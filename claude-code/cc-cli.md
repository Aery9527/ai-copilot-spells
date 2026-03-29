# Claude Code CLI

## 快速導覽

- [常用 CLI 參數](#常用-cli-參數)
- [CLI 內建指令](#cli-內建指令)
- [互動式 slash commands](#互動式-slash-commands)
- [內建 Skills](#內建-skills)
- [互動式特殊功能](#互動式特殊功能)

- 安裝：`npm install -g @anthropic-ai/claude-code`
- 更新：`claude update`，或重新執行 `npm install -g @anthropic-ai/claude-code`
- 來源：
  - <https://code.claude.com/docs/en/cli-reference>
  - <https://code.claude.com/docs/en/commands>
  - <https://code.claude.com/docs/en/interactive-mode>
  - <https://code.claude.com/docs/en/skills>
- 在 prompt 中加入 `ultrathink`（或 `think`、`think hard`、`think harder`）可觸發不同深度的推理模式。也可使用 `Alt+T` 直接切換。
- 普遍 allow 的 tool 啟動指令 `claude --allowedTools "Bash(find:*)" "Bash(cd:*)" "Bash(powershell:*)"`

---

## 常用 CLI 參數

> 下面先整理最常用、最容易直接影響工作流的 `CLI flags`。完整參數仍以 `claude --help` 與官方文件為準。
>
> 官方旗標已比早期版本多出不少 browser、web session、auto mode 與 automation 相關選項；這裡優先保留高影響、日常最常碰到的組合。

### Session 與對話

| flag | example | 說明 | scope / risk | notes |
|---|---|---|---|---|
| `-c`, `--continue` | `claude -c` | 載入目前目錄最近一次的對話並繼續。 | 低 | 快速接回上次工作。 |
| `-r`, `--resume[=SESSION]` | `claude -r "auth-refactor"` | 以 ID 或名稱恢復特定 session，或開啟互動選擇器。 | 低 | 長任務中斷後續跑很實用。 |
| `--fork-session` | `claude -r abc123 --fork-session` | 恢復時建立新 session ID，不覆蓋原本紀錄。 | 低 | 要在舊 session 分叉時使用。 |
| `-n`, `--name=NAME` | `claude -n "my-feature"` | 為本次 session 設定顯示名稱。 | 低 | 會顯示在 `/resume` 清單與 terminal 標題。 |
| `--session-id=UUID` | `claude --session-id "550e8400-e29b-41d4-a716-446655440000"` | 指定本次對話的 session ID。 | 中 | 適合外部系統或自動化流程對接。 |
| `--from-pr=PR` | `claude --from-pr 123` | 恢復與特定 GitHub PR 關聯的 session。 | 低 | 和 `gh pr create` 工作流搭配很方便。 |
| `--no-session-persistence` | `claude -p --no-session-persistence "query"` | 停用 session 持久化（僅 print 模式）。 | 低 | 一次性腳本常用。 |

### 模型與輸出

| flag | example | 說明 | scope / risk | notes |
|---|---|---|---|---|
| `--model=MODEL` | `claude --model claude-sonnet-4-6` | 指定模型，可用 alias（`sonnet`、`opus`）或完整名稱。 | 低 | 可取代互動模式內的 `/model`。 |
| `--effort=LEVEL` | `claude --effort high` | 設定推理強度：`low`、`medium`、`high`、`max`（僅 Opus 4.6）。 | 低 | `max` 僅限本次 session。 |
| `-p`, `--print` | `claude -p "query"` | Print 模式：執行後直接退出，不進入互動介面。 | 中 | 適合腳本化或 CI 整合。 |
| `--output-format=FORMAT` | `claude -p "query" --output-format=json` | 控制輸出格式：`text`、`json`、`stream-json`（僅 print 模式）。 | 中 | `json` 會輸出 JSONL。 |
| `--input-format=FORMAT` | `claude -p --output-format json --input-format stream-json` | 指定 print 模式輸入格式。 | 中 | 處理串流輸入時很有用。 |
| `--json-schema=SCHEMA` | `claude -p --json-schema '{"type":"object"}' "query"` | 要求輸出符合指定 JSON Schema。 | 中 | 結構化輸出整合很實用。 |
| `--verbose` | `claude --verbose` | 啟用詳細日誌，逐 turn 顯示完整輸出。 | 低 | 除錯時實用。 |
| `--max-turns=N` | `claude -p --max-turns 3 "query"` | 限制 agentic turns 數量（print 模式），超過時以錯誤退出。 | 中 | 防止無限迴圈。 |
| `--max-budget-usd=N` | `claude -p --max-budget-usd 5.00 "query"` | 設定最高 API 費用上限（print 模式）。 | 中 | 成本控管。 |
| `--fallback-model=MODEL` | `claude -p --fallback-model sonnet "query"` | 預設模型過載時自動切換備援（print 模式）。 | 低 | 高可用場景實用。 |

### System Prompt

| flag | 說明 | notes |
|---|---|---|
| `--system-prompt=TEXT` | 以自訂文字完全取代預設 system prompt。 | 與 `--system-prompt-file` 互斥。 |
| `--system-prompt-file=PATH` | 從檔案讀取，完全取代預設 system prompt。 | 與 `--system-prompt` 互斥。 |
| `--append-system-prompt=TEXT` | 在預設 system prompt 後附加自訂文字。 | 可與取代旗標並用。 |
| `--append-system-prompt-file=PATH` | 從檔案讀取並附加到 system prompt 末端。 | 可與取代旗標並用。 |

### Tools 與權限

| flag | example | 說明 | scope / risk | notes |
|---|---|---|---|---|
| `--tools=LIST` | `claude --tools "Bash,Edit,Read"` | 限制可用的內建 tools。`""` 停用全部，`"default"` 開啟全部。 | 高 | 精確控制工具範圍。 |
| `--allowedTools=LIST` | `claude --allowedTools "Bash(git log *)"` | 指定可自動執行（不逐次詢問）的 tools。 | 高 | 支援 permission rule 語法。 |
| `--disallowedTools=LIST` | `claude --disallowedTools "Edit"` | 從 model context 完全移除指定 tools。 | 中 | 建立安全護欄。 |
| `--permission-mode=MODE` | `claude --permission-mode plan` | 以指定 permission mode 啟動。 | 中 | 常用值包含 `plan`，也可與 auto / bypass 類模式搭配。 |
| `--allow-dangerously-skip-permissions` | `claude --permission-mode plan --allow-dangerously-skip-permissions` | 啟用「可切到 bypass」的能力，但不會立刻跳過權限。 | **高** | 適合搭配 permission mode 控制流程。 |
| `--dangerously-skip-permissions` | `claude --dangerously-skip-permissions` | 直接跳過權限提示。 | **極高** | 極度謹慎使用。 |
| `--bare` | `claude --bare -p "query"` | Minimal mode：停用 skills、hooks、plugins、MCP auto-discovery 等自動載入。 | 中 | 腳本化呼叫能更快、更乾淨。 |
| `--disable-slash-commands` | `claude --disable-slash-commands` | 停用本次 session 的所有 slash commands 與 skills。 | 中 | 做基線測試或限制能力時實用。 |
| `--enable-auto-mode` | `claude --enable-auto-mode` | 讓 `Shift+Tab` 可切到 auto mode。 | 中 | 需要支援方案與模型。 |

### Workspace / Browser

| flag | example | 說明 | scope / risk | notes |
|---|---|---|---|---|
| `--add-dir=PATH` | `claude --add-dir ../apps ../lib` | 新增 Claude 可存取的額外工作目錄（會驗證路徑是否存在）。 | 低 | 跨目錄作業時實用。 |
| `-w`, `--worktree[=NAME]` | `claude -w feature-auth` | 在 `<repo>/.claude/worktrees/<name>` 建立隔離的 git worktree session。 | 中 | 省略名稱時自動生成。 |
| `--chrome` | `claude --chrome` | 啟用 Chrome browser integration。 | 中 | Web automation / testing workflow 常用。 |
| `--no-chrome` | `claude --no-chrome` | 明確停用本次 session 的 Chrome integration。 | 低 | 排查問題或保持純 CLI 流程時使用。 |
| `--ide` | `claude --ide` | 啟動時若只找到一個可用 IDE，就自動連線。 | 低 | 常用於已綁定 IDE 的工作流。 |

### MCP 與 Plugin

| flag | example | 說明 | scope / risk | notes |
|---|---|---|---|---|
| `--mcp-config=PATH` | `claude --mcp-config ./mcp.json` | 從 JSON 檔或字串載入 MCP servers（空白分隔可多個）。 | 低 | 快速掛載外部工具。 |
| `--strict-mcp-config` | `claude --strict-mcp-config --mcp-config ./mcp.json` | 只使用 `--mcp-config` 指定的 MCP，忽略其他設定。 | 中 | 乾淨的隔離環境。 |
| `--plugin-dir=PATH` | `claude --plugin-dir ./my-plugins` | 僅本次 session 從指定目錄載入 plugins。可重複使用多個路徑。 | 低 | 臨時試驗 plugin 時方便。 |

### Remote / Automation / Other

| flag | example | 說明 | scope / risk |
|---|---|---|---|
| `--agent=AGENT` | `claude --agent my-agent` | 指定本次 session 使用的 agent（覆蓋 `agent` 設定）。 | 低 |
| `--agents=JSON` | `claude --agents '{"reviewer":{"description":"Reviews code","prompt":"You are a code reviewer"}}'` | 以 JSON 動態定義 custom subagents。 | 中 |
| `--debug[=CATEGORY]` | `claude --debug "api,mcp"` | 啟用 debug 模式，可選擇性過濾類別。 | 低 |
| `--remote` | `claude --remote "Fix the login bug"` | 在 claude.ai 建立新的 web session。 | 中 |
| `--remote-control`, `--rc` | `claude --remote-control "My Project"` | 啟動可由 claude.ai / Claude app 遠端控制的互動 session。 | 中 |
| `--teleport` | `claude --teleport` | 將 web session 拉回本機 terminal。 | 中 |
| `--teammate-mode` | `claude --teammate-mode in-process` | 設定 agent team teammates 的顯示模式。 | 低 |
| `--tmux` | `claude -w feature-auth --tmux` | 為 worktree session 建立 tmux / panes 工作區。 | 中 |
| `-v`, `--version` | `claude --version` | 顯示版本號。 | 低 |
| `--help` | `claude --help` | 顯示說明。 | 低 |

[返回開頭](#快速導覽)

## CLI 內建指令

| command | example | 說明 | 備註 |
|---|---|---|---|
| `claude` | `claude` | 啟動互動式 CLI。 | 預設進入對話式工作流。 |
| `claude "query"` | `claude "explain this repo"` | 帶初始 prompt 啟動互動 session。 | 適合快速帶著脈絡進場。 |
| `claude -p "query"` | `claude -p "summarize this file"` | Print 模式，回應後退出。 | 腳本化與 CI 整合常用。 |
| `cat file | claude -p "query"` | `Get-Content .\logs.txt | claude -p "explain"` | 處理 pipe 進來的內容。 | 適合把外部輸出直接交給 Claude 分析。 |
| `claude -c` | `claude -c` | 繼續目前目錄最近一次對話。 | 快速接回原任務。 |
| `claude -c -p "query"` | `claude -c -p "Check for type errors"` | 以 print 模式繼續最近一次對話。 | 腳本化接續既有上下文。 |
| `claude -r "<session>" "query"` | `claude -r "auth-refactor" "Finish this PR"` | 以名稱或 ID 恢復指定 session 並繼續工作。 | 長任務追蹤很好用。 |
| `claude update` | `claude update` | 更新 CLI 到最新版本。 | 等同重新安裝最新版。 |
| `claude auth login` | `claude auth login --console` | 登入 Anthropic 帳號。 | 支援 `--email`、`--sso`、`--console`。 |
| `claude auth logout` | `claude auth logout` | 登出並移除本機憑證。 | 切換帳號或清理環境。 |
| `claude auth status` | `claude auth status --text` | 顯示認證狀態。 | 預設輸出 JSON；`--text` 為人類可讀格式。 |
| `claude agents` | `claude agents` | 列出所有已設定的 subagents，依來源分組。 | 確認可用 agent 清單。 |
| `claude auto-mode defaults` | `claude auto-mode defaults > rules.json` | 輸出內建 auto mode classifier 規則。 | 可搭配 `claude auto-mode config` 查看實際設定。 |
| `claude mcp` | `claude mcp` | 管理 MCP server 設定。 | 詳見 MCP 文件。 |
| `claude plugin` | `claude plugin install code-review@claude-plugins-official` | 管理 Claude Code plugins。 | `claude plugins` 也是 alias。 |
| `claude remote-control` | `claude remote-control --name "My Project"` | 啟動 Remote Control server。 | 讓 claude.ai 或 Claude app 可控制本機 session。 |

[返回開頭](#快速導覽)

## 互動式 slash commands

> 以下整理的是目前 Claude Code CLI 內建的 `slash commands`。不是所有指令都會對每位使用者顯示：有些取決於平台、方案或環境。**最準仍以互動模式輸入 `/help` 為準**。

### Agent / 模型 / 任務

| command | 說明 | notes |
|---|---|---|
| `/model [model]` | 選擇或直接切換模型。 | 支援的模型可在選單中查看。 |
| `/effort [low|medium|high|max|auto]` | 設定推理強度。 | `max` 僅 Opus 4.6 支援；`auto` 重設成預設。 |
| `/agents` | 管理 agent 設定。 | 確認可用 agent 清單。 |
| `/tasks` | 列出並管理背景任務。 | 含 subagents 與 shell sessions。 |
| `/plan [description]` | 直接進入 plan mode。 | 可直接附帶任務描述。 |
| `/fast [on|off]` | 切換 fast mode。 | 適合快速回應場景。 |
| `/btw <question>` | 問一個不寫入主對話歷史的 side question。 | 只使用目前 context，不會動用 tools。 |

### Code / Workspace / Tooling

| command | 說明 | notes |
|---|---|---|
| `/init` | 初始化 `CLAUDE.md` project guide。 | 可搭配新版 interactive init flow。 |
| `/diff` | 開啟互動式 diff 檢視器，顯示未提交變更與逐 turn 差異。 | 方向鍵可切換檢視。 |
| `/ide` | 管理 IDE 整合並顯示連線狀態。 | 與 VS Code、JetBrains 等整合。 |
| `/chrome` | 設定 Claude in Chrome。 | 管理瀏覽器整合設定。 |
| `/security-review` | 分析目前 branch 待提交的變更，找出安全漏洞。 | 涵蓋 injection、auth、data exposure 等。 |
| `/pr-comments [PR]` | 取得 GitHub PR 的留言。 | 自動偵測當前 branch 的 PR，或手動指定 URL / 編號。 |
| `/install-github-app` | 為 repository 設定 Claude GitHub Actions app。 | GitHub Actions 整合入口。 |
| `/install-slack-app` | 安裝 Claude Slack app。 | 會開啟瀏覽器完成 OAuth。 |
| `/doctor` | 診斷並驗證 Claude Code 安裝與設定。 | 排查環境問題的第一步。 |
| `/insights` | 產生 Claude Code session 分析報告。 | 查看互動模式、摩擦點與專案分布。 |
| `/review` | 啟動 code review workflow。 | **已 deprecated**；官方建議改裝 `code-review` plugin。 |

### Permissions / Directories

| command | 說明 | notes |
|---|---|---|
| `/add-dir <path>` | 新增允許存取的目錄到目前 session。 | 跨工作目錄取檔時常用。 |
| `/permissions` | 檢視或更新 permissions。 | alias：`/allowed-tools`。 |
| `/sandbox` | 切換 sandbox mode（視平台支援）。 | 隔離執行環境。 |

### Session / Context / Sharing

| command | 說明 | notes |
|---|---|---|
| `/resume [session]` | 切換到其他 session，或直接指定 `SESSION-ID` / 名稱。 | alias：`/continue`。 |
| `/branch [name]` | 在目前對話點建立分叉 session。 | alias：`/fork`。 |
| `/rename [name]` | 重新命名目前 session。 | 省略名稱時會自動產生。 |
| `/context` | 以彩色格子視覺化目前 context window 使用量。 | 顯示優化建議與容量警告。 |
| `/compact [instructions]` | 壓縮對話歷史以節省 context。 | 可附帶保留重點的指示。 |
| `/clear` | 清空目前對話歷史。 | aliases：`/reset`、`/new`。 |
| `/rewind` | 倒回到先前某個對話點，或從選定訊息摘要。 | alias：`/checkpoint`。 |
| `/export [filename]` | 將目前對話匯出為純文字。 | 可直接寫入檔案，或開對話框另存。 |
| `/copy [N]` | 複製最近一次或第 `N` 新的 assistant 回應。 | 有 code block 時會開 picker；也能寫入檔案。 |
| `/desktop` | 把目前 session 接到 Claude Code Desktop app。 | macOS / Windows only；alias：`/app`。 |
| `/remote-control` | 讓目前 session 可被 claude.ai 遠端控制。 | alias：`/rc`。 |
| `/schedule [description]` | 建立、更新、列出或執行 Cloud scheduled tasks。 | Claude 會互動式引導設定。 |

### Configuration / Extensibility

| command | 說明 | notes |
|---|---|---|
| `/config` | 開啟 Settings 介面（theme、model、output style 等）。 | alias：`/settings`。 |
| `/theme` | 更換色彩主題。 | 支援 light / dark / daltonized / ANSI themes。 |
| `/color [color|default]` | 設定 prompt bar 顏色。 | 支援 `red`、`blue`、`green`、`yellow`、`purple`、`orange`、`pink`、`cyan`。 |
| `/vim` | 切換 Vim 與 Normal 輸入模式。 | 也可透過 `/config` 永久設定。 |
| `/terminal-setup` | 設定 terminal keybindings（如 `Shift+Enter`）。 | 僅在需要設定的 terminal 中顯示。 |
| `/keybindings` | 開啟或建立 keybindings 設定檔。 | 自訂快捷鍵入口。 |
| `/mcp` | 管理 MCP server 設定與 OAuth 認證。 | 包含 MCP prompts 與 server 狀態。 |
| `/memory` | 編輯 `CLAUDE.md` 記憶檔，啟用 / 停用 auto-memory，並檢視 auto-memory 條目。 | 管理跨 session 的持久記憶。 |
| `/hooks` | 檢視 tool 事件的 hook 設定。 | 確認自動化 hook 規則。 |
| `/skills` | 列出可用的 skills。 | 確認已載入的 skill 清單。 |
| `/plugin` | 管理 plugins 與 marketplace。 | 安裝、更新、列出與移除 plugin。 |
| `/reload-plugins` | 重新載入所有 active plugins。 | 不重開 CLI 也能套用變更。 |
| `/remote-env` | 設定 `--remote` 啟動 web session 的預設遠端環境。 | 用於 Claude Code on the web。 |
| `/statusline` | 設定 Claude Code 的 status line。 | 可描述需求，或不帶參數自動設定。 |

### Help / Account / Lifecycle

| command | 說明 | notes |
|---|---|---|
| `/help` | 顯示互動模式指令說明。 | **最準的即時指令清單入口。** |
| `/release-notes` | 顯示完整 changelog，最新版本優先。 | 可快速查看近期變更。 |
| `/stats` | 視覺化每日使用量、session 歷史、連續使用紀錄與模型偏好。 | 了解個人使用模式。 |
| `/usage` | 顯示方案使用限制與 rate limit 狀態。 | 確認剩餘配額。 |
| `/cost` | 顯示 token 使用量統計。 | 成本追蹤。 |
| `/status` | 開啟 Settings 介面（Status 頁），顯示版本、模型、帳號、連線狀態。 | 可在 Claude 回應途中直接查看。 |
| `/feedback [report]` | 提交 Claude Code 回饋。 | alias：`/bug`。 |
| `/login` | 登入 Anthropic 帳號。 | 首次使用或 token 失效時。 |
| `/logout` | 登出 Anthropic 帳號。 | 切換帳號或清理憑證。 |
| `/mobile` | 顯示下載 Claude mobile app 的 QR code。 | aliases：`/ios`、`/android`。 |
| `/voice` | 切換 push-to-talk voice dictation。 | 需要 Claude.ai account。 |
| `/extra-usage` | 設定額外用量，避免 hit rate limits 後中斷。 | 依方案可見性而定。 |
| `/passes` | 分享一週免費 Claude Code 給朋友。 | 僅對符合資格的帳號顯示。 |
| `/privacy-settings` | 檢視或更新隱私設定。 | Pro / Max 方案限定。 |
| `/stickers` | 索取 Claude Code stickers。 | 周邊入口。 |
| `/upgrade` | 開啟升級頁面。 | 方案升級入口。 |
| `/exit` | 離開 CLI。 | alias：`/quit`。 |

[返回開頭](#快速導覽)

## 內建 Skills

Bundled skills 隨 Claude Code 出貨，是 prompt-based 的指令，可協調工具使用、產生平行 agents、讀取檔案。呼叫方式與一般 slash commands 相同，直接輸入 `/skill-name` 即可。

| skill | 說明 | notes |
|---|---|---|
| `/batch <instruction>` | 大規模平行改動：分析程式碼、拆解為 5–30 個獨立單元並展示計畫，再對每個單元產生獨立 git worktree 的背景 agent，各自實作、測試並開 PR。 | 需要 git repo。 |
| `/claude-api` | 載入 Claude API 與 Agent SDK 參考資料，涵蓋多語言 SDK、tool use、streaming、batches、structured outputs 與常見陷阱。 | 匯入 `anthropic`、`@anthropic-ai/sdk`、`claude_agent_sdk` 時也可能自動啟用。 |
| `/debug [description]` | 讀取 session debug log 進行自我除錯。可選擇性描述問題以聚焦分析。 | 互動模式異常時的首選指令。 |
| `/loop [interval] <prompt>` | 以固定間隔重複執行 prompt，直到 session 結束。 | 適合輪詢部署或追蹤 PR，例如 `/loop 5m check deploy status`。 |
| `/simplify [focus]` | 複查最近修改的檔案，找出程式碼重用、品質、效率問題並修正。 | 同時會產生多個 review agents 並行處理。 |

[返回開頭](#快速導覽)

## 互動式特殊功能

### 輸入前綴

| 前綴 | 行為 |
|---|---|
| `/` 開頭 | 觸發指令或 skill。 |
| `!` 開頭 | Bash mode：直接執行 shell 指令，並將輸出加入對話 context。 |
| `@` | 觸發檔案路徑自動補全。 |

### 鍵盤快捷鍵

**一般控制**

| 快捷鍵 | 說明 |
|---|---|
| `Ctrl+C` | 取消目前輸入或生成中的回應。 |
| `Ctrl+X Ctrl+K` | 終止所有背景 agents；3 秒內連按兩次確認。 |
| `Ctrl+D` | 退出 Claude Code session。 |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | 在預設文字編輯器中開啟目前 prompt。 |
| `Ctrl+L` | 清除 terminal 畫面（保留對話歷史）。 |
| `Ctrl+O` | 切換 verbose 輸出模式。 | 
| `Ctrl+R` | 反向搜尋指令歷史。 |
| `Ctrl+V` / `Cmd+V`（iTerm2）/ `Alt+V`（Windows） | 從剪貼簿貼上圖片。 |
| `Ctrl+B` | 將執行中的任務移至背景（Tmux 使用者按兩次）。 |
| `Ctrl+T` | 切換 terminal status 區域的 task list 顯示。 |
| `Shift+Tab` / `Alt+M` | 在 `default`、`acceptEdits`、`plan` 與已啟用的其他 permission modes 間切換。 |
| `Option+P` / `Alt+P` | 切換模型，不清除目前 prompt。 |
| `Option+T` / `Alt+T` | 切換 extended thinking 模式（需先執行 `/terminal-setup`）。 |
| `Option+O` / `Alt+O` | 切換 fast mode。 |
| `Esc` + `Esc` | 倒回或從先前訊息摘要。 |
| `↑ / ↓` | 瀏覽指令歷史。 |
| `← / →` | 在 dialog tabs 間切換。 |

**文字編輯**

| 快捷鍵 | 說明 |
|---|---|
| `Ctrl+K` | 刪除到行尾（可貼回）。 |
| `Ctrl+U` | 從游標刪到行首（可貼回）。 |
| `Ctrl+Y` | 貼回刪除的文字。 |
| `Alt+Y`（在 `Ctrl+Y` 之後） | 循環瀏覽貼上歷史。 |
| `Alt+B` | 游標向前移動一個單字。 |
| `Alt+F` | 游標向後移動一個單字。 |

**多行輸入**

| 方式 | 快捷鍵 |
|---|---|
| 通用 | `\` + `Enter` |
| macOS 預設 | `Option+Enter` |
| 支援的 terminal（iTerm2、WezTerm、Ghostty、Kitty） | `Shift+Enter` |
| Line feed | `Ctrl+J` |

[返回開頭](#快速導覽)
