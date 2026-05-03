# tool

收納與日常工具、Windows 操作流程相關的文件。

---

## 文件索引

| 文件 | 說明 |
|------|------|
| [`claude_desktop_ahk.md`](claude_desktop_ahk.md) | 用 AutoHotkey v2 設定快捷鍵叫出 / 關閉 Claude Desktop |
| [`Microsoft.PowerShell_profile.ps1`](Microsoft.PowerShell_profile.ps1) | PowerShell profile 捷徑函數：`gws`/`jws`（切換工作目錄）、`gcc`/`ggc`/`gcx`（在 Golang 專案叫出各 AI CLI）|
| [`Set-GoEnv.ps1`](Set-GoEnv.ps1) | 設定 Go 環境變數（`GO_HOME`、`PATH`）；被 `Microsoft.PowerShell_profile.ps1` 引用，**兩檔需放在同一目錄** |

> **使用方式**：將 `Microsoft.PowerShell_profile.ps1` 與 `Set-GoEnv.ps1` 複製到同一個資料夾，再將 `Microsoft.PowerShell_profile.ps1` 的內容貼入（或以 dot-source 方式 `. /path/to/Microsoft.PowerShell_profile.ps1` 載入）你的 PowerShell profile（`$PROFILE`）。

---

## 適合放在這裡的內容

- Windows 本機工具安裝與設定
- Claude Desktop 或 Claude Code 的本機端使用輔助文件

如果文件的主題是「腳本本身怎麼用」，請放在 [`../scripts/README.md`](../scripts/README.md) 或 `scripts/` 目錄下；如果主題是「工具或環境怎麼安裝與操作」，則更適合放在 `tool/`。

