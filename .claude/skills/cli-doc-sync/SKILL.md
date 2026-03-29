---
name: cli-doc-sync
description: >-
  同步 CLI 參考文件與官方文件。當使用者提到「同步 CLI 文件」、「更新 CLI 參考」、
  「檢查 CLI 有沒有更新」、「cc-cli 對比官方」、「gc-cli 更新」，或任何涉及將
  CLI 參考 Markdown 與官方文件對齊的需求時觸發。
---

# CLI Doc Sync

從官方文件抓取最新 CLI 參考資訊，與本地 Markdown 做結構化差異比對，補缺刪多。

## 快速導覽

- [觸發條件](#觸發條件)
- [工具呼叫](#工具呼叫)
- [工作流程](#工作流程)
- [更新規則](#更新規則)
- [目標配置](#目標配置)
- [品質 Checklist](#品質-checklist)

## 觸發條件

以下關鍵詞或意圖應觸發此 skill：

- 「同步 CLI 文件」「更新 CLI 參考」「檢查 CLI 變更」
- 「cc-cli.md」「gc-cli.md」 + 更新 / 同步 / 對比
- 「看看官方文件有沒有新的 flag / command / shortcut」
- 明確指定要更新某個工具的 CLI 參考文件

[返回開頭](#快速導覽)

## 工具呼叫

### fetch_docs.py

位置：[`.claude/skills/cli-doc-sync/fetch_docs.py`](fetch_docs.py)

```bash
# 安裝依賴（首次使用）
pip install requests markdownify

# 列出可用目標
python .claude/skills/cli-doc-sync/fetch_docs.py --list

# 抓取指定目標
python .claude/skills/cli-doc-sync/fetch_docs.py claude-code
python .claude/skills/cli-doc-sync/fetch_docs.py github-copilot

# 抓取單一 URL
python .claude/skills/cli-doc-sync/fetch_docs.py --url "https://..."
```

### JSON 輸出結構

```json
{
  "target": "claude-code",
  "md_path": "claude-code/cc-cli.md",
  "fetched_at": "2026-03-28T12:00:00+00:00",
  "sources": [
    {
      "url": "https://...",
      "label": "CLI 參數、CLI 內建指令",
      "content_md": "# CLI Reference\n\n## Flags\n..."
    }
  ]
}
```

每個 source 的 `content_md` 是官方頁面轉換後的 Markdown。若抓取失敗，會有 `error` 欄位而非 `content_md`。

[返回開頭](#快速導覽)

## 工作流程

### Step 1：選擇目標

確認要同步的工具。若使用者未指定，列出可用目標讓其選擇。

### Step 2：執行抓取

用 Bash 執行 `fetch_docs.py <target>`，取得 JSON 輸出。確認所有 source 都成功（無 `error` 欄位）。

### Step 3：讀取現有 md

讀取目標的 md 檔案（路徑在 JSON 的 `md_path`），解析每個表格 section 的項目清單。

**解析方式**：
- 以 H2/H3 標題分隔 section
- 每個表格的第一欄（flag / command / 快捷鍵）作為 **項目識別符**
- 去除識別符的格式差異（backtick、空白）後正規化

### Step 4：差異比對

以**識別符**為錨點，逐 section 比對官方 Markdown 與現有 md。

三類差異：

| 類型 | 定義 | 處理方式 |
|------|------|---------|
| **缺少** | 官方有，md 無 | 報告後新增 |
| **多出** | md 有，官方無 | 報告後由使用者決定是否移除 |
| **描述過時** | 兩邊都有，但官方描述語意明顯不同 | 報告差異，使用者確認後更新 |

**重要**：比對以識別符（flag 名、command 名）為準，**不做中英文描述文字的直接比對**。判斷「描述過時」時，需理解英文官方描述的語意是否與中文現有描述一致。

### Step 5：呈現差異報告

使用以下格式向使用者呈現：

```markdown
## 同步報告：{tool-name}

> 比對日期：{date}
> 來源：{URLs}

### 缺少項目（官方有，文件無）

| 分類 | 項目 | 官方說明 |
|------|------|---------|
| CLI 參數 | `--new-flag` | Does something new |

### 多出項目（文件有，官方無）

| 分類 | 項目 | 目前說明 | 判斷 |
|------|------|---------|------|
| slash commands | `/old-cmd` | 舊指令說明 | 疑似已移除 |

### 描述可能過時

| 分類 | 項目 | 目前說明 | 官方說明 |
|------|------|---------|---------|
| CLI 參數 | `--model` | 目前中文描述 | Updated English desc |

### 無變更

共 {N} 個項目與官方一致，無需更新。
```

### Step 6：使用者確認後更新

**等待使用者確認**後才執行變更。更新時遵循下方「更新規則」。

[返回開頭](#快速導覽)

## 更新規則

### 新增項目

- 插入到對應 H3 section 的表格中，維持既有欄位結構
- 英文描述翻譯為**繁體中文**
- 專有術語維持英文：flag 名、command 名、model 名、tool 名、檔名、路徑
- 參考同 section 既有項目的寫作風格和詳細程度

### 移除項目

- **永不自動移除**
- 在差異報告中標記「多出」，由使用者決定
- 使用者確認後才刪除對應表格行

### 更新描述

- 舊描述和新描述並列呈現
- 使用者確認後，以新的繁體中文翻譯取代

### 自訂內容保護

以下內容**永不修改**，即使官方文件中不存在：

- md 開頭的安裝/更新/來源 metadata 區塊
- 使用者自行加入的提示或備註（如 `ultrathink` 提示、`普遍 allow 的 tool 啟動指令`）
- 非表格的散文段落（除非使用者明確要求）

### 結構保留

- 維持既有 H2/H3 階層和排列順序
- 維持既有表格欄位名稱和欄序
- 不重新格式化未變更的內容

[返回開頭](#快速導覽)

## 目標配置

工具清單定義在 [`targets.json`](targets.json)（與本 SKILL.md 同目錄）。新增工具只需在 JSON 加一筆 entry。

目前支援的目標：

| 目標 | md 路徑 | 來源數量 |
|------|---------|---------|
| `claude-code` | `claude-code/cc-cli.md` | 2 個 URL |
| `github-copilot` | `github-copilot/gc-cli.md` | 2 個 URL |

[返回開頭](#快速導覽)

## 品質 Checklist

- [ ] 所有來源 URL 都已成功抓取（JSON 無 `error` 欄位）
- [ ] 差異報告已呈現給使用者並獲得確認
- [ ] 新增項目已翻譯為繁體中文（專有術語維持英文）
- [ ] 表格欄位與既有格式一致
- [ ] 沒有動到使用者自訂的備註或額外內容
- [ ] H2/H3 結構與原文件一致
- [ ] 告知使用者官方文件可能遺漏的項目（如 beta flag、實驗功能）

[返回開頭](#快速導覽)
