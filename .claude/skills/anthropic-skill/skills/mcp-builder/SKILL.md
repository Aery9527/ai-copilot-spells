---
name: mcp-builder
description: Guide for creating high-quality MCP (Model Context Protocol) servers that enable LLMs to interact with external services through well-designed tools. Use when building MCP servers to integrate external APIs or services, whether in Python (FastMCP) or Node/TypeScript (MCP SDK).
source: anthropic-skills/skills/mcp-builder/SKILL.md
---

## 概述

指導建構高品質的 MCP（Model Context Protocol）伺服器，讓 LLM 能通過清晰設計的工具與外部服務互動。品質衡量標準：LLM 能否有效用此伺服器完成真實世界任務。

## 四個建構階段

### Phase 1：深入研究與規劃
- 理解 MCP 設計原則（API 覆蓋 vs 工作流程工具的平衡）
- 研究 MCP 規格文件（從 `https://modelcontextprotocol.io/sitemap.xml` 開始）
- 研究目標 API 的文件、身份驗證、數據模型
- 規劃工具集（優先全面的 API 覆蓋）

### Phase 2：實作
- 設置專案結構（TypeScript 推薦）
- 實作核心基礎設施（API 客戶端、錯誤處理、分頁）
- 對每個工具定義：Input Schema（Zod/Pydantic）、Output Schema、工具描述、實作邏輯
- 加入 Annotations：`readOnlyHint`、`destructiveHint`、`idempotentHint`

### Phase 3：審查與測試
- 代碼品質（DRY、一致錯誤處理、完整類型覆蓋）
- Build + MCP Inspector 測試（`npx @modelcontextprotocol/inspector`）

### Phase 4：建立評估
- 列出可用工具，探索數據
- 創建 10 個複雜、真實、可驗證的評估問題
- 以 XML 格式輸出（`<evaluation><qa_pair>` 結構）

## 技術棧推薦

| 面向 | 推薦選擇 | 原因 |
|------|---------|------|
| 語言 | TypeScript | SDK 支援佳、型別安全、AI 生成代碼品質高 |
| 傳輸（遠端）| Streamable HTTP + stateless JSON | 易擴展維護 |
| 傳輸（本地）| stdio | 標準本地伺服器模式 |
| Python 框架 | FastMCP | 高階抽象 |
| TypeScript 框架 | MCP SDK | 官方 SDK |

## 工具設計原則

- **命名清晰**：一致前綴（如 `github_create_issue`）、動作導向
- **錯誤訊息可操作**：指向具體解決方案
- **結果聚焦**：返回相關數據，支援過濾/分頁
- **Schema 完整**：含約束和描述，TypeScript 用 Zod、Python 用 Pydantic

## 解決什麼問題

開發者需要讓 Claude 等 LLM 能連接外部 API（GitHub、Slack、資料庫等），但 MCP 協議設計和工具品質直接影響 LLM 能否有效使用。此 skill 提供完整的設計到評估的指導。

## 何時使用（觸發條件）

- 「建 MCP server」/ 「MCP tool」
- 「讓 Claude 連接 [某服務]」
- 「整合外部 API 給 LLM 用」
- 需要 MCP 協議實作的任何場景

## 重要注意事項

- 評估問題必須：獨立、唯讀、複雜（多工具調用）、穩定（答案不隨時間變化）
- TypeScript SDK 優先（`server.registerTool()`），除非明確要 Python
- 工具數量優先**全面性**（覆蓋所有 API 端點），再考慮工作流程組合工具
