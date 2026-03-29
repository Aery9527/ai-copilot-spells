---
name: docx
description: "Use this skill whenever the user wants to create, read, edit, or manipulate Word documents (.docx files). Triggers include: any mention of 'Word doc', 'word document', '.docx', or requests to produce professional documents with formatting like tables of contents, headings, page numbers, or letterheads. Also use when extracting or reorganizing content from .docx files, inserting or replacing images in documents, performing find-and-replace in Word files, working with tracked changes or comments, or converting content into a polished Word document. If the user asks for a 'report', 'memo', 'letter', 'template', or similar deliverable as a Word or .docx file, use this skill. Do NOT use for PDFs, spreadsheets, Google Docs, or general coding tasks unrelated to document generation."
source: anthropic-skills/skills/docx/SKILL.md
---

## 概述

提供完整的 Word 文件（.docx）操作能力，涵蓋創建、讀取、編輯三大工作流程，使用 JavaScript（docx-js）建立新文件，XML 直接操作進行精確編輯。

## 能做什麼

- **讀取/分析**：用 pandoc 提取文字（含追蹤修訂）、unpack 查看原始 XML
- **創建新文件**：使用 `docx`（npm）JavaScript 庫生成完整格式文件
- **編輯現有文件**：unpack → 修改 XML → repack
- **格式功能**：標題層級、目錄、頁碼、頁眉頁腳、表格、圖像
- **追蹤修訂**：讀取或接受追蹤修訂（`accept_changes.py`）
- **格式轉換**：`.doc` → `.docx`、`.docx` → PDF → 圖像（用於視覺 QA）

## 工作流程

### 讀取文件
```bash
pandoc --track-changes=all document.docx -o output.md
python scripts/office/unpack.py document.docx unpacked/
```

### 創建新文件（推薦：docx-js）
```bash
npm install -g docx
node generate.js  # 生成 .docx
```

### 編輯現有文件
```bash
# 1. 解包
python scripts/office/unpack.py input.docx unpacked/
# 2. 修改 unpacked/ 內的 XML
# 3. 重打包
python scripts/office/pack.py unpacked/ output.docx
```

### 視覺驗證
```bash
python scripts/office/soffice.py --headless --convert-to pdf document.docx
pdftoppm -jpeg -r 150 document.pdf page
```

## 解決什麼問題

使用者需要以程序化方式創建或修改 Word 文件，但 .docx 本質上是 ZIP 壓縮的 XML，直接處理很複雜。此 skill 提供適合各種場景的工具選擇與操作流程。

## 何時使用（觸發條件）

- 提到「Word doc」、「word document」、`.docx`
- 「報告」、「備忘錄」、「信件」、「模板」需要以 Word 格式輸出
- 讀取、提取、重組 .docx 文件內容
- 插入/替換圖像、追蹤修訂、find-and-replace

## 關鍵技術棧

- **pandoc**：文字提取（含追蹤修訂）
- **docx（npm）**：創建新 Word 文件（JavaScript）
- **python-docx**：Python 操作（基本格式）
- **scripts/office/soffice.py**：LibreOffice 包裝（格式轉換）
- **scripts/office/unpack.py / pack.py**：XML 直接操作

## 重要注意事項

- `.doc`（舊格式）必須先轉換為 `.docx` 才能編輯
- docx-js 支援複雜格式（TOC、多欄、複雜表格）
- 視覺驗證建議轉成圖像後人工或 sub-agent 審查
- 不適用於：PDF、電子表格、Google Docs、純 coding 任務
