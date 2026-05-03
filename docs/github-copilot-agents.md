# GitHub Copilot CLI Agent 使用指南

## 快速導覽

- [概覽](#概覽)
- [內建與自訂 Agent](#內建與自訂-agent)
- [建立自訂 Agent](#建立自訂-agent)
- [使用 Agent 的方法](#使用-agent-的方法)
- [自訂 Agent 可以做到什麼](#自訂-agent-可以做到什麼)
- [注意事項](#注意事項)
- [參考文件](#參考文件)

## 概覽

GitHub Copilot CLI 既有內建 agent，也支援 custom agents。當你下 prompt 時，主 agent 可能自動把部分工作委派給 subagent；若該任務很符合某個 custom agent 的 `description`，Copilot 也可能直接推斷並使用它。

這份文件聚焦在「如何在 GitHub Copilot CLI 使用 agent」與「如何建立 custom agent profile」。完整 CLI flags、slash commands 與指令列表，請搭配 [GitHub Copilot CLI 參考](../cli-agents/github-copilot/gc-cli.md) 一起看。

[返回開頭](#快速導覽)

## 內建與自訂 Agent

| 類型 | 代表項目 | 典型用途 | 如何啟動 |
|---|---|---|---|
| 內建 agent | `Explore` | 快速 codebase analysis，不污染主 context | Copilot 自動委派 |
| 內建 agent | `Task` | 執行 tests、builds、commands，成功時回短摘要、失敗時回完整輸出 | Copilot 自動委派 |
| 內建 agent | `General-purpose` | 複雜多步驟任務，需要完整工具集與較高品質推理 | Copilot 自動委派 |
| 內建 agent | `Code-review` | 專注找真正重要問題，降低 review 噪音 | Copilot 自動委派或透過 review workflow |
| 自訂 agent | 你在 `.github/agents/` 或 `~/.copilot/agents/` 定義的 `.agent.md` 檔 | 套用特定流程、工具組合、MCP 能力與團隊規範 | `/agent`、明講名稱、推斷、`copilot --agent` |

對 Copilot CLI 來說，custom agent 本質上是 **agent profile**。它用 Markdown + YAML frontmatter 定義「這個 agent 會做什麼、什麼時候該被用到、可以用哪些工具」。真正執行任務時，Copilot 會為它啟動一個獨立 subagent。

[返回開頭](#快速導覽)

## 建立自訂 Agent

### 用 `/agent` 建立

這是 Copilot CLI 內建的互動式入口：

1. 執行 `/agent`
2. 選 **Create new agent**
3. 選擇要放在 project 還是 user scope
   - Project：`.github/agents/`
   - User：`~/.copilot/agents/`
4. 選擇讓 Copilot 幫你產生初稿，或自行手填 profile
5. 選擇這個 agent 可使用的 tools
6. 重新啟動 CLI 讓新 agent 載入

### 手動建立 `.agent.md`

GitHub Copilot CLI 的 custom agent 檔案副檔名是 **`.agent.md`**。最小可用格式如下：

```md
---
name: security-auditor
description: Checks source code for security issues. Use when a security review is requested.
tools: ["read", "search", "edit"]
---

You are a security specialist.

Review the requested files for authentication bypass, injection risks,
exposed secrets, and dependency issues. Report concrete findings first.
```

- `description` 是必填；Copilot 會依它判斷何時自動推斷這個 agent
- `name` 沒填時，預設使用檔名
- Markdown body 是 agent 的行為說明

如果同名 agent 同時存在於 project 與 user scope，**user scope 會覆蓋 project scope**。另外，CLI 用在 `--agent` 的名稱通常就是檔名去掉 `.agent.md` 的結果。

[返回開頭](#快速導覽)

## 使用 Agent 的方法

| 方法 | 範例 | 適用情境 | 強制程度 |
|---|---|---|---|
| `/agent` 選擇 | 在互動模式輸入 `/agent` 後選 agent，再輸入 prompt | 想手動切換到某個 custom agent | 高 |
| 明講 agent 名稱 | `Use the security-auditor agent on all files in the src directory.` | 想直接在 prompt 內要求特定 agent 出手 | 中 |
| 讓 Copilot 推斷 | `Check all TypeScript files under src for security problems.` | agent 的 `description` 已寫得夠明確，希望自動匹配 | 低 |
| CLI flag 指定 | `copilot --agent security-auditor --prompt "Check src/app/auth.ts"` | 腳本化、CI、單次明確任務 | 高 |
| 平行 subagent 工作流 | `/fleet [PROMPT]` | 任務能拆成多個獨立子工作時 | 任務模式 |

內建 agent 與 custom agents 是兩條不同軸線：內建 agent 主要由 Copilot 在背景自動委派，自訂 agent 則是你拿來固定工作方法、團隊規範與工具能力的客製入口。

[返回開頭](#快速導覽)

## 自訂 Agent 可以做到什麼

GitHub Copilot CLI 的 custom agent 偏向「專家 persona + tool profile」。可調整能力比 Claude Code 少一些，但已足夠覆蓋大多數工作流標準化需求：

| 能力 | 對應欄位 | 能做的事 |
|---|---|---|
| 工作定位 | `description` | 定義 agent 擅長什麼，以及什麼情境應該被推斷使用 |
| 顯示名稱 | `name` | 自訂下拉清單與介面顯示名稱 |
| 工具邊界 | `tools` | 限制只能 `read` / `search`，或允許 `edit`、特定 MCP tools |
| 模型 | `model` | 指定這個 agent 執行時要用的模型 |
| 自動/手動可見性 | `disable-model-invocation`、`user-invocable` | 控制是否允許 Copilot 自動推斷它、是否能讓使用者手動選它 |
| 環境範圍 | `target` | 只在 `github-copilot` 或 `vscode` 等特定環境啟用 |
| 外部能力 | `mcp-servers` | 為該 agent 額外掛上 MCP servers 與其工具 |
| 附加資訊 | `metadata` | 補充標註用的 key/value 資訊 |

實務上，這類 agent 很適合拿來做：

1. 固定 code review 檢查表
2. 固定 test writer / planner / security auditor 角色
3. 只准用唯讀工具的分析 agent
4. 綁定特定 MCP server 的 domain agent

相較之下，Copilot CLI 的 agent profile **沒有** Claude Code 那種 `hooks`、`memory`、`background`、`worktree isolation` 這類更像 runtime orchestration 的欄位；它更偏向把工作方式與工具邊界預先定義好。

[返回開頭](#快速導覽)

## 注意事項

1. 建完新的 `.agent.md` 後，CLI 需要重新啟動才會載入新 agent。
2. `description` 寫得越具體，Copilot 越容易正確推斷何時應該使用這個 agent。
3. 若你希望某 agent 只能手動選，不要被模型主動推斷，可設定 `disable-model-invocation: true`。
4. 若你只想提供一小部分 MCP 工具給 agent，請在 `tools` 中精確列出 `server-name/tool-name`，不要直接全開。

[返回開頭](#快速導覽)

## 參考文件

- [GitHub Copilot CLI 參考](../cli-agents/github-copilot/gc-cli.md)
- [GitHub Docs：Creating and using custom agents for GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-custom-agents-for-cli)
- [GitHub Docs：Custom agents configuration](https://docs.github.com/en/copilot/reference/custom-agents-configuration)
- [GitHub Docs：Using GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli)

[返回開頭](#快速導覽)
