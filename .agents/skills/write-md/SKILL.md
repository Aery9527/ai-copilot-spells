---
name: write-md
description: Writing or editing markdown documents. Use when the user asks to write, create, update, or organize any markdown file — including feature docs, module docs, architecture overviews, READMEs, or technical specifications. When the content involves architecture, module dependencies, data flows, state transitions, or component relationships that would be significantly easier to understand as a diagram, embed Mermaid diagrams. Do NOT use Mermaid for content that can be clearly expressed with lists, tables, or prose — only use it when visualization genuinely reduces comprehension difficulty.
---

# Write MD

撰寫與編輯 Markdown 文件。選擇性地嵌入 Mermaid 圖表——**僅在視覺化能明顯降低理解難度時才使用**，而非預設插圖。

## 工作流程

1. 釐清文件範圍：記錄什麼內容、目標讀者是誰
2. 起草 Markdown 結構（章節、段落、表格/清單）
3. 對每個章節套用「Mermaid 判斷關卡」（見下方），再決定是否加圖
4. 只在通過判斷關卡的章節嵌入 Mermaid 圖表
5. 圖表必須補充文字，而非重複文字已說清楚的內容

## Mermaid 判斷關卡

加圖前先問自己：

> **「讀者光靠文字/清單/表格，能輕鬆建立心智模型嗎？」**

**應使用 Mermaid** 的情境：
- 多元件之間的相依關係，依賴鏈不直觀
- 跨 ≥3 個角色的時序互動（sequence）
- 有分支路徑的狀態機 / 生命週期轉換
- 各階段與連接方式都很重要的資料流 pipeline
- 層次複雜、用文字難以追蹤的模組/套件相依樹

**不應使用 Mermaid** 的情境：
- 用簡單條列或編號步驟同樣清楚
- 只是平鋪式的項目列舉（用表格或清單即可）
- 只有 2–3 個顯而易見的線性關係
- 關係用一句話就能說清楚（如「A 呼叫 B」）
- 加了圖只是在重述前一段文字已解釋的內容

## 圖表類型選擇指南

| 情境 | 圖表類型 | 使用時機 |
|---|---|---|
| 模組相依、呼叫層級 | `flowchart TD` | 套件/模組間相依鏈不直觀時 |
| 跨服務的請求/回應流程 | `sequenceDiagram` | ≥3 個元件之間的時序互動 |
| 介面/struct 型別關係 | `classDiagram` | 型別層級、介面實作、struct 組合 |
| 生命週期、狀態轉換 | `stateDiagram-v2` | 實體在有分支的狀態間流轉 |
| 資料庫 schema、實體關係 | `erDiagram` | 有多個外鍵關係的資料模型 |
| 處理 pipeline | `flowchart LR` | 方向與標籤都很重要的線性處理流程 |
| 決策邏輯、分支流程 | `flowchart TD` | 用文字難以說清楚的條件分支 |

若一個功能橫跨多個面向，**只在每種圖各自帶來獨立洞見時**才組合使用，避免為求完整而堆圖。

## 文件結構

可自由調整，典型結構如下：

```markdown
# {功能 / 模組名稱}

## 概覽
目的、範圍、關鍵設計決策（純文字）。

## 架構 / 結構
[Mermaid：僅在元件關係複雜到難以用文字表達時使用]

## 流程
[Mermaid：僅在時序或資料流順序難以用文字追蹤時使用]

## 核心元件
各元件說明。只在型別層級確實需要時才加 classDiagram。

## 注意事項
邊界條件、設計限制、待解決問題。
```

不適用的章節直接省略，依需求增加領域專屬章節。

## Mermaid 最佳實踐

- 每張圖專注於**一個概念**；複雜系統拆成多張圖
- Node label 使用繁體中文，identifier 維持英文
- flowchart 的連線要加有意義的 label 說明關係類型
- 圖的深度控制在 3–4 層以維持可讀性
- 節點 ≥6 個時用 `subgraph` 分群
- sequence diagram 用 `activate`/`deactivate` 與 `note` 標示關鍵行為
- 直接相依用 `-->` 實線，可選/間接關係用 `-.->` 虛線

## 範例

各圖表類型的詳細語法範例，參見 [references/diagram-examples.md](references/diagram-examples.md)。
