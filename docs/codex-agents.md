# Codex Agent 使用指南

## 快速導覽

- [概覽](#概覽)
- [內建與自訂 Agent](#內建與自訂-agent)
- [建立自訂 Agent](#建立自訂-agent)
- [使用 Agent 的方法](#使用-agent-的方法)
- [AGENTS.md 與 Custom Agent 的差異](#agentsmd-與-custom-agent-的差異)
- [自訂 Agent 可以做到什麼](#自訂-agent-可以做到什麼)
- [注意事項](#注意事項)
- [參考文件](#參考文件)

## 概覽

Codex 官方把這套能力主要稱為 **subagents**。主 agent 不會自動亂開平行 agent；**只有你明確要求「spawn / delegate / one agent per ...」時，Codex 才會真的派出 subagent**。

這份文件聚焦在兩件事：

1. **怎麼在 Codex CLI 使用 subagent / custom agent**
2. **`AGENTS.md` 在 Codex 裡到底扮演什麼角色**

如果你要查完整 CLI flags、slash commands、sandbox / approval 與 TUI 操作，請先搭配 [Codex CLI 參考](../cli-agents/codex/codex-cli.md) 一起看。

[返回開頭](#快速導覽)

## 內建與自訂 Agent

| 類型 | 代表項目 | 典型用途 | 如何啟動 |
|---|---|---|---|
| 內建 agent | `default` | 一般用途 fallback agent | 主 agent 依需求派出 |
| 內建 agent | `worker` | 偏執行導向的實作、修正、命令工作 | 你明確要求 subagent delegation 時 |
| 內建 agent | `explorer` | 偏唯讀的 codebase exploration、蒐證、整理 | 你要求探索 / 平行分析時 |
| 自訂 agent | 你在 `.codex/agents/` 或 `~/.codex/agents/` 放的 `*.toml` 檔 | 特定角色、模型、sandbox、MCP、instructions 的專用 worker | 在 prompt 裡明確要求，或讓 Codex 依 `description` 選擇 |

幾個關鍵行為：

1. **subagent workflow 預設已啟用**，但不代表會自動亂派工；Codex 仍要求你明確指示。
2. **subagents 會繼承父 agent 的 sandbox 與 approval 狀態**；如果你在 session 中途改過權限，child agent 也會沿用。
3. 如果 custom agent 名稱和 built-in agent 同名，例如你自己也叫 `explorer`，**你的 custom agent 會覆蓋 built-in agent**。

[返回開頭](#快速導覽)

## 建立自訂 Agent

### 放置位置

Codex 的 custom agents 不是 Markdown manifest，而是 **單一 TOML 檔一個 agent**：

- User scope：`~/.codex/agents/`
- Project scope：`.codex/agents/`

每個檔案定義一個 agent。最穩的命名方式是「檔名 = agent name」，但真正的 source of truth 還是 TOML 裡的 `name` 欄位。

### 最小可用格式

官方要求每個 custom agent 檔至少有這三個欄位：

- `name`
- `description`
- `developer_instructions`

最小範例如下：

```toml
name = "reviewer"
description = "PR reviewer focused on correctness, security, and missing tests."
developer_instructions = """
Review code like an owner.
Prioritize correctness, security, behavior regressions, and missing test coverage.
Lead with concrete findings and avoid style-only comments.
"""
```

### 常見進階欄位

這些欄位沒寫時，多半繼承父 session：

```toml
name = "docs_researcher"
description = "Documentation specialist that verifies APIs and framework behavior."
model = "gpt-5.4-mini"
model_reasoning_effort = "medium"
sandbox_mode = "read-only"
nickname_candidates = ["Atlas", "Delta", "Echo"]
developer_instructions = """
Use MCP docs sources to confirm API behavior.
Return concise answers with links or exact references.
Do not make code changes.
"""

[mcp_servers.openaiDeveloperDocs]
url = "https://developers.openai.com/mcp"
```

可常見覆蓋的欄位包括：

- `model`
- `model_reasoning_effort`
- `sandbox_mode`
- `mcp_servers`
- `skills.config`
- `nickname_candidates`

### 全域 subagent 設定

若你要控制整體 subagent fan-out 行為，改的是 `config.toml` 裡的 `[agents]`，不是個別 agent 檔：

```toml
[agents]
max_threads = 6
max_depth = 1
job_max_runtime_seconds = 1800
```

- `max_threads`：同時可開的 agent thread 上限
- `max_depth`：允許遞迴派工的深度；預設 `1`
- `job_max_runtime_seconds`：CSV fan-out worker 的預設 timeout

[返回開頭](#快速導覽)

## 使用 Agent 的方法

| 方法 | 範例 | 適用情境 | 強制程度 |
|---|---|---|---|
| 明確要求平行派工 | `Spawn one subagent per review category, wait for all of them, then summarize the findings.` | 任務天然可拆成多個獨立子工作 | 高 |
| 指定 agent 名稱 | `Use the reviewer agent to inspect this branch against main.` | 你已經定義好 custom agent，想明確點名 | 高 |
| 指定分工方式 | `Have pr_explorer map the code paths, reviewer find real risks, and docs_researcher verify the APIs.` | 想讓多個 custom agents 各司其職 | 高 |
| `/agent` 切換 thread | 在 CLI 輸入 `/agent` | 想查看或切回已開出的 agent thread | 執行中控制 |
| 讓 Codex 依 `description` 選擇 | `Review this branch for correctness and test gaps.` | 已有客製 agent，但你不想每次手動點名 | 中 |

一個好的 subagent prompt，至少要交代三件事：

1. **怎麼拆工作**
2. **要不要等全部 agent 完成**
3. **最後回來時要整理成什麼格式**

官方示例的精神大概像這樣：

```text
Review this branch with parallel subagents.
Spawn one subagent for security risks, one for test gaps, and one for maintainability.
Wait for all three, then summarize the findings by category with file references.
```

[返回開頭](#快速導覽)

## AGENTS.md 與 Custom Agent 的差異

這兩個東西名字很像，但角色完全不同：

| 項目 | `AGENTS.md` | Custom agent (`.codex/agents/*.toml`) |
|---|---|---|
| 本質 | 持久化專案指引 / custom instructions | 專門角色化的 subagent 設定 |
| 作用對象 | 整個 session / 專案 | 某一種被派出的 agent |
| 典型內容 | build / test 指令、repo 慣例、目錄路由、review 規則 | 模型、sandbox、MCP、agent 專用 instructions |
| 載入方式 | 開 session 時由近到遠分層讀入 | 只有被當成 subagent 使用時才套用 |
| 適合放什麼 | 「改 JS 後要跑 `npm test`」 | 「這個 reviewer 一律 read-only，高推理」 |

簡單講：

- **`AGENTS.md` 是整個 repo 的長期工作守則**
- **custom agent 是某個專職 worker 的 profile**

### `AGENTS.md` 的 discovery 規則

Codex 啟動時會組 instruction chain，順序如下：

1. Global：`~/.codex/AGENTS.override.md` 優先，否則 `~/.codex/AGENTS.md`
2. Project：從 project root 一路走到目前工作目錄；每層最多取一份，優先 `AGENTS.override.md`，再來 `AGENTS.md`
3. Merge：由淺到深串接，**越靠近目前工作目錄的指引越晚出現，因此覆蓋前面的規則**

幾個重要細節：

- 空檔案會被忽略
- 合併總大小預設受 `project_doc_max_bytes` 限制（預設 32 KiB）
- 可用 `project_doc_fallback_filenames` 加入其他替代檔名
- `CODEX_HOME` 會改變 global `AGENTS.md` 的根位置

所以在 Codex 生態裡，`AGENTS.md` 比較接近 **persistent repo guidance**，不是 agent manifest。

[返回開頭](#快速導覽)

## 自訂 Agent 可以做到什麼

Codex 的 custom agent 本質上是一層 **session config overlay**。它不是單純 persona，而是可以直接覆蓋 session 執行設定：

| 能力 | 對應欄位 / 機制 | 能做的事 |
|---|---|---|
| 角色定位 | `description` | 告訴 Codex 這個 agent 何時該出場 |
| 核心行為 | `developer_instructions` | 定義 agent 的工作方法與輸出習慣 |
| 模型選擇 | `model`、`model_reasoning_effort` | reviewer 用高推理、explorer 用 mini model |
| 安全邊界 | `sandbox_mode` | 讓某個 agent 永遠只讀，或只在特定 sandbox 下運作 |
| MCP 能力 | `mcp_servers` | 專門綁 docs server、GitHub、內部系統等 |
| 技能掛載 | `skills.config` | 為 agent 預先接上 skill 設定 |
| 顯示名稱 | `nickname_candidates` | 大量平行 agent 時讓 thread label 比較好辨識 |
| 全域派工控制 | `[agents]` | 限制 fan-out 深度、同時執行數量與 job timeout |

實務上很適合做的角色包括：

1. **read-only reviewer**：只讀 diff，專找 correctness / security / missing tests
2. **code mapper / explorer**：快速掃 code path，不負責修改
3. **docs researcher**：只負責查官方文件與 MCP docs server
4. **worker**：專門實作或修 bug，但限制在特定 sandbox

這套設計的優點是：**把 noisy work 從主 thread 拆出去，主對話只保留需求、決策與最後摘要**。官方文件把這件事稱作避免 `context pollution` 與 `context rot`。

[返回開頭](#快速導覽)

## 注意事項

1. **Codex 不會自己偷偷開 subagent**：要明確要求 `spawn`、`delegate`、`one agent per ...` 這類語句。
2. **subagents 比單 agent 更耗 tokens**：每個 child agent 都有自己的 model / tool work。
3. **平行唯讀工作最穩**：探索、triage、review、summarization 很適合；平行寫 code 容易衝突。
4. **`/agent` 是 thread 管理，不是 agent 建立精靈**：建立 custom agent 主要還是手寫 TOML。
5. **`AGENTS.md` 不是 custom agent 定義檔**：它是全域 / 專案指引，兩者用途不要混。
6. **approval request 可能來自背景 agent thread**：在互動模式下，即使你現在看的是主 thread，也可能跳出 child thread 的 approval overlay。

[返回開頭](#快速導覽)

## 參考文件

- [Codex CLI 參考](../cli-agents/codex/codex-cli.md)
- [OpenAI Developers：Subagents](https://developers.openai.com/codex/subagents)
- [OpenAI Developers：Subagent concepts](https://developers.openai.com/codex/concepts/subagents)
- [OpenAI Developers：Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md)
- [OpenAI Developers：Customization](https://developers.openai.com/codex/concepts/customization)
- [OpenAI Developers：Config basics](https://developers.openai.com/codex/config-basic)
- [OpenAI Developers：Advanced config](https://developers.openai.com/codex/config-advanced)

[返回開頭](#快速導覽)
