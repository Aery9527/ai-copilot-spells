---
name: windows-script
description: >-
  撰寫、修改或 review 任何 Windows 腳本（.ps1、.bat、.cmd）時使用。
---

# Windows Script 開發守則

## ⛔ 禁止使用 .bat / .cmd — 一律改寫為 .ps1

> **這不是建議，是強制規範。**

`.bat` / `.cmd` 是 1980 年代的技術遺產，充滿無法修復的設計缺陷：

| 地雷 | 說明 |
|------|------|
| **Self-modification race condition** | cmd.exe 逐行讀取磁碟上的 .bat 檔；若腳本執行期間 `git checkout` 替換了該檔案（例如切換到不同 encoding 的分支），cmd.exe 從舊 byte offset 繼續讀新檔案，跳到完全錯誤的程式碼路徑，產生難以除錯的靜默錯誤 |
| **CP950 編碼地獄** | cmd.exe 以系統 code page（CP950）解析整份 .bat；UTF-8 中文注釋的 bytes 被 CP950 誤讀後可能形成隱形指令，在第一行輸出之前就噴出 `系統找不到指定的檔案。` |
| **Delayed expansion 陷阱** | `%VAR%` 是 parse-time 展開；for/if 塊內改過的變數在同一塊內讀取永遠是舊值，需要 `!VAR!` + `setlocal enabledelayedexpansion`，極易遺漏 |
| **巢狀 if/else 報錯** | else 分支內含另一個 if/else 會讓 parser 報錯「這個時候不應有 else」，需要 call :subroutine 繞過 |
| **Errorlevel 語義陷阱** | `if errorlevel 1` 的語義是 `>= 1`，不是 `== 1`，高 exit code 會誤觸 |
| **無原生陣列** | 只能用 `VAR_1`, `VAR_2`, `VAR_N` 模擬陣列，脆弱且難維護 |
| **無結構化錯誤處理** | 沒有 try/catch/finally，清理路徑（popd、還原狀態）容易在 goto 迷宮中遺漏 |

**PowerShell 從根本解決以上所有問題**：整個 .ps1 在執行前一次性 parse 進記憶體；native UTF-8；原生陣列；`try/finally`；`$LASTEXITCODE`；無 delayed expansion 陷阱。

**遇到現有 .bat 需要修改時 → 直接改寫成 .ps1，不要修補 .bat。**

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

## 腳本開頭 Checklist

```powershell
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding          = [System.Text.Encoding]::UTF8
Set-Location (Join-Path $PSScriptRoot "..")   # 切換到專案根目錄（如有需要）
```

### 路徑分隔符

用 `Join-Path` 或 `/`（PowerShell 兼容），含空格必須加引號。

```powershell
$path = Join-Path $PSScriptRoot ".." "scripts" "go-mod.ps1"
& "C:\Program Files\Git\bin\git.exe" status
```
