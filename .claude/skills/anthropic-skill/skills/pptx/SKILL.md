---
name: pptx
description: "Use this skill any time a .pptx file is involved in any way — as input, output, or both. This includes: creating slide decks, pitch decks, or presentations; reading, parsing, or extracting text from any .pptx file (even if the extracted content will be used elsewhere, like in an email or summary); editing, modifying, or updating existing presentations; combining or splitting slide files; working with templates, layouts, speaker notes, or comments. Trigger whenever the user mentions 'deck', 'slides', 'presentation', or references a .pptx filename, regardless of what they plan to do with the content afterward. If a .pptx file needs to be opened, created, or touched, use this skill."
---

## 概述

提供完整的 PowerPoint 操作能力，涵蓋讀取分析、從零創建、編輯現有簡報，以及嚴格的設計規範與 QA 流程。

## 三種工作模式

- 讀取或分析內容 -> `python -m markitdown presentation.pptx`
- 編輯既有簡報或從模板創建 -> 讀 [anthropic-skills/skills/pptx/editing.md](../../../../../anthropic-skills/skills/pptx/editing.md)，走 unpack / edit XML / pack 流程
- 從零創建簡報 -> 讀 [anthropic-skills/skills/pptx/pptxgenjs.md](../../../../../anthropic-skills/skills/pptx/pptxgenjs.md)，使用 `pptxgenjs`

## 設計規範

### 色彩原則

- 主色主導 60% 到 70% 視覺重量。
- 使用 1 到 2 個支撐色與 1 個強調色。
- 標題頁與結尾頁可用深色，內容頁可用淺色。
- 嚴禁預設藍色與每張都一樣的配色。

### 字體配對建議

- `Georgia` 標題搭配 `Calibri` 正文。
- `Arial Black` 標題搭配 `Arial` 正文。
- `Impact` 標題搭配 `Arial` 正文。
- `Palatino` 標題搭配 `Garamond` 正文。

### 字號建議

- 標題 36 到 44pt。
- 節標題 20 到 24pt。
- 正文 14 到 16pt。
- 說明文字 10 到 12pt。

### 常見錯誤

- 嚴禁重複相同佈局。
- 嚴禁把正文居中對齊。
- 嚴禁純文字投影片；必須有圖像、圖表、icon 或形狀。
- 嚴禁標題下的強調線。
- 嚴禁低對比度元素。

## QA 流程

```bash
python -m markitdown output.pptx
python -m markitdown output.pptx | grep -iE "xxxx|lorem|ipsum"
python anthropic-skills/skills/pptx/scripts/office/soffice.py --headless --convert-to pdf output.pptx
pdftoppm -jpeg -r 150 output.pdf slide
```

- 必須先做內容 QA。
- 必須再做視覺 QA。
- 必要時可加上 sub-agent 視覺審查。

## 依賴套件

```bash
pip install "markitdown[pptx]"
pip install Pillow
npm install -g pptxgenjs
```

- 另外通常還需要 LibreOffice 的 `soffice` 與 Poppler 的 `pdftoppm`。
