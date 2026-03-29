---
name: xlsx
description: "Use this skill any time a spreadsheet file is the primary input or output. This means any task where the user wants to: open, read, edit, or fix an existing .xlsx, .xlsm, .csv, or .tsv file (e.g., adding columns, computing formulas, formatting, charting, cleaning messy data); create a new spreadsheet from scratch or from other data sources; or convert between tabular file formats. Trigger especially when the user references a spreadsheet file by name or path — even casually (like 'the xlsx in my downloads') — and wants something done to it or produced from it. Also trigger for cleaning or restructuring messy tabular data files (malformed rows, misplaced headers, junk data) into proper spreadsheets. The deliverable must be a spreadsheet file. Do NOT trigger when the primary deliverable is a Word document, HTML report, standalone Python script, database pipeline, or Google Sheets API integration, even if tabular data is involved."
source: anthropic-skills/skills/xlsx/SKILL.md
---

## 概述

完整的 Excel/電子表格操作能力，強調使用 Excel 公式而非 Python 計算硬編碼值，確保試算表保持動態可更新。對財務模型有完整的業界標準色彩和格式規範。

## 工具選擇

| 任務 | 工具 |
|------|------|
| 數據分析、批次操作、簡單導出 | **pandas** |
| 複雜格式、公式、Excel 特定功能 | **openpyxl** |
| 公式重新計算（必做） | **scripts/recalc.py** |

## 核心工作流程

```python
# pandas - 數據分析
import pandas as pd
df = pd.read_excel('file.xlsx')
df.to_excel('output.xlsx', index=False)

# openpyxl - 公式和格式
from openpyxl import Workbook, load_workbook
from openpyxl.styles import Font, PatternFill, Alignment

wb = Workbook()
sheet = wb.active
sheet['B2'] = '=SUM(A1:A10)'  # 用公式，不要計算後硬編碼
wb.save('output.xlsx')

# 公式重新計算（必做！）
# python scripts/recalc.py output.xlsx
```

## 關鍵規則：公式 vs 硬編碼

```python
# ❌ 錯誤：在 Python 計算後硬編碼
total = df['Sales'].sum()
sheet['B10'] = total  # 硬編碼 5000

# ✅ 正確：用 Excel 公式
sheet['B10'] = '=SUM(B2:B9)'
```

**所有計算（加總、百分比、比率、差值）都必須用 Excel 公式。**

## 財務模型規範

### 色彩編碼（業界標準）

| 顏色 | 用途 |
|------|------|
| **藍色** `RGB(0,0,255)` | 硬編碼輸入值、使用者可更改的數字 |
| **黑色** `RGB(0,0,0)` | 所有公式和計算 |
| **綠色** `RGB(0,128,0)` | 同工作簿內跨工作表連結 |
| **紅色** `RGB(255,0,0)` | 外部文件連結 |
| **黃色背景** `RGB(255,255,0)` | 需要注意的關鍵假設 |

### 數字格式標準

- **年份**：文字格式（`"2024"` 非 `"2,024"`）
- **貨幣**：`$#,##0`，標題含單位（`"Revenue ($mm)"`）
- **零值**：顯示 `"-"`（格式 `"$#,##0;($#,##0);-"`）
- **百分比**：`0.0%`（一位小數）
- **倍數**：`0.0x`
- **負數**：括號表示（`(123)` 非 `-123`）

## 公式重新計算

```bash
python scripts/recalc.py output.xlsx [timeout_seconds]
```

腳本返回 JSON：
- `status: "success"` 或 `"errors_found"`
- `error_summary`：包含錯誤類型和位置
- 常見錯誤：`#REF!`（無效引用）、`#DIV/0!`（除以零）、`#VALUE!`（型別錯誤）

## 解決什麼問題

Excel 文件操作涉及多個工具和格式規範。此 skill 明確指定：何時用 pandas vs openpyxl、如何正確使用公式、如何符合財務模型業界標準，以及必須運行公式重算腳本。

## 何時使用（觸發條件）

- 提到 `.xlsx`、`.xlsm`、`.csv`、`.tsv`
- 「電子表格」/ 「Excel」/ 「試算表」
- 「加欄位」/ 「計算公式」/ 「格式化」/ 「清理數據」
- 財務模型、數據整理、表格輸出

## 重要注意事項

- 使用 `data_only=True` 讀取後再存檔，公式會被永久替換為值
- 財務模型必須在假設區（assumption cells）集中放假設，公式用 cell 引用
- 修改完後必須跑 `scripts/recalc.py` 驗證公式無誤
- 不適用於：Word 文件、HTML 報告、資料庫 pipeline、Google Sheets API
