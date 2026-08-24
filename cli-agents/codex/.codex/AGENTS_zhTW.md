# 基本守則

- 執行所有 shell 指令與腳本時都必須使用 Bash 工具，包括 Windows 環境。
- 若 repository 位於 Windows 檔案系統（`C:\...` 或 `/mnt/c/...`），必須優先在 Bash 中呼叫 Windows 原生 Git 的 `git.exe`。只有 repository 位於 WSL 檔案系統時，才使用 WSL 的 `git`。
- 嚴禁把 PowerShell 當成指令 shell，或直接撰寫內嵌 PowerShell 指令。`.ps1` 檔案必須透過 Bash wrapper 執行；wrapper 可依需求選擇 `pwsh` 或 `powershell.exe`。
- 每完成一個較大的任務, 判斷該修改的影響範圍若偏大必須 call reviewer 進行對抗式審查, 若無法判斷範圍則必須詢問使用者是否要 call reviewer 進行對抗式審查.
- 對抗式審查 reviewer 優先採用 `aery-claude-code` 的 `claude-code` 進行, 若無法使用才 fallback 使用 `terra xhigh` 進行.
