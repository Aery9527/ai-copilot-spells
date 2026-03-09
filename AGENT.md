# AGENT.md — 專案 Skills 導覽

> 當使用者遇到問題時，Rion 可以查閱此文件判斷應該使用哪些 skill，並進入對應的 `.claude/skills/<name>/SKILL.md` 獲取詳細使用說明。

---

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
| 建構 MCP server 讓 LLM 連接外部服務 | **mcp-builder** |
| 創建、改善或評估 AI Skill | **skill-creator** |
| 同步 / 更新 anthropic-skills 上游 skill 變更 | **anthropic-skills-sync** |

### 📄 Office 文件

| 我需要... | 使用 Skill |
|----------|-----------|
| 操作 PDF（讀取、合併、分割、OCR、建立） | **pdf** |
| 操作 Word 文件（.docx 創建、編輯、讀取） | **docx** |
| 操作 PowerPoint 簡報（.pptx 創建、編輯、讀取） | **pptx** |
| 操作 Excel 電子表格（.xlsx 創建、編輯、分析） | **xlsx** |

### ✍️ 文字寫作

| 我需要... | 使用 Skill |
|----------|-----------|
| 撰寫技術規格、提案、設計文件 | **doc-coauthoring** |
| 撰寫內部溝通（3P 更新、電子報、事故報告） | **internal-comms** |

---

## 完整 Skill 清單

### 🎨 Creative（創意）

#### algorithmic-art
- **做什麼**：生成藝術（p5.js）— 粒子系統、流場、噪聲場的互動 HTML artifact
- **核心能力**：seeded randomness、seed 導航（100+ 變體）、Anthropic UI 樣式
- **詳細說明**：`.claude/skills/algorithmic-art/SKILL.md`

#### canvas-design
- **做什麼**：靜態視覺藝術（海報、設計作品）→ PDF/PNG 輸出
- **核心能力**：設計哲學宣言 + Python 畫布實作，博物館級工藝標準
- **詳細說明**：`.claude/skills/canvas-design/SKILL.md`

#### slack-gif-creator
- **做什麼**：創作符合 Slack 規格的動態 GIF（emoji 128×128 或 message 480×480）
- **核心能力**：GIFBuilder、Validators、Easing 函數、PIL 繪圖
- **詳細說明**：`.claude/skills/slack-gif-creator/SKILL.md`

---

### 🎨 Styling（樣式）

#### brand-guidelines
- **做什麼**：提供 Anthropic 品牌色彩（#d97757 橘、#6a9bcc 藍等）和字體（Poppins/Lora）規格
- **核心能力**：精確 RGB/Hex 值、字體退回機制
- **詳細說明**：`.claude/skills/brand-guidelines/SKILL.md`

#### theme-factory
- **做什麼**：為任何 artifact 套用 10 種預設主題（Ocean Depths、Midnight Galaxy 等）或生成自訂主題
- **核心能力**：視覺化主題選擇（theme-showcase.pdf）、色彩+字體一體套用
- **詳細說明**：`.claude/skills/theme-factory/SKILL.md`

---

### 💻 Frontend Engineering（前端工程）

#### frontend-design
- **做什麼**：創作具強烈美學觀點的生產級前端 UI（HTML/CSS/JS、React、Vue）
- **核心能力**：對抗 AI 爛設計、獨特排版、動畫微互動、非對稱佈局
- **詳細說明**：`.claude/skills/frontend-design/SKILL.md`

#### web-artifacts-builder
- **做什麼**：建構複雜多組件 Claude.ai artifact（React + Tailwind + shadcn/ui 打包成單一 HTML）
- **核心能力**：init/bundle 腳本、40+ shadcn/ui 組件、路徑別名
- **詳細說明**：`.claude/skills/web-artifacts-builder/SKILL.md`

#### webapp-testing
- **做什麼**：用 Playwright 自動化測試本地 Web 應用、截圖、捕獲 logs
- **核心能力**：with_server.py（多伺服器管理）、偵察後行動模式
- **詳細說明**：`.claude/skills/webapp-testing/SKILL.md`

---

### ⚙️ AI Engineering（AI 工程）

#### claude-api
- **做什麼**：用 Claude API / Anthropic SDK 建構應用（單次調用到完整 Agent）
- **核心能力**：多語言支援（Python/TS/Java/Go/Ruby/C#/PHP）、tool use、streaming、Agent SDK
- **當前模型**：claude-opus-4-6（預設）、claude-sonnet-4-6、claude-haiku-4-5
- **詳細說明**：`.claude/skills/claude-api/SKILL.md`

#### mcp-builder
- **做什麼**：設計和建構 MCP server 讓 LLM 能操作外部 API/服務
- **核心能力**：4 階段流程（研究→實作→測試→評估）、TypeScript/Python 雙語言、工具設計原則
- **詳細說明**：`.claude/skills/mcp-builder/SKILL.md`

#### skill-creator
- **做什麼**：創建、改善、評估和優化 AI Skill 的完整方法論
- **核心能力**：量化評估（evals）、描述優化器、eval-viewer 視覺化報告
- **詳細說明**：`.claude/skills/skill-creator/SUMMARY.md`（SKILL.md 是完整功能 skill）

#### anthropic-skills-sync
- **做什麼**：檢查 `anthropic-skills/` 上游 repo 是否有更新，並自動同步 `.claude/skills/` 中的摘要（skill-creator 則完整同步所有檔案），完成後 commit & push
- **核心能力**：git fetch/diff/pull、robocopy 全量同步、摘要重新生成、AGENT.md 自動擴充
- **詳細說明**：`.claude/skills/anthropic-skills-sync/SKILL.md`

---

### 📄 Office Documents（文件）

#### pdf
- **做什麼**：完整 PDF 操作（合併、分割、旋轉、OCR、建立、加密、填表、浮水印）
- **核心能力**：pypdf、pdfplumber、reportlab、pytesseract、qpdf
- **詳細說明**：`.claude/skills/pdf/SKILL.md`

#### docx
- **做什麼**：Word 文件操作（創建、讀取、編輯 .docx）
- **核心能力**：docx-js（建立）、pandoc（讀取）、XML 直接操作（精確編輯）
- **詳細說明**：`.claude/skills/docx/SKILL.md`

#### pptx
- **做什麼**：PowerPoint 操作（創建、讀取、編輯 .pptx）
- **核心能力**：markitdown（讀取）、pptxgenjs（從零建立）、嚴格設計規範 + QA 流程
- **詳細說明**：`.claude/skills/pptx/SKILL.md`

#### xlsx
- **做什麼**：Excel/電子表格操作（創建、讀取、編輯、財務模型）
- **核心能力**：pandas（分析）、openpyxl（格式+公式）、recalc.py（公式重算）
- **詳細說明**：`.claude/skills/xlsx/SKILL.md`

---

### ✍️ Writing（寫作）

#### doc-coauthoring
- **做什麼**：3 階段文件共同創作（情境蒐集→精練→讀者測試）
- **核心能力**：sub-agent 讀者測試、結構化腦力激盪、`str_replace` 精確編輯
- **詳細說明**：`.claude/skills/doc-coauthoring/SKILL.md`

#### internal-comms
- **做什麼**：按公司格式撰寫內部溝通（3P 更新、電子報、事故報告等）
- **核心能力**：`examples/` 目錄下的格式範本（3p-updates.md、company-newsletter.md 等）
- **詳細說明**：`.claude/skills/internal-comms/SKILL.md`

---

## Skill 選擇決策輔助

### 「我要做一個網頁/UI」

```
需要 shadcn/ui 組件或複雜狀態管理？
├─ 是 → web-artifacts-builder
└─ 否 → 重視設計美學？
    ├─ 是 → frontend-design
    └─ 不確定 → frontend-design（設計優先）
```

### 「我要做藝術/設計」

```
需要互動性（可調參數、探索變體）？
├─ 是 → algorithmic-art（p5.js 生成藝術）
└─ 否 → 靜態圖片/海報 → canvas-design
```

### 「我要做 Office 文件」

```
.pdf → pdf skill
.docx / Word → docx skill
.pptx / PowerPoint / 投影片 → pptx skill
.xlsx / Excel / 電子表格 → xlsx skill
```

### 「我要建 AI 應用」

```
需要 Claude 自行瀏覽網頁/讀寫檔案/執行指令？
├─ 是 → claude-api（Agent SDK）
└─ 否 → 需要讓 Claude 連接外部 API/服務？
    ├─ 是 → mcp-builder（建 MCP server）
    └─ 否 → claude-api（單次調用 or 工具調用）
```

---

## Skill 位置

- **原始 Skills**：`anthropic-skills/skills/<name>/SKILL.md`
- **精華摘要**：`.claude/skills/<name>/SKILL.md`（或 `SUMMARY.md`）
- **此導覽文件**：`AGENT.md`（專案根目錄）
