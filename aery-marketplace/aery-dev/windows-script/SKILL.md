---
name: windows-script
description: >-
  Use when 撰寫、修改、review 任何 Windows 腳本（.ps1、.bat、.cmd），或處理
  PowerShell 的 encoding、BOM、line ending、Windows PowerShell 5.1 相容性、
  中文／非 ASCII 內容、hook script、init.ps1、Windows CLI 自動化時。只要任務碰到
  .ps1、PowerShell、UTF-8、BOM、CRLF/LF、batch script 遷移，就應先使用此 skill。
---

# Windows Script 開發守則

## 快速導覽

- [禁止使用 .bat / .cmd](#禁止使用-bat--cmd--一律改寫為-ps1)
- [PowerShell (.ps1) 守則](#powershell-ps1-守則)
- [腳本開頭 Checklist](#腳本開頭-checklist)
- [常見誤區](#常見誤區)

## ⛔ 禁止使用 .bat / .cmd — 一律改寫為 .ps1

> **這不是建議，是強制規範。**

`.bat` / `.cmd` 是過時的技術遺產，不值得再投資維護成本。遇到需要修改、擴充、除錯或 review 的 batch script，預設策略不是修補，而是直接改寫成 `.ps1`。

**PowerShell 是預設替代方案**：語法與錯誤處理較一致、UTF-8 友善、可讀性與可維護性都明顯較好，也更適合現代 CLI、CI 與自動化工作流。

**遇到現有 .bat 需要修改時 → 直接改寫成 .ps1，不要修補 .bat。**

---

[返回開頭](#快速導覽)

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

### 6. 檔案 encoding / BOM ── 不要把需要支援 5.1 的 `.ps1` 存成 UTF-8 無 BOM

`pwsh` 7+ 能正常讀取 UTF-8 無 BOM，**不代表** `powershell.exe`（Windows PowerShell
5.1）也能正確讀取。只要 `.ps1` 檔案裡有中文、註解、本地化訊息、banner、錯誤訊息或任何
非 ASCII 字元，5.1 就可能因為檔案是 **UTF-8 無 BOM** 而誤判編碼，進而出現 parse error、
字串截斷或亂碼。

**鐵則：**

- 只要腳本需要支援 `powershell.exe` 5.1，且檔案內容含非 ASCII 字元，**預設保存為 UTF-8 with BOM**
- 不要因為 editor、formatter、normalizer 或「全 repo 都 UTF-8 no BOM」的習慣，順手把這類 `.ps1` 改掉
- **BOM 與 line ending 是兩件事**：需要 BOM 不代表要改成 CRLF；line ending 仍優先遵循 repo 內 `.gitattributes` / `.editorconfig`
- 若 repo 已明確規定 `*.ps1` 的 `charset` / `eol`，必須遵守；沒有規定時，遇到 5.1 相容性需求就保守選 **UTF-8 with BOM**
- 除非能明確確認腳本只支援 `pwsh` 7+ 且全檔 ASCII，否則不要自行降成 UTF-8 無 BOM

修改這類檔案後，若環境允許，至少做一次 5.1 驗證：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\script.ps1
```

---

### 7. 中文 / UTF-8 輸出

Windows PowerShell（5.x）預設 console encoding 是 CP950（繁中）或 GBK（簡中），
可能讓中文輸出亂碼或讓 `git` 輸出被截斷：

```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding          = [System.Text.Encoding]::UTF8
```

PowerShell 7+ 預設 UTF-8，通常不需要手動設定。

---

### 8. CWD 保護 ── 禁止污染呼叫端目錄

腳本頂層直接呼叫 `Set-Location` 會**永久改變呼叫端（termial）的工作目錄**，用完腳本後 CWD 已不是原始位置，使用者需要手動 `cd` 回去。

**正確做法**：在腳本最頂層先儲存原始位置，用 `try/finally` 確保還原：

```powershell
$originalLocation = Get-Location
Set-Location (Join-Path $PSScriptRoot "..")
try {
    # ... 腳本主體 ...
} finally {
    Set-Location $originalLocation
}
```

> `exit` 在 `try` 塊內仍會執行 `finally`，所以這個模式在任何退出路徑下都安全。

**❌ 不要用 `Push-Location` / `Pop-Location`**：腳本內部若有針對子模組的 `Push-Location $sub`，一旦遇到 `exit`、`return` 或錯誤提前退出，這些 inner push 不會被 pop，導致 `finally` 中的 `Pop-Location` 彈出的是 inner push 而非原始位置，CWD 仍然被污染。`$originalLocation` 方法完全不依賴 location stack，任何執行路徑都正確。

---

### 9. 彩色輸出 ── 所有互動式腳本必須使用

**凡是使用者會在 terminal 直接執行的腳本，都必須使用 `-ForegroundColor` 讓輸出可讀**。純後台 / CI 腳本例外。

**色彩使用標準（必須遵循）：**

| 場景 | 色彩 | 範例 |
|------|------|------|
| 大標題 / Banner | `Cyan` | `=== Switch Branch ===` |
| 小節標題 | `Blue` | `--- Summary ---` |
| 成功 `[OK]` | `Green` | `[OK] Switched to develop` |
| 錯誤 `[X] ERROR` | `Red` | `[X] ERROR: checkout failed` |
| 警告 `[!]` / 取消 | `Yellow` | `[!] Cancelled` |
| Repo / 資源名稱列 | `Cyan` | `  game-go-common` |
| 選單項目數字 `[1]` | `Green` | `[1] develop` |
| 選單特殊選項 `[e]` | `Cyan` | `[e] enter branch name` |
| Summary 成功計數 | `Green` | `Success: 6` |
| Summary 失敗計數 | `Red` | `Failed: 1` |

```powershell
Write-Host "=== Switch Branch ===" -ForegroundColor Cyan
Write-Host "  [OK] Switched to $branch" -ForegroundColor Green
Write-Host "  [X] ERROR: checkout failed" -ForegroundColor Red
Write-Host "  [!] Cancelled by user" -ForegroundColor Yellow
Write-Host "--- Summary ---" -ForegroundColor Blue
Write-Host "Success: $successCount" -ForegroundColor Green
Write-Host "Failed:  $failCount"  -ForegroundColor Red
```

---

[返回開頭](#快速導覽)

## 腳本開頭 Checklist

```powershell
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding          = [System.Text.Encoding]::UTF8

# 若腳本需要支援 powershell.exe 5.1 且檔案含非 ASCII，檔案本身必須保存為 UTF-8 with BOM
# CWD 保護：必須用 $originalLocation + try/finally，禁止裸 Set-Location
$originalLocation = Get-Location
Set-Location (Join-Path $PSScriptRoot "..")
try {
    # ... 腳本主體 ...
} finally {
    Set-Location $originalLocation
}
```

### 路徑分隔符

用 `Join-Path` 或 `/`（PowerShell 兼容），含空格必須加引號。

```powershell
$path = Join-Path $PSScriptRoot ".." "scripts" "go-mod.ps1"
& "C:\Program Files\Git\bin\git.exe" status
```

[返回開頭](#快速導覽)

## 常見誤區

1. **「`pwsh` 跑得動，所以 `powershell.exe` 也一定沒問題」**  
   錯。`pwsh` 7+ 對 UTF-8 無 BOM 友善很多，5.1 不是。
2. **「我已經把 console OutputEncoding 設成 UTF-8，所以檔案 encoding 不重要」**  
   錯。console 輸出 encoding 與 `.ps1` 檔案本身的儲存 encoding 是兩件事。
3. **「需要 BOM 就順手改成 CRLF」**  
   錯。BOM 與 line ending 無關，line ending 仍然遵循 repo 規則。
4. **「只是改一行註解 / 中文字串，不會影響腳本執行」**  
   錯。只要檔案從全 ASCII 變成含非 ASCII，5.1 的風險就上來了。

[返回開頭](#快速導覽)
