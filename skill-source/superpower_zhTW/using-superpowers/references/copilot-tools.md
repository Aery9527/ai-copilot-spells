# Copilot CLI 工具對應表

Skills 使用 Claude Code 的工具名稱。當你在 skill 中遇到這些名稱時，請使用你的平台對應工具：

| Skill 所引用的名稱 | Copilot CLI 對應工具 |
|-------------------|----------------------|
| `Read`（讀取檔案） | `view` |
| `Write`（建立檔案） | `create` |
| `Edit`（編輯檔案） | `edit` |
| `Bash`（執行命令） | `bash` |
| `Grep`（搜尋檔案內容） | `grep` |
| `Glob`（依名稱搜尋檔案） | `glob` |
| `Skill` 工具（呼叫 skill） | `skill` |
| `WebFetch` | `web_fetch` |
| `Task` 工具（派遣子代理） | `task` 搭配 `agent_type: "general-purpose"` 或 `"explore"` |
| 多個 `Task` 呼叫（並行） | 多次 `task` 呼叫 |
| Task 狀態/輸出 | `read_agent`、`list_agents` |
| `TodoWrite`（任務追蹤） | `sql` 搭配內建的 `todos` 資料表 |
| `WebSearch` | 無對應工具——請改用 `web_fetch` 搭配搜尋引擎 URL |
| `EnterPlanMode` / `ExitPlanMode` | 無對應工具——保持在主會話中繼續操作 |

## 非同步 shell 會話

Copilot CLI 支援持久性非同步 shell 會話，在 Claude Code 中沒有直接對應：

| 工具 | 用途 |
|------|------|
| `bash` 搭配 `async: true` | 在背景啟動長時間執行的命令 |
| `write_bash` | 向正在執行的非同步會話傳送輸入 |
| `read_bash` | 讀取非同步會話的輸出 |
| `stop_bash` | 終止非同步會話 |
| `list_bash` | 列出所有活躍的 shell 會話 |

## Copilot CLI 額外工具

| 工具 | 用途 |
|------|------|
| `store_memory` | 為未來的會話持久化關於程式碼庫的事實 |
| `report_intent` | 以當前意圖更新 UI 狀態列 |
| `sql` | 查詢會話的 SQLite 資料庫（todos、元資料） |
| `fetch_copilot_cli_documentation` | 查閱 Copilot CLI 文件 |
| GitHub MCP 工具（`github-mcp-server-*`） | 原生 GitHub API 存取（issues、PRs、程式碼搜尋） |