---
name: claude-api
description: "Build, debug, and optimize Claude API / Anthropic SDK apps. Apps built with this skill should include prompt caching. Also handles migrating existing Claude API code between Claude model versions (4.5 → 4.6, 4.6 → 4.7, retired-model replacements). TRIGGER when: code imports `anthropic`/`@anthropic-ai/sdk`; user asks for the Claude API, Anthropic SDK, or Managed Agents; user adds/modifies/tunes a Claude feature (caching, thinking, compaction, tool use, batch, files, citations, memory) or model (Opus/Sonnet/Haiku) in a file; questions about prompt caching / cache hit rate in an Anthropic SDK project. SKIP: file imports `openai`/other-provider SDK, filename like `*-openai.py`/`*-generic.py`, provider-neutral code, general programming/ML."
source: skill-source/anthropic-skills/skills/claude-api/SKILL.md
---

## 概述

這個 skill 協助開發者以 Claude API 或 Anthropic SDK 建構 LLM 應用，涵蓋從單次 API 呼叫到 Managed Agents 的 surface 選型，並處理跨模型版本遷移（4.5 → 4.6 → 4.7）。

## 能做什麼

- 依專案語言自動導向 Python、TypeScript、Java、Go、Ruby、C#、PHP 或 cURL 文件
- 在 Claude API、Claude API + tool use、Managed Agents 之間做 surface 選型（含決策樹）
- 提供 streaming、batches、Files API、structured outputs、tool runner / manual loop 的導讀
- 指引 Managed Agents 設定：Agent → Session 強制流程、各語言 `managed-agents/README.md`、所有 `shared/managed-agents-*.md` 概念文件
- 提供 thinking（adaptive / disabled）、effort（low/medium/high/max/xhigh）、Compaction、Task Budgets 的正確用法
- 處理模型遷移（retired model 替換、`budget_tokens` 廢棄、`output_format` 廢棄、prefill 移除等）
- 支援 `/claude-api managed-agents-onboard` 子指令引導從零建立 Managed Agent

## 解決什麼問題

Claude 生態同時有 Claude API、Anthropic SDK、Managed Agents 與大量 supporting docs；選錯 surface、沿用過時模型參數、或自行重造 SDK 已內建的 loop / tool abstraction，容易產生架構問題並踩 API 細節坑。此 skill 將 surface 選型、最新模型預設、語言別文件入口、常見陷阱整理成可直接採用的路徑。

## 何時使用（觸發條件）

- 程式碼 import `anthropic`、`@anthropic-ai/sdk` 或任何 Anthropic 官方 SDK
- 使用者要用 Claude API / Anthropic SDK 建應用，或詢問 Managed Agents 接法
- 需求涉及 tool use、streaming、batches、Files API、prompt caching、structured outputs
- 想做有 file / web / terminal 能力的 agent，或需要 Anthropic 代管執行環境（Managed Agents）
- 想查最新模型能力、thinking / effort、context window、或進行模型版本遷移
- 問到 prompt caching 命中率低、cache 失效原因

**不觸發：** import `openai` 或其他 provider SDK、純 ML/data-science 任務、provider-neutral 程式碼

## 關鍵技術棧

- Claude Messages API 與 supporting endpoints：Models、Batches、Files、Token Counting
- Anthropic 官方 SDK：Python、TypeScript、Java、Go、Ruby、C#、PHP，以及 cURL/raw HTTP
- Managed Agents（第一方限定，不支援 Bedrock/Vertex/Foundry）：各語言 `managed-agents/README.md` 與 `shared/managed-agents-*.md` 系列文件
- Streaming、Compaction、prompt caching、structured outputs、tool runner、manual agent loops
- thinking（adaptive only on Opus 4.7）、effort（含 xhigh tier）、Task Budgets（beta）

## 重要注意事項

- **預設模型 `claude-opus-4-7`**；非必要不要降級，降級是使用者的決定
- **Opus 4.7 thinking**：只支援 `adaptive`；`budget_tokens`、`temperature`、`top_p`、`top_k` 全部移除，傳入會 400
- **Managed Agents 是第一方限定**：Bedrock、Vertex、Foundry 上不可用，改用 Claude API + tool use
- **Agent → Session 強制流程**：`agents.create` 只做一次，回傳的 agent ID 傳給每次 `sessions.create`；不要在 request path 裡呼叫 `agents.create`
- **4.6/4.7 family prefill 移除**：last-assistant-turn prefill 會 400，改用 `output_config.format` 或 system prompt
- **`output_format` 廢棄**：改用 `output_config: {format: {...}}`
- 先選最簡單可行的 surface；`budget_tokens` 在 Opus 4.6 / Sonnet 4.6 上已廢棄，新程式碼改用 `thinking: {type: "adaptive"}`
- Compaction 需保留 response.content（含 compaction blocks）回寫 messages，不可只保留文字
