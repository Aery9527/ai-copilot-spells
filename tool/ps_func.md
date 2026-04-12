# 在 Windows 設定 PowerShell 快捷指令

## 快速導覽

- [檔案位置](#檔案位置)
- [建議目錄結構](#建議目錄結構)
- [Profile 範例](#profile-範例)
- [Helper Scripts 範例](#helper-scripts-範例)
- [快捷指令對照](#快捷指令對照)
- [補充說明](#補充說明)

## 檔案位置

PowerShell 的快捷指令建議拆成兩層：

| 角色 | 建議位置 | 說明 |
| --- | --- | --- |
| PowerShell 7 profile | `~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` | PowerShell 啟動時自動載入 |
| Windows PowerShell 5.1 profile | `~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` | 若仍有使用 5.1，再同步一份 |
| 自訂 helper scripts 目錄 | `<cmd-root>` | 放 `env-*.ps1`、`exe-*.ps1` 等共用腳本 |

目前實際內容顯示：**profile 檔放在 `~\Documents\PowerShell`，而語言環境與 CLI 包裝腳本放在另一個自訂目錄**。文件內已將原本的個人路徑去敏感化，統一改成 `~` 與 `<cmd-root>`。

[返回開頭](#快速導覽)

## 建議目錄結構

```text
~\Documents\PowerShell\
  Microsoft.PowerShell_profile.ps1

<cmd-root>\
  env-golang.ps1
  env-java.ps1
  exe-cc.ps1
  exe-gc.ps1
```

[返回開頭](#快速導覽)

## Profile 範例

以下寫法對應目前實際使用的模式：**workspace shortcut 放在 profile，語言環境與 CLI 啟動邏輯拆到外部 `.ps1` 後再 dot-source 進來**。

```powershell
$cmdRoot = '<cmd-root>'

$repoWorkspace = '<repo-workspace>'
$javaWorkspace = '<java-workspace>'
$goWorkspace   = '<go-workspace>'

$goProject0 = '<go-project-0>'
$goProject1 = '<go-project-1>'
$goProject2 = '<go-project-2>'

# cd workspace

function aws {
    Set-Location $repoWorkspace
}

function jws {
    Set-Location $javaWorkspace
}

function gws {
    Set-Location $goWorkspace
}

# GitHub Copilot

function jgc {
    . (Join-Path $cmdRoot 'env-java.ps1')
    . (Join-Path $cmdRoot 'exe-gc.ps1') @args
}

function ggc {
    . (Join-Path $cmdRoot 'env-golang.ps1')
    . (Join-Path $cmdRoot 'exe-gc.ps1') @args
}

function ggc0 {
    Set-Location $goProject0
    . (Join-Path $cmdRoot 'env-golang.ps1')
    . (Join-Path $cmdRoot 'exe-gc.ps1') @args
}

function ggc1 {
    Set-Location $goProject1
    . (Join-Path $cmdRoot 'env-golang.ps1')
    . (Join-Path $cmdRoot 'exe-gc.ps1') @args
}

function ggc2 {
    Set-Location $goProject2
    . (Join-Path $cmdRoot 'env-golang.ps1')
    . (Join-Path $cmdRoot 'exe-gc.ps1') @args
}

# Claude Code

function jcc {
    . (Join-Path $cmdRoot 'env-java.ps1')
    . (Join-Path $cmdRoot 'exe-cc.ps1') @args
}

function gcc {
    . (Join-Path $cmdRoot 'env-golang.ps1')
    . (Join-Path $cmdRoot 'exe-cc.ps1') @args
}

function gcc0 {
    Set-Location $goProject0
    . (Join-Path $cmdRoot 'env-golang.ps1')
    . (Join-Path $cmdRoot 'exe-cc.ps1') @args
}

function gcc1 {
    Set-Location $goProject1
    . (Join-Path $cmdRoot 'env-golang.ps1')
    . (Join-Path $cmdRoot 'exe-cc.ps1') @args
}

function gcc2 {
    Set-Location $goProject2
    . (Join-Path $cmdRoot 'env-golang.ps1')
    . (Join-Path $cmdRoot 'exe-cc.ps1') @args
}
```

`@args` 會把你在 shell 輸入的參數直接轉交給 `copilot` 或 `claude`。

[返回開頭](#快速導覽)

## Helper Scripts 範例

### `env-golang.ps1`

```powershell
$env:GO_HOME    = '<go-sdk-root>'
$env:PROTP_HOME = '<protoc-root>'
$env:PATH       = "$env:GO_HOME\bin;$env:PROTP_HOME\bin;$env:PATH"
```

### `env-java.ps1`

```powershell
$env:JAVA_HOME  = '<jdk-root>'
$env:MAVEN_HOME = '<maven-bin-root>'
$env:PATH       = "$env:JAVA_HOME\bin;$env:MAVEN_HOME\bin;$env:PATH"
```

### `exe-gc.ps1`

```powershell
copilot --allow-all-tools @args
```

### `exe-cc.ps1`

```powershell
claude --permission-mode auto @args
```

這種拆法的優點是：

1. `profile` 專心放快捷函數，不把語言環境細節全部塞進同一檔。
2. Go / Java 的環境設定可以重複使用。
3. Copilot / Claude 的啟動參數可以集中管理。

[返回開頭](#快速導覽)

## 快捷指令對照

| 指令 | 行為 |
| --- | --- |
| `aws` | 切到 repo 工作區 |
| `jws` | 切到 Java 工作區 |
| `gws` | 切到 Go 工作區 |
| `jgc` | 載入 Java 環境後執行 GitHub Copilot |
| `ggc` | 載入 Go 環境後執行 GitHub Copilot |
| `ggc0` / `ggc1` / `ggc2` | 切到指定 Go 專案後執行 GitHub Copilot |
| `jcc` | 載入 Java 環境後執行 Claude Code |
| `gcc` | 載入 Go 環境後執行 Claude Code |
| `gcc0` / `gcc1` / `gcc2` | 切到指定 Go 專案後執行 Claude Code |

[返回開頭](#快速導覽)

## 補充說明

1. 修改完 `Microsoft.PowerShell_profile.ps1` 後，重新開一個 shell，或執行 `. $PROFILE` 重新載入。
2. 若你要把設定分享給別人，請只保留 `~`、`<cmd-root>`、`<go-sdk-root>` 這類 placeholder，不要提交個人機器的實際絕對路徑。
3. 若同時使用 PowerShell 7 與 Windows PowerShell 5.1，記得確認兩邊的 profile 是否需要同步。
4. 更新 PowerShell 可用：`winget upgrade Microsoft.PowerShell`

[返回開頭](#快速導覽)
