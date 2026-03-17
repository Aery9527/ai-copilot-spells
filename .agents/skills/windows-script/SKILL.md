---
name: windows-script
description: >-
  Windows 批次腳本（.bat/.cmd）與 PowerShell（.ps1）的開發守則與陷阱防範。
  任何涉及撰寫、修改、review .bat、.cmd 或 .ps1 檔案的任務都應使用此 skill。
  涵蓋：cmd 巢狀 if...else 語法錯誤、delayed expansion 失效、errorlevel 語義陷阱、
  PowerShell 錯誤處理、exit code 傳遞、字串引號規則、
  .bat 檔案必須以系統 code page（CP950）儲存等高頻踩坑點。
  修改任何 Windows 腳本前務必先讀完此 skill。
---

# Windows Script 開發守則

## Overview

Windows cmd 和 PowerShell 各有一套直覺上不顯眼、卻會靜悄悄讓腳本出錯的語法規則。
本守則記錄實際踩過的坑，避免重複犯同樣的錯誤。

---

## Batch (.bat / .cmd) 守則

### 1. 巢狀 if...else ── 最高頻陷阱

**問題**：cmd parser 在解析多行 `if...else` 時，若 `else` 分支的括號塊內含另一個完整的
`if...else`，外層的 `else` 會被報錯「這個時候不應有 else」。

```batch
REM ❌ 會報錯
if !CONDITION_A!==1 (
    if !CONDITION_B!==1 (
        echo B is true
    ) else (
        echo B is false
    )
) else (
    echo A is false   ← 「這個時候不應有 else」
)
```

**根本原因**：cmd 把外層 `else` 誤認為內層 `if` 的第二個 `else`，解析失敗。

**解法：把含 else 的巢狀邏輯提取為 `call :subroutine`**

```batch
REM ✅ 正確做法
if !CONDITION_A!==1 (
    call :handle_b
) else (
    echo A is false
)
goto :eof

:handle_b
if !CONDITION_B!==1 (
    echo B is true
) else (
    echo B is false
)
goto :eof
```

`call :label` 共享父層的 `setlocal` 環境，子例程內對變數的修改直接生效，語意不變。

---

### 2. Delayed Expansion ── for loop / if block 內的變數讀取

**問題**：在 `for` 迴圈或 `if` 括號塊內，`%VAR%` 是 parse-time 展開（整個塊在執行前已替換完畢），
所以在塊內更新的變數，在同一塊內讀取永遠是舊值。

```batch
setlocal enabledelayedexpansion
set COUNT=0
for /l %%i in (1,1,3) do (
    set /a COUNT+=1
    echo %COUNT%    ← ❌ 永遠印 0（parse-time 展開）
    echo !COUNT!    ← ✅ 印 1, 2, 3
)
```

**規則**：
- 宣告在腳本頂端：`setlocal enabledelayedexpansion`
- `for` / `if` 塊外部：`%VAR%` 和 `!VAR!` 都可以
- `for` / `if` 塊**內部**：一律用 `!VAR!`

---

### 3. Errorlevel 語義 ── >= 不是 ==

**問題**：`if errorlevel N` 的語義是「exitcode >= N」，不是「== N」。

```batch
REM ❌ 誤解：以為只有 errorlevel 恰好等於 1 才觸發
if errorlevel 1 echo failed    ← exitcode 2, 3, 127 也會觸發

REM ✅ 正確：明確比對
if !errorlevel!==0 (
    echo success
) else (
    echo failed, code=!errorlevel!
)
```

搭配 `setlocal enabledelayedexpansion` 後，`!errorlevel!` 是最直觀且語義精確的寫法。
注意：在 `&&` / `||` 鏈後，`errorlevel` 已被後續指令覆寫，要先 `set EC=!errorlevel!` 保存。

---

### 4. else 必須緊跟右括號

`else` 必須與上一個 `if` 塊的右括號 `)` 同行，不能換行。

```batch
REM ❌ 會報錯
if "!VAR!"=="1" (
    echo one
)
else (
    echo other
)

REM ✅ 正確
if "!VAR!"=="1" (
    echo one
) else (
    echo other
)
```

---

### 5. 特殊字元轉義

在 `echo` 等輸出指令中，以下字元需要 `^` 轉義：

| 字元 | 轉義 | 說明 |
|------|------|------|
| `&` | `^&` | 指令分隔符 |
| `\|` | `^\|` | 管線 |
| `<` `>` | `^<` `^>` | 重新導向 |
| `^` | `^^` | 轉義字元本身 |
| `!` | `^^!` | 在 `enabledelayedexpansion` 下 `!` 也是特殊字元 |

```batch
REM 印出 [!] WARNING: don't use & here
echo [^^!] WARNING: don^'t use ^& here
```

在 `for /f` 的指令字串中，`^` 用兩個 `^^` 轉義（因為 shell 解析兩次）：
```batch
for /f "tokens=1" %%a in ('git diff --quiet 2^>nul') do ...
```

---

### 6. pushd / popd 配對

`pushd` 沒有對應的 `popd` 會讓後續路徑操作出錯。
所有 `exit /b`、`goto` 的離開路徑都要確保 `popd` 已執行。

```batch
pushd "!SUBMODULE!"
git merge "!SOURCE!"
if !errorlevel! neq 0 (
    echo failed
    popd          ← 離開前先 popd
    exit /b 1
)
popd
```

---

### 7. set /a 計算不需要 !

`set /a` 內部有自己的變數解析，不需要 `%` 或 `!`：

```batch
set /a COUNT+=1          ✅
set /a COUNT=!COUNT!+1   ← 多此一舉，但不會出錯
```

---

### 8. .bat 檔案編碼 ── 必須用系統 Code Page，不能用 UTF-8

**問題**：`.bat` 檔案以 UTF-8 儲存，在繁體中文 Windows（cmd.exe code page **CP950**）執行時，
中文注釋（REM）的 UTF-8 multibyte byte 序列會被 cmd.exe 以 CP950 誤解析，
某些 byte 組合意外形成可執行指令，觸發 `系統找不到指定的檔案。` 吐到 **stderr**，
且出現在腳本自身第一行輸出之前（令人困惑）。

**症狀**：
- 腳本功能完全正常，但每次執行都有一行不明 stderr 錯誤
- 錯誤訊息為 `系統找不到指定的檔案。`（CP950）或 `The system cannot find the file specified.`（切換 code page 後）
- 錯誤在 banner / 第一個 `echo` 之前出現

**根本原因**：
cmd.exe 用**系統 code page**（CP950）讀取並解析整個 .bat 檔案。
UTF-8 中文字元的 byte 序列（如 `E4 B8 80`）被 CP950 誤讀後，可能碰巧形成一個
「嘗試執行不存在的檔案」的隱形指令。

**解法：將 .bat 檔案以 CP950 儲存**

```powershell
# PowerShell：批次轉換所有 .bat 為 CP950
$cp950  = [System.Text.Encoding]::GetEncoding(950)
$utf8   = [System.Text.Encoding]::UTF8
Get-ChildItem scripts\*.bat | ForEach-Object {
    $content = [System.IO.File]::ReadAllText($_.FullName, $utf8)
    [System.IO.File]::WriteAllText($_.FullName, $content, $cp950)
}
```

**常見誤解：`chcp 65001` 可以修復** → ❌ 無效

`chcp 65001` 只改變 console 的 **I/O 輸出 encoding**，不影響 cmd.exe **讀取與解析
.bat 檔案**的方式。腳本開始執行時 cmd.exe 早已用 CP950 掃描過整份檔案了。

```batch
@echo off
chcp 65001 >nul     ← ❌ 來不及，UTF-8 bytes 已經被 CP950 誤讀
```

**額外陷阱：UTF-8 BOM 破壞第一行**

若 .bat 以 UTF-8 **with BOM**（`EF BB BF`）儲存，BOM bytes 在 CP950 下被讀成亂碼，
會破壞 `@echo off`，導致 echo 未關閉且第一行顯示亂碼命令。

**規則**：含中文注釋的 `.bat` → 存 **CP950**；若改用純英文注釋 → ASCII/UTF-8 皆可。

---

## PowerShell (.ps1) 守則

### 1. 錯誤處理 ── 預設靜默吞錯

PowerShell cmdlet 預設 `$ErrorActionPreference = 'Continue'`，遇到錯誤不會拋出 exception，
腳本繼續執行。任何需要 fail-fast 的腳本都應在開頭設定：

```powershell
$ErrorActionPreference = 'Stop'
```

或針對單一指令：
```powershell
Get-Item "nonexistent" -ErrorAction Stop
```

外部程式（`git`, `go` 等）的失敗不觸發 `$ErrorActionPreference`，需要手動檢查：
```powershell
git merge $source
if ($LASTEXITCODE -ne 0) { throw "merge failed: exit $LASTEXITCODE" }
```

---

### 2. $? vs $LASTEXITCODE

| 變數 | 適用對象 | 說明 |
|------|---------|------|
| `$?` | PowerShell cmdlet | `$true` / `$false` |
| `$LASTEXITCODE` | 外部執行檔（.exe / .bat） | 整數 exit code |

```powershell
git fetch            # 外部程式
$LASTEXITCODE        # ✅ 用這個

Get-Item "..."       # cmdlet
$?                   # ✅ 用這個
```

---

### 3. 字串引號

- **單引號** `'...'`：字面值，不展開變數
- **雙引號** `"..."`：展開 `$var` 和 `` `n `` 等 escape

```powershell
$name = "World"
Write-Host 'Hello $name'   # 印 Hello $name
Write-Host "Hello $name"   # 印 Hello World
```

路徑含空格時必須加引號；呼叫含空格路徑的執行檔需用 `&`：
```powershell
& "C:\Program Files\Git\bin\git.exe" status
```

---

### 4. Exit Code 傳遞

PowerShell script 結束時預設 exit code 為 0，即使內部出錯。
呼叫端（.bat 或 CI）需要正確 exit code 時：

```powershell
# 腳本最後
exit $LASTEXITCODE

# 或明確傳遞
if ($failed) { exit 1 }
exit 0
```

---

### 5. 陣列邊界

空陣列用 `@()` 宣告，否則 `$null` 會讓 `.Count` 拋 NullReference：

```powershell
$items = @()              # ✅ 空陣列，$items.Count = 0
$items = $null            # ❌ $items.Count 會是 null，在 strict mode 報錯
```

只有一個元素時，pipeline 可能把陣列「展開」成純物件：
```powershell
$result = @(Get-ChildItem "." -Filter "*.go")   # 用 @() 強制保留陣列型別
```

---

### 6. 中文 / UTF-8 輸出

Windows PowerShell（5.x）預設 console encoding 是 CP950（繁中）或 GBK（簡中），
可能讓中文輸出亂碼或讓 `git` 輸出被截斷：

```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding          = [System.Text.Encoding]::UTF8
```

PowerShell 7+ 預設 UTF-8，通常不需要手動設定。

---

## 共通守則

### 腳本開頭 Checklist

**.bat**
```batch
@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0\.."          REM 切換到專案根目錄（如有需要）
```

**.ps1**
```powershell
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot "..")   # 切換到專案根目錄（如有需要）
```

### 路徑分隔符

- `.bat`：用 `\`，含空格的路徑加雙引號 `"C:\path with space\file"`
- `.ps1`：用 `Join-Path` 或 `/`（PowerShell 兼容），含空格必須加引號

### 不要混用 cmd 和 PowerShell 語法

`.bat` 裡不能直接用 PowerShell cmdlet；`.ps1` 裡不能用 `%VAR%`。
需要互相呼叫時：

```batch
REM .bat 呼叫 .ps1
powershell -ExecutionPolicy Bypass -File ".\script.ps1"
if !errorlevel! neq 0 exit /b !errorlevel!
```

```powershell
# .ps1 呼叫 .bat
cmd /c "script.bat"
if ($LASTEXITCODE -ne 0) { throw "bat failed" }
```
