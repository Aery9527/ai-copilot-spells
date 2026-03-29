---
name: anthropic-skill
description: Use this skill when a user asks which Anthropic skill fits a task, or when the task falls into creative design, frontend engineering, AI engineering, office documents, or writing workflows covered by the local anthropic-skills catalog. Start here, route by category, then load only the relevant internal category and skill notes.
---

# Anthropic Skill Router

## 快速導覽

- [定位原則](#定位原則)
- [快速查詢：問題 → Skill](#快速查詢問題--skill)
- [第二層讀取規則](#第二層讀取規則)
- [分類入口](#分類入口)
- [注意事項](#注意事項)

## 定位原則

`anthropic-skill` 是本 repo 針對 Anthropic skills 整理後的唯一第一層入口。它的工作不是一次把所有 skill 細節載入，而是先做路由，再按需揭露第二層內容。

執行順序固定如下：

1. 先用本檔的「快速查詢：問題 → Skill」判斷需求落在哪個類別。
2. 再讀對應的分類檔（`categories/`）。
3. 最後只讀需要的 skill 細節檔（`skills/<name>/SKILL.md`）。
4. 除非任務真的跨類別，否則不要一口氣讀完整個 `skills/` 目錄。

[返回開頭](#快速導覽)

## 快速查詢：問題 → Skill

### 🎨 創意設計

| 我需要... | 使用 Skill |
|----------|-----------|
| 用代碼創作生成藝術、流場、粒子系統 | **algorithmic-art** |
| 設計海報、藝術品、靜態視覺（PNG/PDF） | **canvas-design** |
| 為已完成的 artifact 套用主題風格 | **theme-factory** |
| 套用 Anthropic 官方品牌色彩和字體 | **brand-guidelines** |
| 做 Slack 用的動態 GIF 表情包 | **slack-gif-creator** |

### 💻 前端工程

| 我需要... | 使用 Skill |
|----------|-----------|
| 建構有設計感的網頁 UI、組件、landing page | **frontend-design** |
| 建構複雜的多組件 Claude artifact（React + shadcn/ui） | **web-artifacts-builder** |
| 測試本地 Web 應用、自動化 UI 行為 | **webapp-testing** |

### ⚙️ AI 工程

| 我需要... | 使用 Skill |
|----------|-----------|
| 用 Claude API 或 Anthropic SDK 建構應用 | **claude-api** |
| 建構 MCP server 讓 LLM 連接外部 API/服務 | **mcp-builder** |
| 創建、改善或評估 AI Skill | **skill-creator** |

### 📄 Office 文件

| 我需要... | 使用 Skill |
|----------|-----------|
| 操作 PDF（讀取、合併、分割、OCR、建立） | **pdf** |
| 操作 Word 文件（.docx 創建、編輯、讀取） | **docx** |
| 操作 PowerPoint 簡報（.pptx 創建、編輯、讀取） | **pptx** |
| 操作 Excel 電子表格（.xlsx 創建、編輯、分析） | **xlsx** |
| 為 Office 文件生成情境配圖（設計風格、海報圖、裝飾圖） | **canvas-design** |
| 為 Office 文件生成生成式藝術圖（流場、粒子、幾何） | **algorithmic-art** |

### ✍️ 文字寫作

| 我需要... | 使用 Skill |
|----------|-----------|
| 撰寫技術規格、提案、設計文件 | **doc-coauthoring** |
| 撰寫內部溝通（3P 更新、電子報、事故報告） | **internal-comms** |

[返回開頭](#快速導覽)

## 第二層讀取規則

- 若需求是生成藝術、品牌、主題、設計視覺，讀 [categories/creative-and-styling.md](categories/creative-and-styling.md)
- 若需求是網頁 UI、artifact builder、UI 自動化測試，讀 [categories/frontend-engineering.md](categories/frontend-engineering.md)
- 若需求是 Claude API、MCP、skill engineering，讀 [categories/ai-engineering.md](categories/ai-engineering.md)
- 若需求是 PDF、Word、PowerPoint、Excel 或文件配圖，讀 [categories/office-documents.md](categories/office-documents.md)
- 若需求是技術文件或內部溝通，讀 [categories/writing.md](categories/writing.md)

若分類檔已足夠回答，就不要再展開更多 skill 細節；只有在需要具體能力邊界、技術棧或注意事項時，才往 `skills/<name>/SKILL.md` 深入。

[返回開頭](#快速導覽)

## 分類入口

- [Creative & Styling](categories/creative-and-styling.md)
- [Frontend Engineering](categories/frontend-engineering.md)
- [AI Engineering](categories/ai-engineering.md)
- [Office Documents](categories/office-documents.md)
- [Writing](categories/writing.md)

[返回開頭](#快速導覽)

## 注意事項

- `anthropic-skills-sync` 是獨立的維運 skill，位於 [`.claude/skills/anthropic-skills-sync/SKILL.md`](../anthropic-skills-sync/SKILL.md)，不屬於這個 router 的第二層內容。
- `skill-creator` 已和其他 Anthropic skills 一樣被正規化成第二層摘要檔，不再保留特權路徑。
- 若需求跨多個 skill，先找主 skill，再只補讀必要的次要 skill，避免一開始就把所有內容灌進 context。

[返回開頭](#快速導覽)
