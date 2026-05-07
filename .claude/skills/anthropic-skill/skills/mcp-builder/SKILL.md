---
name: mcp-builder
description: Guide for creating high-quality MCP (Model Context Protocol) servers that enable LLMs to interact with external services through well-designed tools. Use when building MCP servers to integrate external APIs or services, whether in Python (FastMCP) or Node/TypeScript (MCP SDK).
---

## 概述

指導建構高品質的 MCP 伺服器，讓 LLM 能透過設計清楚的工具與外部服務互動。品質標準是 LLM 是否真能完成現實任務，而不是只做到協議相容。

## 四個建構階段

### Phase 1：深入研究與規劃

- 理解 MCP 設計原則，平衡 API 覆蓋與工作流程工具。
- 研究 MCP 規格文件，起點可用 [modelcontextprotocol.io sitemap](https://modelcontextprotocol.io/sitemap.xml)。
- 研究目標 API 的文件、認證方式與資料模型。
- 規劃工具集，優先完整 API 覆蓋。

### Phase 2：實作

- 建立專案結構，預設推薦 TypeScript。
- 實作核心基礎設施，例如 API client、錯誤處理、分頁。
- 為每個工具定義 input schema、output schema、工具描述與實作邏輯。
- 加入 annotations，例如 `readOnlyHint`、`destructiveHint`、`idempotentHint`。

### Phase 3：審查與測試

- 審查 DRY、一致錯誤處理與型別覆蓋。
- 執行 build 與 MCP Inspector 測試，例如 `npx @modelcontextprotocol/inspector`。

### Phase 4：建立評估

- 列出可用工具並探索資料。
- 建立 10 個複雜、真實、可驗證的評估問題。
- 以 XML 格式輸出，例如 `<evaluation><qa_pair>...</qa_pair></evaluation>`。

## 技術棧推薦

- 語言優先選 TypeScript，因為 SDK 支援較完整、型別安全較好，且 AI 生成品質通常較穩。
- 遠端傳輸優先用 streamable HTTP 與 stateless JSON。
- 本地傳輸優先用 `stdio`。
- Python 框架可用 `FastMCP`。
- TypeScript 框架優先用官方 MCP SDK。

## 工具設計原則

- 命名必須清晰且一致，例如用動作導向名稱與固定前綴。
- 錯誤訊息必須可操作，能指向具體修正方向。
- 回傳結果必須聚焦，並支援過濾或分頁。
- Schema 必須完整；TypeScript 可用 Zod，Python 可用 Pydantic。

## 重要注意事項

- 評估問題必須獨立、唯讀、複雜且穩定。
- 除非明確要求 Python，否則優先 TypeScript SDK。
- 工具設計優先考慮全面性，再考慮工作流程組合工具。
