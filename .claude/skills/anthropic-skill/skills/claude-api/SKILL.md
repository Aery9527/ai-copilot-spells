---
name: claude-api
description: "Build apps with the Claude API or Anthropic SDK. TRIGGER when: code imports `anthropic`/`@anthropic-ai/sdk`/`claude_agent_sdk`, or user asks to use Claude API, Anthropic SDKs, or Agent SDK. DO NOT TRIGGER when: code imports `openai`/other AI SDK, general programming, or ML/data-science tasks."
source: anthropic-skills/skills/claude-api/SKILL.md
---

## 概述

這個 skill 用來協助開發者以 Claude API 或 Anthropic SDK 建構 LLM 應用，先判斷該用單次 API、tool-use workflow、Agent SDK，還是 Managed Agents，再導向對應語言與文件。最新版內容特別補強了 Managed Agents、Models API、prompt caching 與 model migration 的決策與參考資料。

## 能做什麼

- 依專案檔案自動判斷語言，導向 Python、TypeScript、Java、Go、Ruby、C#、PHP 或 cURL 文件
- 協助在 Claude API、Claude API + tool use、Agent SDK、Managed Agents 之間選擇正確 surface
- 提供 streaming、batches、Files API、structured outputs、tool runner / manual loop 的導讀
- 指向 Agent SDK 的 built-in tools、permissions、MCP、hooks、session resumption 等能力
- 補充 Managed Agents 的 shared 文件與各語言 `managed-agents/README.md` 入口，包含 memory stores、tools、events、environments、client patterns
- 提醒何時應改查 live docs，例如最新模型能力、context window、beta features 或 cached 資訊可能過期時

## 解決什麼問題

Claude 生態同時有 Claude API、Anthropic SDK、Agent SDK、Managed Agents 與多個 supporting docs；如果選錯 surface、沿用過時模型參數、或自行重造 SDK 已內建的 loop / tool abstraction，很容易把架構做複雜又踩 API 細節坑。這個 skill 的價值就是把 surface 選型、最新模型預設、語言別文件入口，以及常見陷阱整理成可直接採用的路徑。

## 何時使用（觸發條件）

- 程式碼或需求明確提到 `anthropic`、`@anthropic-ai/sdk`、`claude_agent_sdk`
- 使用者要「用 Claude API / Anthropic SDK 建應用」或問 Agent SDK / Managed Agents 怎麼接
- 需求涉及 tool use、streaming、batches、Files API、prompt caching、structured outputs
- 要做有 file / web / terminal 能力的 agent、agentic coding assistant、或需要 built-in permissions / guardrails
- 想查最新模型能力、thinking / effort、context window、或模型遷移建議

## 關鍵技術棧

- Claude Messages API 與 supporting endpoints：Models、Batches、Files、Token Counting
- Anthropic 官方 SDK：Python、TypeScript、Java、Go、Ruby、C#、PHP，以及 cURL/raw HTTP
- Agent SDK（Python / TypeScript）與 MCP、hooks、subagents、built-in tools
- Managed Agents 文件群：各語言 `managed-agents/README.md` 與 `shared/managed-agents-*.md`
- Streaming、prompt caching、structured outputs、tool runner、manual agent loops

## 重要注意事項

- 預設模型是 `claude-opus-4-6`；較複雜任務預設用 `thinking: {type: "adaptive"}`，不要在 Opus 4.6 / Sonnet 4.6 上再用 `budget_tokens`
- 先選最簡單可行的 surface：單次 API / workflow 能解就不要直接升級成 agent
- 想要內建 file / web / terminal tools、permissions、MCP 時用 Agent SDK；若是你自己定義工具與流程控制，優先用 Claude API + tool use
- Managed Agents 相關內容現在有獨立 shared 文件與語言別 `managed-agents/` 入口；不要再把它和舊版 Agent SDK patterns 混在一起理解
- 使用者明確問「最新 / current」模型能力或 cached 資訊看起來不對時，應改讀 `shared/live-sources.md` 指向的官方文件
