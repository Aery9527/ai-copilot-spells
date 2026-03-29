# AI Engineering

## 快速導覽

- [何時讀這份](#何時讀這份)
- [問題 → Skill](#問題--skill)
- [Skill 細節入口](#skill-細節入口)
- [注意事項](#注意事項)

## 何時讀這份

當需求涉及 Claude API、Anthropic SDK、MCP server、或建立 / 評估 skill 本身時，先讀這份分類檔。

[返回開頭](#快速導覽)

## 問題 → Skill

| 情境 | 建議 Skill |
|------|-------------|
| 用 Claude API / Anthropic SDK 建構應用 | [claude-api](../skills/claude-api/SKILL.md) |
| 建 MCP server 給 LLM 使用 | [mcp-builder](../skills/mcp-builder/SKILL.md) |
| 建 skill、改 skill、跑 eval、優化觸發描述 | [skill-creator](../skills/skill-creator/SKILL.md) |

[返回開頭](#快速導覽)

## Skill 細節入口

- [claude-api](../skills/claude-api/SKILL.md) — Claude API / Anthropic SDK、多語言範例與 Agent SDK
- [mcp-builder](../skills/mcp-builder/SKILL.md) — MCP server 設計、實作、測試與評估
- [skill-creator](../skills/skill-creator/SKILL.md) — skill 工程方法論、eval、描述優化

[返回開頭](#快速導覽)

## 注意事項

- `skill-creator` 在這個架構中只是一般第二層 skill 細節，不再享有獨立的特殊同步規則。
- 如果需求明確提到 Claude API / Anthropic SDK import 或 Agent SDK，通常直接展開 `claude-api`。

[返回開頭](#快速導覽)
