---
name: pdf
description: Use this skill whenever the user wants to do anything with PDF files. This includes reading or extracting text/tables from PDFs, combining or merging multiple PDFs into one, splitting PDFs apart, rotating pages, adding watermarks, creating new PDFs, filling PDF forms, encrypting/decrypting PDFs, extracting images, and OCR on scanned PDFs to make them searchable. If the user mentions a .pdf file or asks to produce one, use this skill.
---

## 概述

提供完整的 PDF 操作能力，涵蓋讀取、建立、合併、分割、旋轉、浮水印、加密、OCR 等所有 PDF 相關操作。

## 能做什麼

- 合併 PDF -> `pypdf`
- 分割 PDF -> `pypdf`
- 提取文字 -> `pdfplumber`
- 提取表格 -> `pdfplumber`
- 建立 PDF -> `reportlab`
- 旋轉頁面 -> `pypdf`
- 加浮水印 -> `pypdf`
- 加密或解密 -> `pypdf`
- 提取圖像 -> `pdfimages`
- OCR 掃描 PDF -> `pytesseract` + `pdf2image`
- 命令列合併或分割 -> `qpdf` 或 `pdftk`
- 填寫 PDF 表單 -> `pdf-lib` 或 `pypdf`；詳細流程讀 [anthropic-skills/skills/pdf/forms.md](../../../../../anthropic-skills/skills/pdf/forms.md)

## 核心 Python 庫

```python
from pypdf import PdfReader, PdfWriter
import pdfplumber
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from reportlab.platypus import SimpleDocTemplate, Paragraph
import pytesseract
from pdf2image import convert_from_path
```

## 命令列工具

```bash
pdftotext -layout input.pdf output.txt
qpdf --empty --pages file1.pdf file2.pdf -- merged.pdf
qpdf input.pdf --pages . 1-5 -- pages1-5.pdf
qpdf input.pdf output.pdf --rotate=+90:1
```

## 重要：reportlab 的下標與上標

- 嚴禁使用 Unicode 下標或上標字元，因為內建字體常不支援，會渲染成方塊。
- 必須改用 XML 標籤：

```python
chemical = Paragraph("H<sub>2</sub>O", styles['Normal'])
squared = Paragraph("x<super>2</super>", styles['Normal'])
```

## 進階功能

- PDF 表單流程讀 [anthropic-skills/skills/pdf/forms.md](../../../../../anthropic-skills/skills/pdf/forms.md)。
- 進階 pypdfium2 與 JavaScript `pdf-lib` 用法讀 [anthropic-skills/skills/pdf/reference.md](../../../../../anthropic-skills/skills/pdf/reference.md)。
- 故障排除也讀 [anthropic-skills/skills/pdf/reference.md](../../../../../anthropic-skills/skills/pdf/reference.md)。
