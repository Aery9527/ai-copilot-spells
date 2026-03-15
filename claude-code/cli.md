# Claude Code CLI

- 安裝：`npm install -g @anthropic-ai/claude-code`
- 更新：`claude update`，或重新執行 `npm install -g @anthropic-ai/claude-code`
- 來源：
  - <https://docs.anthropic.com/en/docs/claude-code/cli-reference>
  - <https://docs.anthropic.com/en/docs/claude-code/slash-commands>
- 在 prompt 中加入 `ultrathink`（或 `think`、`think hard`、`think harder`）可觸發不同深度的推理模式。也可使用 `Alt+T` 直接切換。

---

## 常用 CLI 參數

> 下面先整理最常用、最容易直接影響工作流的 `CLI flags`。完整參數仍以 `claude --help` 與官方文件為準。

### Session 與對話

| flag | example | 說明 | scope / risk | notes |
|---|---|---|---|---|
| `-c`, `--continue` | `claude -c` | 載入目前目錄最近一次的對話並繼續。 | 低 | 快速接回上次工作。 |
| `-r`, `--resume[=SESSION]` | `claude -r "auth-refactor"` | 以 ID 或名稱恢復特定 session，或開啟互動選擇器。 | 低 | 長任務中斷後續跑很實用。 |
| `--fork-session` | `claude -r abc123 --fork-session` | 恢復時建立新 session ID，不覆蓋原本紀錄。 | 低 | 要在舊 session 分叉時使用。 |
| `-n`, `--name=NAME` | `claude -n "my-feature"` | 為本次 session 設定顯示名稱。 | 低 | 會顯示在 `/resume` 清單與 terminal 標題。 |
| `--no-session-persistence` | `claude -p --no-session-persistence "query"` | 停用 session 持久化（僅 print 模式）。 | 低 | 一次性腳本常用。 |

### 模型與輸出

| flag | example | 說明 | scope / risk | notes |
|---|---|---|---|---|
| `--model=MODEL` | `claude --model claude-sonnet-4-6` | 指定模型，可用 alias（`sonnet`、`opus`）或完整名稱。 | 低 | 可取代互動模式內的 `/model`。 |
| `--effort=LEVEL` | `claude --effort high` | 設定推理強度：`low`、`medium`、`high`、`max`（僅 Opus 4.6）。 | 低 | `max` 僅限本次 session。 |
| `-p`, `--print` | `claude -p "query"` | Print 模式：執行後直接退出，不進入互動介面。 | 中 | 適合腳本化或 CI 整合。 |
| `--output-format=FORMAT` | `claude -p "query" --output-format=json` | 控制輸出格式：`text`、`json`、`stream-json`（僅 print 模式）。 | 中 | `json` 會輸出 JSONL。 |
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
| `--allowedTools=LIST` | `--allowedTools "Bash(git log *)"` | 指定可自動執行（不逐次詢問）的 tools。 | 高 | 支援 permission rule 語法。日常作業推薦：`--allowedTools "Bash(git *),Edit,Write,Read,Glob,Grep"`（比 `--dangerously-skip-permissions` 更安全，Bash 非 git 指令仍會詢問）。 |
| `--disallowedTools=LIST` | `--disallowedTools "Edit"` | 從 model context 完全移除指定 tools。 | 中 | 建立安全護欄。 |
| `--permission-mode=MODE` | `claude --permission-mode plan` | 以指定 permission mode 啟動（例如 `plan`）。 | 中 | 可搭配 `--allow-dangerously-skip-permissions`。 |
| `--dangerously-skip-permissions` | `claude --dangerously-skip-permissions` | 跳過所有權限提示。 | **極高** | 極度謹慎使用。 |

### Workspace 與目錄

| flag | example | 說明 | scope / risk | notes |
|---|---|---|---|---|
| `--add-dir=PATH` | `claude --add-dir ../apps ../lib` | 新增 Claude 可存取的額外工作目錄（會驗證路徑是否存在）。 | 低 | 跨目錄作業時實用。 |
| `-w`, `--worktree[=NAME]` | `claude -w feature-auth` | 在 `<repo>/.claude/worktrees/<name>` 建立隔離的 git worktree session。 | 中 | 省略名稱時自動生成。 |

### MCP 與 Plugin

| flag | example | 說明 | scope / risk | notes |
|---|---|---|---|---|
| `--mcp-config=PATH` | `claude --mcp-config ./mcp.json` | 從 JSON 檔或字串載入 MCP servers（空白分隔可多個）。 | 低 | 快速掛載外部工具。 |
| `--strict-mcp-config` | `claude --strict-mcp-config --mcp-config ./mcp.json` | 只使用 `--mcp-config` 指定的 MCP，忽略其他設定。 | 中 | 乾淨的隔離環境。 |
| `--plugin-dir=PATH` | `claude --plugin-dir ./my-plugins` | 僅本次 session 從指定目錄載入 plugins。可重複使用多個路徑。 | 低 | 臨時試驗 plugin 時方便。 |

### 其他常用

| flag | example | 說明 | scope / risk |
|---|---|---|---|
| `--agent=AGENT` | `claude --agent my-agent` | 指定本次 session 使用的 agent（覆蓋 `agent` 設定）。 | 低 |
| `--debug[=CATEGORY]` | `claude --debug "api,mcp"` | 啟用 debug 模式，可選擇性過濾類別。 | 低 |
| `-v`, `--version` | `claude --version` | 顯示版本號。 | 低 |
| `--help` | `claude --help` | 顯示說明。 | 低 |

---

## CLI 內建指令

| command | example | 說明 | 備註 |
|---|---|---|---|
| `claude` | `claude` | 啟動互動式 CLI。 | 預設進入對話式工作流。 |
| `claude "query"` | `claude "explain this repo"` | 帶初始 prompt 啟動互動 session。 | 適合快速帶著脈絡進場。 |
| `claude -p "query"` | `claude -p "summarize this file"` | Print 模式，回應後退出。 | 腳本化與 CI 整合常用。 |
| `claude update` | `claude update` | 更新 CLI 到最新版本。 | 等同重新安裝最新版。 |
| `claude auth login` | `claude auth login --email user@example.com` | 登入 Anthropic 帳號。支援 `--email` 與 `--sso`。 | 首次使用或 token 失效時。 |
| `claude auth logout` | `claude auth logout` | 登出並移除本機憑證。 | 切換帳號或清理環境。 |
| `claude auth status` | `claude auth status` | 顯示認證狀態（JSON 格式，加 `--text` 為人類可讀）。 | 登入回傳 0；未登入回傳 1。 |
| `claude agents` | `claude agents` | 列出所有已設定的 subagents，依來源分組。 | 確認可用 agent 清單。 |
| `claude mcp` | `claude mcp` | 管理 MCP server 設定。 | 詳見 MCP 文件。 |

---

## 互動式 slash commands

> 以下整理的是目前 Claude Code CLI 內建的 `slash commands`。實際可用清單仍可能隨版本或 feature flag 變動，**最準仍以互動模式輸入 `/help` 為準**。

### Agent / 模型 / 任務

| command | 說明 | notes |
|---|---|---|
| `/model [MODEL]` | 選擇或直接切換模型，方向鍵可調整 effort level。 | 立即生效。 |
| `/effort [low\|medium\|high\|max\|auto]` | 設定推理強度。`max` 僅本次 session，`auto` 重設為預設值。 | 僅 Opus 4.6 支援 `max`。 |
| `/agents` | 管理 agent 設定。 | 確認可用 agent 清單。 |
| `/tasks` | 列出並管理背景任務。 | 含 subagents 與 shell sessions。 |
| `/plan` | 直接進入 plan mode。 | 適合高風險改動前先規劃。 |
| `/fast [on\|off]` | 切換 fast mode。 | 快速回應場景。 |

### Code / Workspace / Tooling

| command | 說明 | notes |
|---|---|---|
| `/init` | 初始化 `CLAUDE.md` project guide。 | 為 agentic workflow 建立說明文件。 |
| `/diff` | 開啟互動式 diff 檢視器，顯示未提交變更與逐 turn 差異。 | 方向鍵切換 git diff 與各 turn 差異。 |
| `/ide` | 管理 IDE 整合並顯示連線狀態。 | 與 VS Code、JetBrains 等整合。 |
| `/security-review` | 分析目前 branch 待提交的變更，找出安全漏洞。 | 涵蓋 injection、auth、data exposure 等。 |
| `/pr-comments [PR]` | 取得 GitHub PR 的留言。自動偵測當前 branch 的 PR，或手動指定 URL/編號。 | 需要 `gh` CLI。 |
| `/install-github-app` | 為 repository 設定 Claude GitHub Actions app。 | GitHub Actions 整合入口。 |
| `/doctor` | 診斷並驗證 Claude Code 安裝與設定。 | 排查環境問題的第一步。 |

### Permissions / Directories

| command | 說明 | notes |
|---|---|---|
| `/add-dir PATH` | 新增允許存取的目錄到目前 session。 | 跨工作目錄取檔時常用。 |
| `/permissions` | 檢視或更新 permissions。 | alias：`/allowed-tools`。 |
| `/sandbox` | 切換 sandbox 模式（視平台支援）。 | 隔離執行環境。 |

### Session / Context / Sharing

| command | 說明 | notes |
|---|---|---|
| `/resume [SESSION]` | 切換到其他 session，或直接指定 `SESSION-ID`。 | alias：`/continue`。 |
| `/fork [name]` | 在目前對話點建立分叉 session。 | 保留原 session 繼續分支探索。 |
| `/rename [NAME]` | 重新命名目前 session。省略名稱時自動從對話歷史產生。 | 整理多 session 時實用。 |
| `/context` | 以彩色格子視覺化目前 context window 使用量。 | 顯示優化建議與容量警告。 |
| `/compact [instructions]` | 壓縮對話歷史以節省 context，可加入保留重點的指示。 | 長 session 常用。 |
| `/clear` | 清空目前對話歷史。 | alias：`/reset`、`/new`。 |
| `/rewind` | 倒回到先前某個對話點，或從選定訊息摘要。 | alias：`/checkpoint`。 |
| `/export [filename]` | 將目前對話匯出為純文字。指定 filename 寫入檔案；否則開啟對話框。 | 留存調查紀錄。 |
| `/share [file\|gist] [PATH]` | 同上，但可匯出到 GitHub gist。 | 適合分享紀錄。 |
| `/copy` | 複製上一個回應到剪貼簿。有 code block 時顯示選擇器。 | 快速搬運內容。 |

### Configuration / Extensibility

| command | 說明 | notes |
|---|---|---|
| `/config` | 開啟 Settings 介面（theme、model、output style 等）。 | alias：`/settings`。 |
| `/theme` | 更換色彩主題（light/dark、colorblind、ANSI 等）。 | 調整可讀性。 |
| `/color [COLOR\|default]` | 設定 prompt bar 顏色。選項：`red`、`blue`、`green`、`yellow`、`purple`、`orange`、`pink`、`cyan`。 | `default` 重設。 |
| `/vim` | 切換 Vim 與 Normal 輸入模式。 | 也可透過 `/config` 永久設定。 |
| `/terminal-setup` | 設定 terminal keybindings（如 Shift+Enter）。 | 僅在需要設定的 terminal 中顯示。 |
| `/keybindings` | 開啟或建立 keybindings 設定檔。 | 自訂快捷鍵入口。 |
| `/mcp [show\|add\|edit\|delete\|disable\|enable] [SERVER]` | 管理 MCP server 設定與 OAuth 認證。 | 包含內建 GitHub MCP server。 |
| `/memory` | 編輯 `CLAUDE.md` 記憶檔，啟用/停用 auto-memory，並檢視 auto-memory 條目。 | 管理跨 session 的持久記憶。 |
| `/instructions` | 檢視目前載入的 custom instruction files。 | 確認 instruction 狀態。 |
| `/hooks` | 檢視 tool 事件的 hook 設定。 | 確認自動化 hook 規則。 |
| `/skills` | 列出可用的 skills。 | 確認已載入的 skill 清單。 |
| `/plugin [marketplace\|install\|uninstall\|update\|list] [ARGS...]` | 管理 plugins 與 marketplace。 | 擴充 CLI 功能。 |
| `/experimental [on\|off]` | 顯示或切換 experimental features。 | 會影響可用功能集合。 |
| `/statusline` | 設定 Claude Code 的 status line。可描述需求，或不帶參數自動設定。 | 自訂 terminal status 顯示。 |

### Help / Account / Lifecycle

| command | 說明 | notes |
|---|---|---|
| `/help` | 顯示互動模式指令說明。 | **最準的即時指令清單入口。** |
| `/release-notes` | 顯示完整 changelog，最新版本優先。 | alias 參考：`/changelog`。 |
| `/stats` | 視覺化每日使用量、session 歷史、連續使用紀錄與模型偏好。 | 了解個人使用模式。 |
| `/usage` | 顯示方案使用限制與 rate limit 狀態。 | 確認剩餘配額。 |
| `/cost` | 顯示 token 使用量統計。 | 成本追蹤。 |
| `/status` | 開啟 Settings 介面（Status 頁），顯示版本、模型、帳號、連線狀態。 | 快速確認本機狀態。 |
| `/feedback [report]` | 提交 Claude Code 回饋。 | alias：`/bug`。 |
| `/login` | 登入 Anthropic 帳號。 | 首次使用或 token 失效時。 |
| `/logout` | 登出 Anthropic 帳號。 | 切換帳號或清理憑證。 |
| `/update` | 更新 CLI 到最新版本。 | 互動模式內直接升級。 |
| `/version` | 顯示版本資訊並檢查更新。 | 確認本機狀態。 |
| `/exit` | 離開 CLI。 | alias：`/quit`。 |

---

## 內建 Skills（以 `/` 呼叫）

Bundled skills 隨 Claude Code 出貨，是 prompt-based 的指令，可協調工具使用、產生平行 agents、讀取檔案。

| skill | 說明 | notes |
|---|---|---|
| `/batch <instruction>` | 大規模平行改動：分析程式碼、拆解為 5–30 個獨立單元並展示計畫，再對每個單元產生獨立 git worktree 的背景 agent，各自實作、測試並開 PR。 | 需要 git repo。 |
| `/simplify [focus]` | 複查最近修改的檔案，找出程式碼重用、品質、效率問題並修正。同時產生三個 review agents 並行處理。 | 可加文字聚焦方向，如 `/simplify focus on memory efficiency`。 |
| `/loop [interval] <prompt>` | 以固定間隔重複執行 prompt，直到 session 結束。 | 適合輪詢部署或追蹤 PR，例如 `/loop 5m check deploy status`。 |
| `/debug [description]` | 讀取 session debug log 進行自我除錯。可選擇性描述問題以聚焦分析。 | 互動模式異常時的首選指令。 |

---

## 互動式特殊功能

### 輸入前綴

| 前綴 | 行為 |
|---|---|
| `/` 開頭 | 觸發指令或 skill。 |
| `!` 開頭 | Bash 模式：直接執行 shell 指令，並將輸出加入對話 context。 |
| `@` | 觸發檔案路徑自動補全。 |

### 鍵盤快捷鍵

**一般控制**

| 快捷鍵 | 說明 |
|---|---|
| `Ctrl+C` | 取消目前輸入或生成中的回應。 |
| `Ctrl+D` | 退出 Claude Code session。 |
| `Ctrl+L` | 清除 terminal 畫面（保留對話歷史）。 |
| `Ctrl+O` | 切換 verbose 輸出模式。 |
| `Ctrl+R` | 反向搜尋指令歷史。 |
| `Ctrl+G` | 在預設文字編輯器中開啟目前 prompt。 |
| `Ctrl+V` / `Cmd+V` / `Alt+V` | 從剪貼簿貼上圖片。 |
| `Ctrl+B` | 將執行中的任務移至背景（Tmux 使用者按兩次）。 |
| `Ctrl+F` | 終止所有背景 agents（3 秒內按兩次確認）。 |
| `Ctrl+T` | 切換 terminal status 區域的任務清單顯示。 |
| `Shift+Tab` / `Alt+M` | 切換 permission mode（Auto-Accept、Plan、Normal）。 |
| `Option+P` / `Alt+P` | 切換模型，不清除目前 prompt。 |
| `Option+T` / `Alt+T` | 切換 extended thinking 模式（需先執行 `/terminal-setup`）。 |
| `Esc` + `Esc` | 倒回或從先前訊息摘要。 |
| `↑ / ↓` | 瀏覽指令歷史。 |
| `← / →` | 在 dialog tabs 間切換。 |
| `?` | 顯示目前環境可用的快捷鍵清單。 |

**文字編輯**

| 快捷鍵 | 說明 |
|---|---|
| `Ctrl+K` | 刪除到行尾（可貼回）。 |
| `Ctrl+U` | 刪除整行（可貼回）。 |
| `Ctrl+Y` | 貼回刪除的文字。 |
| `Alt+Y`（在 Ctrl+Y 之後）| 循環瀏覽貼上歷史。 |
| `Alt+B` | 游標向前移動一個單字。 |
| `Alt+F` | 游標向後移動一個單字。 |

**多行輸入**

| 方式 | 快捷鍵 |
|---|---|
| 通用 | `\` + `Enter` |
| macOS 預設 | `Option+Enter` |
| 支援的 terminal（iTerm2、WezTerm、Ghostty、Kitty） | `Shift+Enter` |
| Line feed | `Ctrl+J` |
