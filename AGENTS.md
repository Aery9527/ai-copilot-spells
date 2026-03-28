# AGENTS.md — 專案 Skills 導覽

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

---

## 完整 Skill 清單

### 🎨 Creative（創意）

#### algorithmic-art
- **做什麼**：生成藝術（p5.js）— 粒子系統、流場、噪聲場的互動 HTML artifact
- **核心能力**：seeded randomness、seed 導航（100+ 變體）、Anthropic UI 樣式
- **詳細說明**：[`.claude/skills/algorithmic-art/SKILL.md`](.claude/skills/algorithmic-art/SKILL.md)

#### canvas-design
- **做什麼**：靜態視覺藝術（海報、設計作品）→ PDF/PNG 輸出
- **核心能力**：設計哲學宣言 + Python 畫布實作，博物館級工藝標準
- **詳細說明**：[`.claude/skills/canvas-design/SKILL.md`](.claude/skills/canvas-design/SKILL.md)

#### slack-gif-creator
- **做什麼**：創作符合 Slack 規格的動態 GIF（emoji 128×128 或 message 480×480）
- **核心能力**：GIFBuilder、Validators、Easing 函數、PIL 繪圖
- **詳細說明**：[`.claude/skills/slack-gif-creator/SKILL.md`](.claude/skills/slack-gif-creator/SKILL.md)

---

### 🎨 Styling（樣式）

#### brand-guidelines
- **做什麼**：提供 Anthropic 品牌色彩（#d97757 橘、#6a9bcc 藍等）和字體（Poppins/Lora）規格
- **核心能力**：精確 RGB/Hex 值、字體退回機制
- **詳細說明**：[`.claude/skills/brand-guidelines/SKILL.md`](.claude/skills/brand-guidelines/SKILL.md)

#### theme-factory
- **做什麼**：為任何 artifact 套用 10 種預設主題（Ocean Depths、Midnight Galaxy 等）或生成自訂主題
- **核心能力**：視覺化主題選擇（theme-showcase.pdf）、色彩+字體一體套用
- **詳細說明**：[`.claude/skills/theme-factory/SKILL.md`](.claude/skills/theme-factory/SKILL.md)

---

### 💻 Frontend Engineering（前端工程）

#### frontend-design
- **做什麼**：創作具強烈美學觀點的生產級前端 UI（HTML/CSS/JS、React、Vue）
- **核心能力**：對抗 AI 爛設計、獨特排版、動畫微互動、非對稱佈局
- **詳細說明**：[`.claude/skills/frontend-design/SKILL.md`](.claude/skills/frontend-design/SKILL.md)

#### web-artifacts-builder
- **做什麼**：建構複雜多組件 Claude.ai artifact（React + Tailwind + shadcn/ui 打包成單一 HTML）
- **核心能力**：init/bundle 腳本、40+ shadcn/ui 組件、路徑別名
- **詳細說明**：[`.claude/skills/web-artifacts-builder/SKILL.md`](.claude/skills/web-artifacts-builder/SKILL.md)

#### webapp-testing
- **做什麼**：用 Playwright 自動化測試本地 Web 應用、截圖、捕獲 logs
- **核心能力**：with_server.py（多伺服器管理）、偵察後行動模式
- **詳細說明**：[`.claude/skills/webapp-testing/SKILL.md`](.claude/skills/webapp-testing/SKILL.md)

---

### ⚙️ AI Engineering（AI 工程）

#### claude-api
- **做什麼**：用 Claude API / Anthropic SDK 建構應用（單次調用到完整 Agent）
- **核心能力**：多語言支援（Python/TS/Java/Go/Ruby/C#/PHP）、tool use、streaming、Agent SDK
- **當前模型**：claude-opus-4-6（預設）、claude-sonnet-4-6、claude-haiku-4-5
- **詳細說明**：[`.claude/skills/claude-api/SKILL.md`](.claude/skills/claude-api/SKILL.md)

#### mcp-builder
- **做什麼**：設計和建構 MCP server 讓 LLM 能操作外部 API/服務
- **核心能力**：4 階段流程（研究→實作→測試→評估）、TypeScript/Python 雙語言、工具設計原則
- **詳細說明**：[`.claude/skills/mcp-builder/SKILL.md`](.claude/skills/mcp-builder/SKILL.md)

#### skill-creator
- **做什麼**：創建、改善、評估和優化 AI Skill 的完整方法論
- **核心能力**：量化評估（evals）、描述優化器、eval-viewer 視覺化報告
- **詳細說明**：[`.claude/skills/skill-creator/SUMMARY.md`](.claude/skills/skill-creator/SUMMARY.md)（[SKILL.md](.claude/skills/skill-creator/SKILL.md) 是完整功能 skill）

---

### 📄 Office Documents（文件）

#### pdf
- **做什麼**：完整 PDF 操作（合併、分割、旋轉、OCR、建立、加密、填表、浮水印）
- **核心能力**：pypdf、pdfplumber、reportlab、pytesseract、qpdf
- **詳細說明**：[`.claude/skills/pdf/SKILL.md`](.claude/skills/pdf/SKILL.md)

#### docx
- **做什麼**：Word 文件操作（創建、讀取、編輯 .docx）
- **核心能力**：docx-js（建立）、pandoc（讀取）、XML 直接操作（精確編輯）
- **詳細說明**：[`.claude/skills/docx/SKILL.md`](.claude/skills/docx/SKILL.md)

#### pptx
- **做什麼**：PowerPoint 操作（創建、讀取、編輯 .pptx）
- **核心能力**：markitdown（讀取）、pptxgenjs（從零建立）、嚴格設計規範 + QA 流程
- **詳細說明**：[`.claude/skills/pptx/SKILL.md`](.claude/skills/pptx/SKILL.md)

#### xlsx
- **做什麼**：Excel/電子表格操作（創建、讀取、編輯、財務模型）
- **核心能力**：pandas（分析）、openpyxl（格式+公式）、recalc.py（公式重算）
- **詳細說明**：[`.claude/skills/xlsx/SKILL.md`](.claude/skills/xlsx/SKILL.md)

---

### ✍️ Writing（寫作）

#### doc-coauthoring
- **做什麼**：3 階段文件共同創作（情境蒐集→精練→讀者測試）
- **核心能力**：sub-agent 讀者測試、結構化腦力激盪、`str_replace` 精確編輯
- **詳細說明**：[`.claude/skills/doc-coauthoring/SKILL.md`](.claude/skills/doc-coauthoring/SKILL.md)

#### internal-comms
- **做什麼**：按公司格式撰寫內部溝通（3P 更新、電子報、事故報告等）
- **核心能力**：`examples/` 目錄下的格式範本（3p-updates.md、company-newsletter.md 等）
- **詳細說明**：[`.claude/skills/internal-comms/SKILL.md`](.claude/skills/internal-comms/SKILL.md)

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

**文件內需要配圖？**

```
需要什麼風格的圖？
├─ 設計感海報／封面／裝飾圖（靜態 PNG/PDF）
│   └─ canvas-design（Python 畫布，高工藝標準）
└─ 生成式幾何藝術／流場／粒子（互動 HTML 或截圖用）
    └─ algorithmic-art（p5.js，100+ seed 變體）

注意：以上兩者均為「程式碼繪圖」，非 AI 寫實圖片生成。
輸出圖片後再交給 Office skill 嵌入文件。
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

| 目錄 | 來源 | 說明 |
|------|------|------|
| `anthropic-skills/` | Anthropic 上游 | 原始 skill 定義（上游 repo，勿直接修改） |
| `.claude/skills/` | 本地摘要（從 anthropic-skills 同步） | 針對 `anthropic-skills` 的**進階解說版**，供 AI 在使用者詢問功能時，快速判斷並組合合適的 skill |
| `.agents/skills/` | **個人自製 skills** | 工作上實際遇到的問題與踩坑經驗而沉澱的 skill，與 anthropic-skills 無關 |
| `AGENT.md` | 本文件 | Skills 導覽索引（專案根目錄） |

### `.agents/` 自製 Skills 清單

這些 skill 是個人在工作中遇到具體問題後自行撰寫的，記錄常見陷阱、開發守則與實戰決策邏輯：

| Skill | 解決什麼問題 | 路徑 |
|-------|------------|------|
| **mongo** | MongoDB 查詢、aggregation pipeline、Go mongo-go-driver、JS shell 型別陷阱 | `.agents/skills/mongo/SKILL.md` |
| **windows-script** | Windows .bat/.cmd/.ps1 語法陷阱、errorlevel、delayed expansion、PowerShell 錯誤處理 | `.agents/skills/windows-script/SKILL.md` |
| **write-md** | Markdown 文件撰寫/編輯，含 Mermaid 圖表決策規則 | `.agents/skills/write-md/SKILL.md` |
| **cli-doc-sync** | CLI 參考文件與官方文件同步：Python 抓取、差異比對、缺補多刪 | `.agents/skills/cli-doc-sync/SKILL.md` |

### `.claude/` Skills 的用途

`.claude/skills/` 內的每個 SKILL.md 是對應 `anthropic-skills` 原始 skill 的**精華摘要與進階解說**。  
本文件僅整理這些與 `anthropic-skills` 上游內容一一對應的 skill，不納入本地維護／同步用途的輔助 skill。  
當使用者描述一個功能需求時，AI 可藉此快速理解各 skill 的能力邊界，做出「單 skill」或「多 skill 組合」的最佳決策。
