# GitHub Copilot CLI

- 安裝：`npm install -g @github/copilot@latest`
- 更新：`copilot update`，或重新執行 `npm install -g @github/copilot@latest`
- 來源：
  - <https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference>
  - <https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli>

---

## 常用 CLI 參數

> 下面先整理最常用、最容易直接影響工作流的 `CLI flags`。完整參數仍以 `copilot help` 與官方文件為準。

| flag | example | 說明 | scope / risk | notes |
|---|---|---|---|---|
| `-p`, `--prompt=PROMPT` | `copilot -p "Summarize this repo"` | 以單次模式執行 prompt，完成後退出。 | 中 | 適合腳本化或 CI 整合。 |
| `-i`, `--interactive=PROMPT` | `copilot -i "Review this folder"` | 啟動互動模式，並先執行一段 prompt。 | 低 | 適合直接帶著初始上下文進場。 |
| `--agent=AGENT` | `copilot --agent=refactor-agent` | 指定 custom agent。 | 低 | 任務明確時可降低行為漂移。 |
| `--model=MODEL` | `copilot --model=gpt-5.1` | 指定要使用的模型。 | 低 | 可取代互動模式內的 `/model`。 |
| `--continue` | `copilot --continue` | 直接續接最近一次 session。 | 低 | 不會先顯示 session 清單。 |
| `--resume[=SESSION-ID]` | `copilot --resume` | 從既有 session 清單中選擇續接，或直接指定 `SESSION-ID`。 | 低 | 長任務與中斷續跑很實用。 |
| `--allow-all` | `copilot --allow-all` | 一次開啟所有 tools、paths、URLs 權限。 | **高** | 等價於 `--allow-all-tools --allow-all-paths --allow-all-urls`。 |
| `--allow-all-tools` | `copilot --allow-all-tools` | 讓所有 tools 自動執行，不再逐次詢問。 | **高** | 程式化執行時常用，但風險高。 |
| `--allow-tool=TOOL ...` | `copilot --allow-tool write` | 預先允許指定 tool。 | 中 | 可用 quoted comma-separated list。 |
| `--deny-tool=TOOL ...` | `copilot --deny-tool "shell(rm)"` | 預先禁止指定 tool。 | 低 | 適合建立安全護欄。 |
| `--experimental` / `--no-experimental` | `copilot --experimental` | 開啟或關閉 experimental features。 | 中 | 互動模式也可用 `/experimental` 切換。 |
| `--share=PATH` / `--share-gist` | `copilot -p "Summarize" --share=summary.md` | 在 programmatic session 結束後輸出分享檔或 gist。 | 中 | 適合留存執行紀錄。 |
| `--output-format=text\|json` | `copilot -p "Summarize" --output-format=json` | 控制輸出格式。 | 中 | `json` 會輸出 JSONL。 |
| `-s`, `--silent` | `copilot -p "Summarize" --silent` | 只輸出 agent 回應。 | 低 | 常用於 shell script。 |

## CLI 內建指令

| command | example | 說明 | 備註 |
|---|---|---|---|
| `copilot` | `copilot` | 啟動互動式 CLI。 | 預設進入對話式工作流。 |
| `copilot help [topic]` | `copilot help permissions` | 顯示 CLI 說明。 | `topic` 常見值有 `config`、`commands`、`environment`、`logging`、`permissions`。 |
| `copilot init` | `copilot init` | 初始化 repository 的 Copilot custom instructions。 | 會協助建立與 agentic workflow 相關的檔案。 |
| `copilot update` | `copilot update` | 更新 CLI 到最新版本。 | 適合已安裝 CLI 後直接升級。 |
| `copilot version` | `copilot version` | 顯示版本資訊並檢查更新。 | 可快速確認本機版本。 |
| `copilot login` | `copilot login` | 登入 GitHub Copilot。 | 支援指定 `--host HOST`。 |
| `copilot logout` | `copilot logout` | 登出並移除本機憑證。 | 常用於切換帳號或清理環境。 |
| `copilot plugin` | `copilot plugin` | 管理 plugins 與 plugin marketplace。 | 也可在互動模式用 `/plugin`。 |

## 互動式 slash commands

> 以下整理的是目前 GitHub Copilot CLI 內建的 `slash commands`。實際可用清單仍可能隨版本或 feature flag 變動，**最準仍以互動模式輸入 `/help` 為準**。

### Agent / model / subagent

| command | 說明 | notes |
|---|---|---|
| `/agent` | 瀏覽並切換可用 agent。 | 有 custom agents 時特別有用。 |
| `/model`, `/models [MODEL]` | 選擇或直接切換模型。 | `MODEL` 可直接指定目標模型。 |
| `/delegate [PROMPT]` | 把工作委派到 GitHub，建立 AI 生成的 PR。 | 適合要交給 remote workflow 的任務。 |
| `/fleet [PROMPT]` | 啟用平行 subagent 執行。 | 適合可拆分的大型任務。 |
| `/tasks` | 檢視與管理背景 tasks。 | 包含 subagents 與 shell sessions。 |
| `/plan [PROMPT]` | 先做 implementation plan，再開始寫程式。 | 適合需求未定或高風險改動。 |
| `/research` | 進行 deep research。 | 會結合 GitHub search 與 web sources。 |
| `/review [PROMPT]` | 啟動 code review agent 分析變更。 | 偏向 code review workflow。 |

### Code / workspace / tooling

| command | 說明 | notes |
|---|---|---|
| `/ide` | 連接到 IDE workspace。 | 適合和 IDE 工作區同步。 |
| `/diff` | 檢視目前目錄的變更。 | 常用於快速 review。 |
| `/pr` | 操作目前 branch 對應的 pull request。 | 依版本與 GitHub 狀態提供對應功能。 |
| `/lsp [show\|test\|reload\|help] [SERVER-NAME]` | 管理 LSP 設定與狀態。 | 適合確認 code intelligence 狀態。 |
| `/terminal-setup` | 設定 multiline input 支援。 | 讓 `Shift+Enter` / `Ctrl+Enter` 可用。 |
| `/init` | 初始化目前 repository 的 Copilot instructions / agentic features。 | 也可用來關閉 init suggestion。 |

### Permissions / directories

| command | 說明 | notes |
|---|---|---|
| `/allow-all`, `/yolo` | 一次開啟所有權限。 | 包含 tools、paths、URLs；高風險。 |
| `/add-dir PATH` | 新增允許讀取的目錄。 | 當需要跨工作目錄取檔時很常用。 |
| `/list-dirs` | 顯示目前允許讀取的目錄清單。 | 可用於權限稽核。 |
| `/cwd`, `/cd [PATH]` | 顯示或切換目前工作目錄。 | `PATH` 省略時通常顯示目前位置。 |
| `/reset-allowed-tools` | 重設允許的 tools 清單。 | 適合清理暫時性授權。 |

### Session / context / sharing

| command | 說明 | notes |
|---|---|---|
| `/resume [SESSION-ID]` | 切換到其他 session，或直接指定 `SESSION-ID`。 | 與 `--resume` 對應。 |
| `/rename NAME` | 重新命名目前 session。 | 是 `/session rename` 的 alias。 |
| `/context` | 顯示 context window token 使用情況。 | 可視覺化目前上下文負載。 |
| `/usage` | 顯示 session usage metrics。 | 含 duration、premium requests、token usage 等。 |
| `/session [checkpoints [n]\|files\|plan\|rename NAME]` | 顯示 session 資訊與 workspace 摘要。 | 可用 subcommands 深入查看。 |
| `/compact` | 壓縮對話歷史以節省 context。 | 常用於長 session。 |
| `/share [file\|gist] [PATH]` | 將 session 匯出到 Markdown 檔或 GitHub gist。 | 適合留存或分享調查紀錄。 |
| `/copy` | 複製上一個回應到剪貼簿。 | 快速搬運內容時很好用。 |
| `/clear`, `/new` | 清空目前對話歷史。 | 切新任務時常用。 |
| `/restart` | 重啟 CLI，但保留目前 session。 | 適合 CLI 狀態異常時快速恢復。 |

### Extensibility / configuration

| command | 說明 | notes |
|---|---|---|
| `/skills [list\|info\|add\|remove\|reload] [ARGS...]` | 管理 skills。 | 用於增強特定領域能力。 |
| `/mcp [show\|add\|edit\|delete\|disable\|enable] [SERVER-NAME]` | 管理 MCP server 設定。 | 內建 GitHub MCP server 也在此管理。 |
| `/plugin [marketplace\|install\|uninstall\|update\|list] [ARGS...]` | 管理 plugins 與 marketplace。 | 與 `copilot plugin` 對應。 |
| `/theme [show\|set\|list] [auto\|THEME-ID]` | 顯示或切換 CLI theme。 | 適合調整可讀性。 |
| `/experimental [on\|off]` | 顯示或切換 experimental features。 | 會影響可用功能集合。 |
| `/instructions` | 檢視與切換 custom instruction files。 | 用於確認目前載入的 instructions。 |
| `/streamer-mode` | 切換 streamer mode。 | 會隱藏 preview model 名稱與 quota 細節。 |

### Help / account / lifecycle

| command | 說明 | notes |
|---|---|---|
| `/help` | 顯示互動模式指令說明。 | **最準的即時指令清單入口。** |
| `/changelog` | 顯示 CLI changelog。 | 可加 `summarize` 請 AI 摘要。 |
| `/feedback` | 提供 CLI 回饋。 | 可用於 bug report 或 feature request。 |
| `/update` | 更新 CLI 到最新版本。 | 互動模式內直接升級。 |
| `/version` | 顯示版本資訊並檢查更新。 | 適合確認本機狀態。 |
| `/login` | 登入 GitHub Copilot。 | 首次使用或 token 失效時會用到。 |
| `/logout` | 登出 GitHub Copilot。 | 切換帳號或清理憑證時使用。 |
| `/user [show\|list\|switch]` | 管理目前 GitHub 使用者。 | 多帳號場景很實用。 |
| `/exit`, `/quit` | 離開 CLI。 | 正常結束互動 session。 |
