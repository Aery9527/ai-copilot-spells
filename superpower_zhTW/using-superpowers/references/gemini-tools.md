# Gemini CLI 工具對應表

Skills 使用 Claude Code 的工具名稱。當你在 skill 中遇到這些名稱時，請使用你的平台對應工具：

| Skill 所引用的名稱 | Gemini CLI 對應工具 |
|-------------------|---------------------|
| `Read`（讀取檔案） | `read_file` |
| `Write`（建立檔案） | `write_file` |
| `Edit`（編輯檔案） | `replace` |
| `Bash`（執行命令） | `run_shell_command` |
| `Grep`（搜尋檔案內容） | `grep_search` |
| `Glob`（依名稱搜尋檔案） | `glob` |
| `TodoWrite`（任務追蹤） | `write_todos` |
| `Skill` 工具（呼叫 skill） | `activate_skill` |
| `WebSearch` | `google_web_search` |
| `WebFetch` | `web_fetch` |
| `Task` 工具（派遣子代理） | `@agent-name`（詳見[子代理支援](#子代理支援)） |

## 子代理支援

Gemini CLI 透過 `@` 語法原生支援子代理。使用內建的 `@generalist` 代理來派遣任何任務——它可以存取所有工具，並遵循你提供的提示。

當 skill 要求派遣命名代理類型時，請使用 `@generalist` 搭配 skill 提示模板中的完整提示：

| Skill 指令 | Gemini CLI 對應 |
|------------|----------------|
| `Task tool (superpowers:implementer)` | `@generalist` 搭配已填寫完成的 `implementer-prompt.md` 模板 |
| `Task tool (superpowers:spec-reviewer)` | `@generalist` 搭配已填寫完成的 `spec-reviewer-prompt.md` 模板 |
| `Task tool (superpowers:code-reviewer)` | `@code-reviewer`（內建代理）或 `@generalist` 搭配已填寫的審查提示 |
| `Task tool (superpowers:code-quality-reviewer)` | `@generalist` 搭配已填寫完成的 `code-quality-reviewer-prompt.md` 模板 |
| `Task tool (general-purpose)` 搭配行內提示 | `@generalist` 搭配你的行內提示 |

### 填寫提示模板

Skills 提供含有佔位符的提示模板，例如 `{WHAT_WAS_IMPLEMENTED}` 或 `[FULL TEXT of task]`。填寫所有佔位符，並將完整提示作為訊息傳遞給 `@generalist`。提示模板本身包含代理的角色、審查標準和預期輸出格式——`@generalist` 將照此執行。

### 並行派遣

Gemini CLI 支援並行子代理派遣。當 skill 要求你同時並行派遣多個獨立的子代理任務時，在同一個提示中一次請求所有這些 `@generalist` 或命名子代理任務。保持依賴任務的順序，但不要僅為了維持較簡單的歷史記錄而將獨立的子代理任務序列化。

## Gemini CLI 額外工具

以下工具在 Gemini CLI 中可用，但在 Claude Code 中沒有對應工具：

| 工具 | 用途 |
|------|------|
| `list_directory` | 列出檔案和子目錄 |
| `save_memory` | 跨會話將事實持久化到 GEMINI.md |
| `ask_user` | 向使用者請求結構化輸入 |
| `tracker_create_task` | 豐富的任務管理（建立、更新、列出、視覺化） |
| `enter_plan_mode` / `exit_plan_mode` | 在進行變更前切換到唯讀研究模式 |
