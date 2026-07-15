# tool

收納與日常工具、Windows 操作流程相關的文件。

```mermaid
flowchart TD
    A["想找本機工具文件"] --> B{"主題是什麼？"}
    B -->|"工具或環境安裝"| C["tool/ 文件"]
    B -->|"腳本本身怎麼用"| D["scripts/README.md"]
```

---

## Quick Navigation

- [文件索引](#文件索引)
- [適合放在這裡的內容](#適合放在這裡的內容)

[Back to top](#quick-navigation)

---

## 文件索引

| 文件 | 說明 |
|------|------|
| [`claude_desktop_ahk.md`](claude_desktop_ahk.md) | 用 AutoHotkey v2 設定快捷鍵叫出 / 關閉 Claude Desktop |
| [`PowerShell/`](PowerShell/) | PowerShell 啟動設定與 AI CLI / 語言環境切換腳本 |

### `PowerShell/` 內容

| 文件 | 說明 |
|------|------|
| [`PowerShell/Microsoft.PowerShell_profile.ps1`](PowerShell/Microsoft.PowerShell_profile.ps1) | PowerShell profile 入口（隨 OneDrive 同步）；若 `$HOME\.config\powershell\local_profile.ps1` 存在就載入它 |
| [`PowerShell/local_profile.ps1`](PowerShell/local_profile.ps1) | 共用指令定義；提供 `gws`/`jws` 工作目錄切換，以及 `acc`/`agc`/`acx`、`gcc`/`ggc`/`gcx`、`jcc`/`jgc`/`jcx` 等捷徑函數，內部用 `$ToolRoot`（= `$HOME\.config\powershell`）定位同目錄的 `Exe-*.ps1` / `Set-*.ps1` |
| [`PowerShell/Exe-CC.ps1`](PowerShell/Exe-CC.ps1) | 執行 Claude Code：`claude --permission-mode auto @args` |
| [`PowerShell/Exe-GC.ps1`](PowerShell/Exe-GC.ps1) | 執行 GitHub Copilot CLI：`copilot --allow-all-tools @args` |
| [`PowerShell/Exe-CX.ps1`](PowerShell/Exe-CX.ps1) | 執行 Codex CLI：`codex --sandbox danger-full-access -a never @args` |
| [`PowerShell/Set-DevEnv.ps1`](PowerShell/Set-DevEnv.ps1) | 開發時共用環境變數設定入口；供 AI CLI / Go / Java wrapper 載入 |
| [`PowerShell/Set-GoEnv.ps1`](PowerShell/Set-GoEnv.ps1) | 設定 Go workspace 的 `GO_BIN_HOME` / `PATH` |
| [`PowerShell/Set-GoVersion.ps1`](PowerShell/Set-GoVersion.ps1) | 設定 Go 版本與 `GO_HOME` / `PATH` |
| [`PowerShell/Set-JavaVersion.ps1`](PowerShell/Set-JavaVersion.ps1) | 設定 Java 版本與 `JAVA_HOME` / `PATH` |
| [`PowerShell/Set-JavaEnv.ps1`](PowerShell/Set-JavaEnv.ps1) | 設定 Maven 安裝路徑的 `MAVEN_HOME` / `PATH` |

> **使用方式**：因為 `$PROFILE` 常隨 OneDrive 同步到多台機器，而各機器上這個 repo 的實際路徑可能不同，此架構分成兩層：
> 1. 把 [`PowerShell/Microsoft.PowerShell_profile.ps1`](PowerShell/Microsoft.PowerShell_profile.ps1) 的內容 dot-source 進你的 `$PROFILE`（這支同步、各機器相同）。
> 2. 把整個 [`PowerShell/`](PowerShell/) 目錄下所有檔案部署（複製）到 `$HOME\.config\powershell\`（不同步，每台機器各自一份）。
>
> [`PowerShell/local_profile.ps1`](PowerShell/local_profile.ps1) 內部用 `$ToolRoot = Join-Path $HOME ".config\powershell"` 定位 `Exe-*.ps1` / `Set-*.ps1`，而不是用 `$PSScriptRoot`：因為部署後 `local_profile.ps1` 與其他共用腳本都在 `$HOME\.config\powershell\` 底下，`$ToolRoot` 是這個固定慣例路徑，靠 `$HOME` 自動算出、不需要為每台機器手動改任何路徑。

[Back to top](#quick-navigation)

---

## 適合放在這裡的內容

- Windows 本機工具安裝與設定
- Claude Desktop 或 Claude Code 的本機端使用輔助文件

如果文件的主題是「腳本本身怎麼用」，請放在 [`scripts/README.md`](../scripts/README.md) 或 [`scripts/`](../scripts/) 目錄下；如果主題是「工具或環境怎麼安裝與操作」，則更適合放在 [`tool/`](./)。

[Back to top](#quick-navigation)

