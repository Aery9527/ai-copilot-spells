# 基本守則

- 執行所有命令列工具與腳本時都必須透過 Bash：Windows 必須使用 Git for Windows Bash，Unix-like 系統必須使用系統 Bash；Windows 環境嚴禁使用 WSL Bash。
- 每完成一個較大的任務, 判斷該修改的影響範圍若偏大必須 call reviewer 進行對抗式審查, 若無法判斷範圍則必須詢問使用者是否要 call reviewer 進行對抗式審查.
- 對抗式審查 reviewer 優先採用 `aery-claude-code` 的 `claude-code` 進行, 若無法使用才 fallback 使用 `terra xhigh` 進行.
