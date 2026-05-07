---
name: xlsx
description: "Use this skill any time a spreadsheet file is the primary input or output. This means any task where the user wants to: open, read, edit, or fix an existing .xlsx, .xlsm, .csv, or .tsv file (e.g., adding columns, computing formulas, formatting, charting, cleaning messy data); create a new spreadsheet from scratch or from other data sources; or convert between tabular file formats. Trigger especially when the user references a spreadsheet file by name or path — even casually (like 'the xlsx in my downloads') — and wants something done to it or produced from it. Also trigger for cleaning or restructuring messy tabular data files (malformed rows, misplaced headers, junk data) into proper spreadsheets. The deliverable must be a spreadsheet file. Do NOT trigger when the primary deliverable is a Word document, HTML report, standalone Python script, database pipeline, or Google Sheets API integration, even if tabular data is involved."
---

## 概述

提供完整的 Excel 與電子表格操作能力，重點是使用 Excel 公式而不是 Python 硬編碼計算值，確保試算表保持動態可更新。

## 工具選擇

- 數據分析、批次操作、簡單導出 -> `pandas`
- 複雜格式、公式、Excel 特定功能 -> `openpyxl`
- 公式重新計算 -> [`anthropic-skills/skills/xlsx/scripts/recalc.py`](../../../../../anthropic-skills/skills/xlsx/scripts/recalc.py)

## 核心工作流程

```python
import pandas as pd
from openpyxl import Workbook, load_workbook
from openpyxl.styles import Font, PatternFill, Alignment
```

- 用 `pandas` 做分析與簡單輸出。
- 用 `openpyxl` 寫公式與格式。
- 修改完成後必須執行 `python anthropic-skills/skills/xlsx/scripts/recalc.py output.xlsx`。

## 關鍵規則：公式優先

- 嚴禁在 Python 裡先算好再把結果硬編碼進儲存格。
- 所有加總、百分比、比率與差值都必須用 Excel 公式。

## 財務模型規範

### 色彩編碼

- 藍色 `RGB(0,0,255)` -> 硬編碼輸入值與可修改數字。
- 黑色 `RGB(0,0,0)` -> 所有公式與計算。
- 綠色 `RGB(0,128,0)` -> 同工作簿內跨工作表連結。
- 紅色 `RGB(255,0,0)` -> 外部文件連結。
- 黃色背景 `RGB(255,255,0)` -> 需要注意的關鍵假設。

### 數字格式標準

- 年份使用文字格式。
- 貨幣格式用 `$#,##0`，標題應含單位。
- 零值顯示 `-`。
- 百分比用 `0.0%`。
- 倍數用 `0.0x`。
- 負數用括號，不用負號。

## 公式重新計算

```bash
python anthropic-skills/skills/xlsx/scripts/recalc.py output.xlsx [timeout_seconds]
```

- 腳本會回傳 `success` 或 `errors_found`。
- 必須檢查 `error_summary`。
- 常見錯誤包括 `#REF!`、`#DIV/0!` 與 `#VALUE!`。

## 重要注意事項

- 使用 `data_only=True` 讀取後再存檔，會永久把公式替換成值。
- 財務模型應把假設集中在 assumption cells，公式用 cell 引用。
- 修改後必須跑 [`anthropic-skills/skills/xlsx/scripts/recalc.py`](../../../../../anthropic-skills/skills/xlsx/scripts/recalc.py) 驗證。
- 如果主要交付物不是 spreadsheet file，嚴禁誤用此 skill。
