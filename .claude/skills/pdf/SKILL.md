---
name: pdf
description: Use this skill whenever the user wants to do anything with PDF files. This includes reading or extracting text/tables from PDFs, combining or merging multiple PDFs into one, splitting PDFs apart, rotating pages, adding watermarks, creating new PDFs, filling PDF forms, encrypting/decrypting PDFs, extracting images, and OCR on scanned PDFs to make them searchable. If the user mentions a .pdf file or asks to produce one, use this skill.
source: anthropic-skills/skills/pdf/SKILL.md
---

## 概述

提供完整的 PDF 操作能力，涵蓋讀取、創建、合併、分割、旋轉、浮水印、加密、OCR 等所有 PDF 相關操作，使用 Python 庫和命令行工具。

## 能做什麼

| 操作 | 工具 |
|------|------|
| 合併 PDF | pypdf |
| 分割 PDF | pypdf |
| 提取文字 | pdfplumber（含版面）|
| 提取表格 | pdfplumber |
| 建立 PDF | reportlab |
| 旋轉頁面 | pypdf |
| 加浮水印 | pypdf |
| 加密/解密 | pypdf |
| 提取圖像 | pdfimages（poppler） |
| OCR 掃描 PDF | pytesseract + pdf2image |
| 命令行合併/分割 | qpdf / pdftk |
| 填寫 PDF 表單 | pdf-lib 或 pypdf（詳見 FORMS.md）|

## 核心 Python 庫

```python
# 基本操作（合併、分割、旋轉、加密）
from pypdf import PdfReader, PdfWriter

# 文字和表格提取
import pdfplumber

# 創建 PDF（程序化）
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from reportlab.platypus import SimpleDocTemplate, Paragraph

# OCR 掃描 PDF
import pytesseract
from pdf2image import convert_from_path
```

## 命令行工具

```bash
# 文字提取（保留版面）
pdftotext -layout input.pdf output.txt

# 合併
qpdf --empty --pages file1.pdf file2.pdf -- merged.pdf

# 分割（指定頁範圍）
qpdf input.pdf --pages . 1-5 -- pages1-5.pdf

# 旋轉
qpdf input.pdf output.pdf --rotate=+90:1
```

## 重要：reportlab 的下標/上標

**禁止使用 Unicode 下標字元**（₀₁₂...、⁰¹²...）——內建字體不支援，會渲染成黑色方塊。

改用 XML 標籤：
```python
chemical = Paragraph("H<sub>2</sub>O", styles['Normal'])
squared = Paragraph("x<super>2</super>", styles['Normal'])
```

## 解決什麼問題

PDF 格式廣泛但操作複雜——需要不同工具處理不同任務（提取 vs 創建 vs 合併）。此 skill 提供統一的工具選擇指南，避免工具選錯導致功能不符。

## 何時使用（觸發條件）

- 提到 `.pdf` 或 PDF 文件的任何請求
- 「合併 PDF」/ 「拆分 PDF」/ 「提取 PDF 文字」
- 「PDF 表單」/ 「加密 PDF」/ 「OCR」
- 需要產生 PDF 報告或文件

## 進階功能

- **PDF 表單**：讀 `FORMS.md` 了解詳細填表流程（pdf-lib 或 pypdf）
- **高級 pypdfium2 用法**：讀 `REFERENCE.md`
- **JavaScript pdf-lib**：讀 `REFERENCE.md`
- **故障排除**：讀 `REFERENCE.md`
