---
name: claude-api
description: "Build apps with the Claude API or Anthropic SDK. TRIGGER when: code imports `anthropic`/`@anthropic-ai/sdk`/`claude_agent_sdk`, or user asks to use Claude API, Anthropic SDKs, or Agent SDK. DO NOT TRIGGER when: code imports `openai`/other AI SDK, general programming, or ML/data-science tasks."
source: anthropic-skills/skills/claude-api/SKILL.md
---

## 概述

協助開發者用 Claude API 或 Anthropic SDK 建構 LLM 應用程式，涵蓋從單次 API 調用到完整 Agent 系統的所有場景，並提供多語言支援與最新模型規格。

## 能做什麼

- 偵測專案語言（Python/TypeScript/Java/Go/Ruby/C#/PHP/cURL）
- 選擇正確的應用層級（單次調用 → Workflow → Agent → Agent SDK）
- 提供各語言的 SDK 代碼範例
- 工具調用（tool use）、串流（streaming）、批次處理（batches）
- 文件 API（Files API）、結構化輸出（structured outputs）
- Agent SDK 整合（Python/TypeScript，含內建工具、MCP）
- 上下文壓縮（Compaction，Opus 4.6）

## 當前模型規格（2026-02-17）

| 模型 | Model ID | 情境窗口 | 輸入$/1M | 輸出$/1M |
|------|----------|----------|----------|----------|
| Claude Opus 4.6 | `claude-opus-4-6` | 200K (1M beta) | $5.00 | $25.00 |
| Claude Sonnet 4.6 | `claude-sonnet-4-6` | 200K (1M beta) | $3.00 | $15.00 |
| Claude Haiku 4.5 | `claude-haiku-4-5` | 200K | $1.00 | $5.00 |

**預設使用 `claude-opus-4-6`**，除非使用者明確指定其他模型。

## 關鍵 API 決策樹

```
需要什麼？
├─ 單次分類/摘要/提取 → Claude API（一次請求一次回應）
├─ Claude 需自行讀寫檔案/瀏覽網頁/執行指令
│   └─ Agent SDK（Python/TypeScript only）
├─ 多步驟、程式碼控制的 workflow
│   └─ Claude API + tool use
└─ 開放式 agent（模型決定行動路徑）
    └─ Claude API agentic loop
```

## 思考模式（Thinking）

- **Opus 4.6 / Sonnet 4.6**：使用 `thinking: {type: "adaptive"}`（自適應）
- **禁止使用 `budget_tokens`**（在 Opus/Sonnet 4.6 上已棄用）
- `effort` 參數：`low | medium | high | max`（在 `output_config` 內）

## 解決什麼問題

開發者需要快速正確地整合 Claude API，但 SDK 版本更新、模型參數、最佳實踐容易出錯。此 skill 提供最新規格與語言特定代碼範例，避免常見陷阱。

## 何時使用（觸發條件）

- 代碼中出現 `import anthropic`、`from anthropic import`、`@anthropic-ai/sdk`
- 詢問「如何使用 Claude API」
- 需要 tool use、streaming、batches、Files API
- 建構 AI agent 或 chatbot
- Agent SDK 相關問題

## 語言支援矩陣

| 語言 | Tool Runner | Agent SDK |
|------|-------------|-----------|
| Python | ✅ (beta) | ✅ |
| TypeScript | ✅ (beta) | ✅ |
| Java | ✅ (beta) | ❌ |
| Go | ✅ (beta) | ❌ |
| Ruby | ✅ (beta) | ❌ |
| C# / PHP | ❌ | ❌ |

## 常見陷阱

- Opus 4.6 不支援 prefill（會返回 400）→ 改用 `output_config.format`
- 128K output tokens 需要 streaming（避免 HTTP 超時）
- `output_format` 已棄用 → 使用 `output_config: {format: {...}}`
- 不要自定義 SDK 已有的 TypeScript 介面（如 `MessageParam`、`Tool`）
