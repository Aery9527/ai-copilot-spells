---
name: pptx
description: "Use this skill any time a .pptx file is involved in any way — as input, output, or both. This includes: creating slide decks, pitch decks, or presentations; reading, parsing, or extracting text from any .pptx file (even if the extracted content will be used elsewhere, like in an email or summary); editing, modifying, or updating existing presentations; combining or splitting slide files; working with templates, layouts, speaker notes, or comments. Trigger whenever the user mentions 'deck', 'slides', 'presentation', or references a .pptx filename, regardless of what they plan to do with the content afterward. If a .pptx file needs to be opened, created, or touched, use this skill."
source: anthropic-skills/skills/pptx/SKILL.md
---

## 概述

完整的 PowerPoint 文件操作能力，涵蓋讀取分析、從零創建、編輯現有簡報，並附有嚴格的設計規範和 QA 流程防止 AI 爛設計。

## 三種工作模式

| 任務 | 方法 |
|------|------|
| 讀取/分析內容 | `python -m markitdown presentation.pptx` |
| 編輯或從模板創建 | 讀 `editing.md` → unpack/edit XML/pack 流程 |
| 從零創建 | 讀 `pptxgenjs.md` → pptxgenjs（Node.js）|

## 設計規範（禁止 AI 爛設計）

### 色彩原則
- **主色主導**：60-70% 視覺重量，1-2 支撐色，1 強調色
- **深/淺對比**：標題+結尾頁深色，內容頁淺色（三明治結構）
- **禁止**：預設藍色、每張都一樣的配色

### 字體配對建議

| 標題字體 | 正文字體 |
|---------|---------|
| Georgia | Calibri |
| Arial Black | Arial |
| Impact | Arial |
| Palatino | Garamond |

**字號**：標題 36-44pt、節標題 20-24pt、正文 14-16pt、說明 10-12pt

### 常見錯誤（禁止做）
- 重複相同佈局
- 居中對齊正文（只有標題居中）
- 純文字投影片（必須有圖像、圖表、icon 或形狀）
- 標題下的強調線（AI 爛設計特徵，嚴禁）
- 低對比度元素

## QA 流程（必做）

```bash
# 1. 內容 QA
python -m markitdown output.pptx
python -m markitdown output.pptx | grep -iE "xxxx|lorem|ipsum"

# 2. 視覺 QA（轉為圖像）
python scripts/office/soffice.py --headless --convert-to pdf output.pptx
pdftoppm -jpeg -r 150 output.pdf slide

# 3. Sub-agent 視覺審查
```

**QA 原則：假設一定有問題，去找它。不找到任何問題代表沒認真看。**

## 解決什麼問題

PowerPoint 格式複雜（XML 結構），而且 AI 容易產生千篇一律的爛設計。此 skill 提供正確的工具選擇路徑和嚴格的設計標準，確保輸出既功能正確又視覺精良。

## 何時使用（觸發條件）

- 提到 `deck`、`slides`、`presentation`、`.pptx`
- 「做簡報」/ 「pitch deck」/ 「投影片」
- 讀取、摘要、修改現有 .pptx 文件
- 模板、版面配置、演講者備注相關操作

## 依賴套件

```bash
pip install "markitdown[pptx]"    # 文字提取
pip install Pillow                # 縮略圖
npm install -g pptxgenjs          # 從零創建
# LibreOffice（soffice）        # PDF 轉換
# Poppler（pdftoppm）           # PDF 轉圖像
```
