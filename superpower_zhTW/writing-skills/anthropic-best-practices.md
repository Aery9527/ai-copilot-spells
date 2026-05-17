# Skill 撰寫最佳實踐

> 學習如何撰寫有效的 Skills，讓 Claude 能夠成功地發現並使用它們。

好的 Skills 簡潔、結構清晰，並經過真實使用的測試。本指南提供實用的撰寫決策，幫助你撰寫 Claude 能夠有效發現和使用的 Skills。

有關 Skills 運作方式的概念背景，請參閱 [Skills 概覽](/en/docs/agents-and-tools/agent-skills/overview)。

## 核心原則

### 簡潔是關鍵

[Context window](https://platform.claude.com/docs/en/build-with-claude/context-windows) 是公共財。你的 Skill 與 Claude 需要知道的所有其他內容共享 context window，包括：

* 系統提示
* 對話歷史
* 其他 Skills 的元資料
* 你的實際請求

你的 Skill 中並非每個 token 都有即時成本。啟動時，只有所有 Skills 的元資料（名稱和 description）會被預先載入。Claude 只有在 Skill 變得相關時才讀取 SKILL.md，並且只在需要時讀取其他檔案。然而，SKILL.md 的簡潔性仍然重要：一旦 Claude 載入它，每個 token 都與對話歷史和其他 context 競爭。

**預設假設**：Claude 已經非常聰明

只添加 Claude 還沒有的 context。對每條資訊提出挑戰：

* 「Claude 真的需要這個解釋嗎？」
* 「我可以假設 Claude 已知道這個嗎？」
* 「這個段落值得它的 token 成本嗎？」

**好範例：簡潔**（約 50 tokens）：

````markdown  theme={null}
## 提取 PDF 文字

使用 pdfplumber 進行文字提取：

```python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````

**差範例：過於冗長**（約 150 tokens）：

```markdown  theme={null}
## 提取 PDF 文字

PDF（可攜式文件格式）檔案是一種常見的檔案格式，包含文字、圖片和其他內容。
要從 PDF 提取文字，你需要使用函式庫。有許多可用的 PDF 處理函式庫，
但我們推薦 pdfplumber，因為它易於使用且能處理大多數情況。
首先，你需要使用 pip 安裝它。然後你可以使用下面的程式碼...
```

簡潔版本假設 Claude 知道 PDF 是什麼以及函式庫如何運作。

### 設定適當的自由度

根據任務的脆弱性和可變性，匹配具體程度的層級。

**高自由度**（文字型說明）：

使用時機：

* 多種方法都有效
* 決策取決於 context
* 啟發式方法引導方向

範例：

```markdown  theme={null}
## 程式碼審查流程

1. 分析程式碼結構和組織
2. 檢查潛在的錯誤或邊緣案例
3. 建議改善可讀性和可維護性
4. 驗證是否符合專案慣例
```

**中等自由度**（帶參數的偽程式碼或腳本）：

使用時機：

* 存在偏好的模式
* 某些變化是可接受的
* 設定會影響行為

範例：

````markdown  theme={null}
## 生成報告

使用此模板並按需自訂：

```python
def generate_report(data, format="markdown", include_charts=True):
    # 處理資料
    # 以指定格式生成輸出
    # 選擇性包含視覺化
```
````

**低自由度**（具體腳本，少量或無參數）：

使用時機：

* 操作脆弱且容易出錯
* 一致性至關重要
* 必須遵循特定序列

範例：

````markdown  theme={null}
## 資料庫遷移

執行這個確切的腳本：

```bash
python scripts/migrate.py --verify --backup
```

不要修改命令或添加額外的 flags。
````

**比喻**：把 Claude 想像成一個探索路徑的機器人：

* **兩側有懸崖的窄橋**：只有一條安全的前進路徑。提供具體的護欄和確切說明（低自由度）。範例：必須按確切順序執行的資料庫遷移。
* **沒有危險的開闊田野**：許多路徑都能成功。給出大致方向，相信 Claude 能找到最佳路線（高自由度）。範例：context 決定最佳方法的程式碼審查。

### 對你計劃使用的所有模型進行測試

Skills 是對模型的補充，因此效果取決於底層模型。對你計劃使用的所有模型測試你的 Skill。

**依模型的測試考量**：

* **Claude Haiku**（快速、經濟）：Skill 是否提供了足夠的引導？
* **Claude Sonnet**（均衡）：Skill 是否清晰且高效？
* **Claude Opus**（強大推理）：Skill 是否避免了過度解釋？

對 Opus 完美有效的內容可能需要為 Haiku 提供更多細節。如果你計劃在多個模型中使用你的 Skill，請以對所有模型都能良好運作為目標。

## Skill 結構

<Note>
  **YAML Frontmatter**：SKILL.md frontmatter 需要兩個欄位：

  * `name` — Skill 的人類可讀名稱（最多 64 個字元）
  * `description` — Skill 功能和何時使用的單行描述（最多 1024 個字元）

  完整的 Skill 結構細節，請參閱 [Skills 概覽](/en/docs/agents-and-tools/agent-skills/overview#skill-structure)。
</Note>

### 命名慣例

使用一致的命名模式，使 Skills 更容易被引用和討論。我們建議為 Skill 名稱使用**動名詞形式**（動詞 + -ing），因為這能清楚描述 Skill 提供的活動或能力。

**好的命名範例（動名詞形式）**：

* 「Processing PDFs」
* 「Analyzing spreadsheets」
* 「Managing databases」
* 「Testing code」
* 「Writing documentation」

**可接受的替代方式**：

* 名詞短語：「PDF Processing」、「Spreadsheet Analysis」
* 動作導向：「Process PDFs」、「Analyze Spreadsheets」

**避免**：

* 模糊名稱：「Helper」、「Utils」、「Tools」
* 過於通用：「Documents」、「Data」、「Files」
* 你的 skill 集合中不一致的模式

一致的命名使以下事項更容易：

* 在文件和對話中引用 Skills
* 一眼了解 Skill 的功能
* 組織和搜尋多個 Skills
* 維護專業、連貫的 skill 函式庫

### 撰寫有效的 descriptions

`description` 欄位啟用 Skill 的可發現性，應包含 Skill 的功能以及何時使用。

<Warning>
  **始終以第三人稱撰寫**。description 被注入系統提示，不一致的人稱可能導致發現問題。

  * **好：**「Processes Excel files and generates reports」
  * **避免：**「I can help you process Excel files」
  * **避免：**「You can use this to process Excel files」
</Warning>

**具體說明並包含關鍵術語**。包含 Skill 的功能以及何時使用的具體觸發器/context。

每個 Skill 只有一個 description 欄位。description 對於 skill 選擇至關重要：Claude 使用它從可能超過 100 個可用 Skills 中選擇正確的 Skill。你的 description 必須提供足夠的細節，讓 Claude 知道何時選擇這個 Skill，而 SKILL.md 的其餘部分提供實作細節。

有效範例：

**PDF Processing skill：**

```yaml  theme={null}
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

**Excel Analysis skill：**

```yaml  theme={null}
description: Analyze Excel spreadsheets, create pivot tables, generate charts. Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files.
```

**Git Commit Helper skill：**

```yaml  theme={null}
description: Generate descriptive commit messages by analyzing git diffs. Use when the user asks for help writing commit messages or reviewing staged changes.
```

避免如下模糊的 descriptions：

```yaml  theme={null}
description: Helps with documents
```

```yaml  theme={null}
description: Processes data
```

```yaml  theme={null}
description: Does stuff with files
```

### 漸進式揭露模式

SKILL.md 作為概覽，根據需要引導 Claude 取得詳細資料，就像入職指南中的目錄。有關漸進式揭露運作方式的說明，請參閱概覽中的 [Skills 運作方式](/en/docs/agents-and-tools/agent-skills/overview#how-skills-work)。

**實用指導：**

* 保持 SKILL.md 本文在 500 行以內以獲得最佳效能
* 接近此限制時，將內容拆分為獨立檔案
* 使用以下模式有效組織說明、程式碼和資源

#### 視覺概覽：從簡單到複雜

基本 Skill 從一個包含元資料和說明的 SKILL.md 檔案開始：

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=87782ff239b297d9a9e8e1b72ed72db9" alt="顯示 YAML frontmatter 和 markdown 本文的簡單 SKILL.md 檔案" data-og-width="2048" width="2048" data-og-height="1153" height="1153" data-path="images/agent-skills-simple-file.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=c61cc33b6f5855809907f7fda94cd80e 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=90d2c0c1c76b36e8d485f49e0810dbfd 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=ad17d231ac7b0bea7e5b4d58fb4aeabb 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=f5d0a7a3c668435bb0aee9a3a8f8c329 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=0e927c1af9de5799cfe557d12249f6e6 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=46bbb1a51dd4c8202a470ac8c80a893d 2500w" />

隨著你的 Skill 成長，你可以捆綁 Claude 只在需要時才載入的額外內容：

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=a5e0aa41e3d53985a7e3e43668a33ea3" alt="捆綁額外參考檔案，如 reference.md 和 forms.md。" data-og-width="2048" width="2048" data-og-height="1327" height="1327" data-path="images/agent-skills-bundling-content.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=f8a0e73783e99b4a643d79eac86b70a2 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=dc510a2a9d3f14359416b706f067904a 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=82cd6286c966303f7dd914c28170e385 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=56f3be36c77e4fe4b523df209a6824c6 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=d22b5161b2075656417d56f41a74f3dd 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=3dd4bdd6850ffcc96c6c45fcb0acd6eb 2500w" />

完整的 Skill 目錄結構可能如下所示：

```
pdf/
├── SKILL.md              # 主要說明（觸發時載入）
├── FORMS.md              # 填表指南（按需載入）
├── reference.md          # API 參考（按需載入）
├── examples.md           # 使用範例（按需載入）
└── scripts/
    ├── analyze_form.py   # 實用腳本（執行，不載入）
    ├── fill_form.py      # 填表腳本
    └── validate.py       # 驗證腳本
```

#### 模式 1：高層次指南搭配參考

````markdown  theme={null}
---
name: PDF Processing
description: Extracts text and tables from PDF files, fills forms, and merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---

# PDF Processing

## 快速開始

使用 pdfplumber 提取文字：
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

## 進階功能

**填表**：完整指南請參閱 [FORMS.md](FORMS.md)
**API 參考**：所有方法請參閱 [REFERENCE.md](REFERENCE.md)
**範例**：常見模式請參閱 [EXAMPLES.md](EXAMPLES.md)
````

Claude 只在需要時才載入 FORMS.md、REFERENCE.md 或 EXAMPLES.md。

#### 模式 2：領域特定的組織

對於具有多個領域的 Skills，按領域組織內容以避免載入不相關的 context。當使用者詢問銷售指標時，Claude 只需要讀取銷售相關的結構描述，而不是財務或行銷資料。這讓 token 使用量低且 context 專注。

```
bigquery-skill/
├── SKILL.md（概覽和導覽）
└── reference/
    ├── finance.md（收入、帳單指標）
    ├── sales.md（商機、管道）
    ├── product.md（API 使用量、功能）
    └── marketing.md（行銷活動、歸因）
```

````markdown SKILL.md theme={null}
# BigQuery 資料分析

## 可用資料集

**財務**：收入、ARR、帳單 → 參閱 [reference/finance.md](reference/finance.md)
**銷售**：商機、管道、帳戶 → 參閱 [reference/sales.md](reference/sales.md)
**產品**：API 使用量、功能、採用率 → 參閱 [reference/product.md](reference/product.md)
**行銷**：行銷活動、歸因、電子郵件 → 參閱 [reference/marketing.md](reference/marketing.md)

## 快速搜尋

使用 grep 查找特定指標：

```bash
grep -i "revenue" reference/finance.md
grep -i "pipeline" reference/sales.md
grep -i "api usage" reference/product.md
```
````

#### 模式 3：條件式細節

顯示基本內容，連結到進階內容：

```markdown  theme={null}
# DOCX Processing

## 建立文件

使用 docx-js 建立新文件。參閱 [DOCX-JS.md](DOCX-JS.md)。

## 編輯文件

對於簡單的編輯，直接修改 XML。

**追蹤修訂**：參閱 [REDLINING.md](REDLINING.md)
**OOXML 細節**：參閱 [OOXML.md](OOXML.md)
```

Claude 只在使用者需要這些功能時才讀取 REDLINING.md 或 OOXML.md。

### 避免深度巢狀參考

從其他參考檔案引用時，Claude 可能只部分讀取檔案。遇到巢狀參考時，Claude 可能使用 `head -100` 等命令預覽內容而非讀取完整檔案，導致資訊不完整。

**從 SKILL.md 保持參考一層深**。所有參考檔案應直接從 SKILL.md 連結，以確保 Claude 在需要時讀取完整檔案。

**差範例：太深**：

```markdown  theme={null}
# SKILL.md
參閱 [advanced.md](advanced.md)...

# advanced.md
參閱 [details.md](details.md)...

# details.md
這是實際資訊...
```

**好範例：一層深**：

```markdown  theme={null}
# SKILL.md

**基本使用**：[SKILL.md 中的說明]
**進階功能**：參閱 [advanced.md](advanced.md)
**API 參考**：參閱 [reference.md](reference.md)
**範例**：參閱 [examples.md](examples.md)
```

### 對較長的參考檔案使用目錄

對於超過 100 行的參考檔案，在頂部包含目錄。這確保即使在部分讀取預覽時，Claude 也能看到可用資訊的完整範圍。

**範例**：

```markdown  theme={null}
# API 參考

## 目錄
- 驗證與設定
- 核心方法（建立、讀取、更新、刪除）
- 進階功能（批次操作、webhooks）
- 錯誤處理模式
- 程式碼範例

## 驗證與設定
...

## 核心方法
...
```

Claude 然後可以讀取完整檔案或根據需要跳轉到特定章節。

有關此基於檔案系統的架構如何啟用漸進式揭露的詳細資訊，請參閱下方進階章節中的[執行環境](#runtime-environment)。

## 工作流程和回饋迴圈

### 對複雜任務使用工作流程

將複雜操作分解為清晰的順序步驟。對於特別複雜的工作流程，提供一個清單，讓 Claude 可以複製到其回應中並在進展時打勾。

**範例 1：研究綜合工作流程**（針對沒有程式碼的 Skills）：

````markdown  theme={null}
## 研究綜合工作流程

複製此清單並追蹤你的進度：

```
研究進度：
- [ ] 步驟 1：閱讀所有來源文件
- [ ] 步驟 2：識別關鍵主題
- [ ] 步驟 3：交叉參考主張
- [ ] 步驟 4：建立結構化摘要
- [ ] 步驟 5：驗證引用
```

**步驟 1：閱讀所有來源文件**

審查 `sources/` 目錄中的每個文件。記下主要論點和支持證據。

**步驟 2：識別關鍵主題**

尋找來源之間的模式。哪些主題反覆出現？來源在哪裡同意或不同意？

**步驟 3：交叉參考主張**

對於每個主要主張，驗證它出現在來源材料中。記下哪個來源支持每個觀點。

**步驟 4：建立結構化摘要**

按主題組織發現。包括：
- 主要主張
- 來源的支持證據
- 衝突的觀點（如果有的話）

**步驟 5：驗證引用**

檢查每個主張是否引用了正確的來源文件。如果引用不完整，返回步驟 3。
````

此範例展示了如何將工作流程應用於不需要程式碼的分析任務。清單模式適用於任何複雜的多步驟流程。

**範例 2：PDF 填表工作流程**（針對有程式碼的 Skills）：

````markdown  theme={null}
## PDF 填表工作流程

複製此清單並在完成時打勾：

```
任務進度：
- [ ] 步驟 1：分析表單（執行 analyze_form.py）
- [ ] 步驟 2：建立欄位對應（編輯 fields.json）
- [ ] 步驟 3：驗證對應（執行 validate_fields.py）
- [ ] 步驟 4：填寫表單（執行 fill_form.py）
- [ ] 步驟 5：驗證輸出（執行 verify_output.py）
```

**步驟 1：分析表單**

執行：`python scripts/analyze_form.py input.pdf`

這會提取表單欄位及其位置，儲存到 `fields.json`。

**步驟 2：建立欄位對應**

編輯 `fields.json`，為每個欄位添加值。

**步驟 3：驗證對應**

執行：`python scripts/validate_fields.py fields.json`

在繼續之前修正任何驗證錯誤。

**步驟 4：填寫表單**

執行：`python scripts/fill_form.py input.pdf fields.json output.pdf`

**步驟 5：驗證輸出**

執行：`python scripts/verify_output.py output.pdf`

如果驗證失敗，返回步驟 2。
````

清楚的步驟防止 Claude 跳過關鍵驗證。清單幫助 Claude 和你追蹤多步驟工作流程的進度。

### 實作回饋迴圈

**常見模式**：執行驗證器 → 修正錯誤 → 重複

此模式大幅改善輸出品質。

**範例 1：風格指南合規**（針對沒有程式碼的 Skills）：

```markdown  theme={null}
## 內容審查流程

1. 按照 STYLE_GUIDE.md 中的指南起草你的內容
2. 根據清單審查：
   - 檢查術語一致性
   - 驗證範例遵循標準格式
   - 確認所有必要章節都存在
3. 如果發現問題：
   - 記下每個問題及具體章節參考
   - 修訂內容
   - 再次審查清單
4. 只有當所有要求都滿足時才繼續
5. 完成並儲存文件
```

這展示了使用參考文件而非腳本的驗證迴圈模式。「驗證器」是 STYLE\_GUIDE.md，Claude 通過閱讀和比較來執行檢查。

**範例 2：文件編輯流程**（針對有程式碼的 Skills）：

```markdown  theme={null}
## 文件編輯流程

1. 對 `word/document.xml` 進行編輯
2. **立即驗證**：`python ooxml/scripts/validate.py unpacked_dir/`
3. 如果驗證失敗：
   - 仔細審查錯誤訊息
   - 修正 XML 中的問題
   - 再次執行驗證
4. **只有驗證通過時才繼續**
5. 重新打包：`python ooxml/scripts/pack.py unpacked_dir/ output.docx`
6. 測試輸出文件
```

驗證迴圈及早發現錯誤。

## 內容指南

### 避免時效性資訊

不要包含會過時的資訊：

**差範例：時效性**（會變錯）：

```markdown  theme={null}
如果你在 2025 年 8 月之前這樣做，使用舊的 API。
2025 年 8 月之後，使用新的 API。
```

**好範例**（使用「舊模式」章節）：

```markdown  theme={null}
## 當前方法

使用 v2 API endpoint：`api.example.com/v2/messages`

## 舊模式

<details>
<summary>Legacy v1 API（已於 2025-08 棄用）</summary>

v1 API 使用：`api.example.com/v1/messages`

此 endpoint 不再受支援。
</details>
```

舊模式章節提供歷史 context，不會使主要內容雜亂。

### 使用一致的術語

選擇一個術語並在整個 Skill 中使用：

**好 — 一致**：

* 始終用「API endpoint」
* 始終用「field」
* 始終用「extract」

**差 — 不一致**：

* 混用「API endpoint」、「URL」、「API route」、「path」
* 混用「field」、「box」、「element」、「control」
* 混用「extract」、「pull」、「get」、「retrieve」

一致性幫助 Claude 理解和遵循說明。

## 常見模式

### 範本模式

為輸出格式提供範本。根據你的需求匹配嚴格程度。

**對於嚴格要求**（如 API 回應或資料格式）：

````markdown  theme={null}
## 報告結構

始終使用此確切的範本結構：

```markdown
# [分析標題]

## 執行摘要
[關鍵發現的一段概覽]

## 關鍵發現
- 帶有支持資料的發現 1
- 帶有支持資料的發現 2
- 帶有支持資料的發現 3

## 建議
1. 具體可行的建議
2. 具體可行的建議
```
````

**對於靈活指引**（當調整有用時）：

````markdown  theme={null}
## 報告結構

以下是合理的預設格式，但請根據分析使用你的最佳判斷：

```markdown
# [分析標題]

## 執行摘要
[概覽]

## 關鍵發現
[根據你發現的內容調整章節]

## 建議
[針對具體 context 量身定制]
```

根據具體的分析類型按需調整章節。
````

### 範例模式

對於輸出品質取決於看到範例的 Skills，提供輸入/輸出對，就像在一般提示中一樣：

````markdown  theme={null}
## commit 訊息格式

按照這些範例生成 commit 訊息：

**範例 1：**
輸入：Added user authentication with JWT tokens
輸出：
```
feat(auth): implement JWT-based authentication

Add login endpoint and token validation middleware
```

**範例 2：**
輸入：Fixed bug where dates displayed incorrectly in reports
輸出：
```
fix(reports): correct date formatting in timezone conversion

Use UTC timestamps consistently across report generation
```

**範例 3：**
輸入：Updated dependencies and refactored error handling
輸出：
```
chore: update dependencies and refactor error handling

- Upgrade lodash to 4.17.21
- Standardize error response format across endpoints
```

遵循此風格：type(scope): 簡短描述，然後是詳細說明。
````

範例幫助 Claude 比單純的描述更清楚地理解所需的風格和細節程度。

### 條件式工作流程模式

引導 Claude 通過決策點：

```markdown  theme={null}
## 文件修改工作流程

1. 確定修改類型：

   **建立新內容？** → 遵循下方「建立工作流程」
   **編輯現有內容？** → 遵循下方「編輯工作流程」

2. 建立工作流程：
   - 使用 docx-js 函式庫
   - 從頭建立文件
   - 匯出為 .docx 格式

3. 編輯工作流程：
   - 解壓縮現有文件
   - 直接修改 XML
   - 每次更改後驗證
   - 完成後重新打包
```

<Tip>
  如果工作流程變得很大或有很多步驟，考慮將它們推入獨立檔案，並告訴 Claude 根據手邊的任務讀取適當的檔案。
</Tip>

## 評估與迭代

### 先建立評估

**在撰寫大量文件之前先建立評估。** 這確保你的 Skill 解決真實問題，而非記錄想像中的問題。

**評估驅動開發：**

1. **識別空缺**：在沒有 Skill 的情況下對代表性任務執行 Claude。記錄具體的失敗或缺失的 context
2. **建立評估**：建立三個測試這些空缺的情境
3. **建立基線**：測量沒有 Skill 時 Claude 的表現
4. **撰寫最少說明**：建立剛好足以解決空缺並通過評估的內容
5. **迭代**：執行評估，與基線比較，並精煉

此方法確保你在解決真實問題，而非預測可能永遠不會出現的需求。

**評估結構**：

```json  theme={null}
{
  "skills": ["pdf-processing"],
  "query": "Extract all text from this PDF file and save it to output.txt",
  "files": ["test-files/document.pdf"],
  "expected_behavior": [
    "Successfully reads the PDF file using an appropriate PDF processing library or command-line tool",
    "Extracts text content from all pages in the document without missing any pages",
    "Saves the extracted text to a file named output.txt in a clear, readable format"
  ]
}
```

<Note>
  此範例展示了帶有簡單測試標準的資料驅動評估。我們目前不提供執行這些評估的內建方式。使用者可以建立自己的評估系統。評估是衡量 Skill 效果的真實依據。
</Note>

### 與 Claude 迭代開發 Skills

最有效的 Skill 開發過程涉及 Claude 本身。與一個 Claude 實例（「Claude A」）合作建立一個將被其他實例（「Claude B」）使用的 Skill。Claude A 幫助你設計和精煉說明，而 Claude B 在真實任務中測試它們。這之所以有效，是因為 Claude 模型理解如何撰寫有效的代理說明以及代理需要什麼資訊。

**建立新 Skill：**

1. **在沒有 Skill 的情況下完成任務**：與 Claude A 使用一般提示完成一個問題。在工作過程中，你自然會提供 context、解釋偏好和分享程序知識。注意你反覆提供的資訊。

2. **識別可重複使用的模式**：完成任務後，識別你提供的 context 哪些對類似的未來任務有用。

   **範例**：如果你完成了一個 BigQuery 分析，你可能提供了表格名稱、欄位定義、篩選規則（如「始終排除測試帳號」）和常見查詢模式。

3. **請 Claude A 建立 Skill**：「建立一個 Skill，捕捉我們剛剛使用的 BigQuery 分析模式。包含表格結構描述、命名慣例和關於篩選測試帳號的規則。」

   <Tip>
     Claude 模型原生理解 Skill 格式和結構。你不需要特殊的系統提示或「撰寫 skills」技巧來讓 Claude 幫助建立 Skills。只需請 Claude 建立 Skill，它就會生成帶有適當 frontmatter 和本文內容的結構化 SKILL.md。
   </Tip>

4. **審查簡潔性**：檢查 Claude A 是否添加了不必要的解釋。問：「刪除關於 win rate 是什麼意思的解釋——Claude 已經知道了。」

5. **改善資訊架構**：請 Claude A 更有效地組織內容。例如：「組織這個，讓表格結構描述在獨立的參考檔案中。我們之後可能會添加更多表格。」

6. **對類似任務測試**：使用 Claude B（載入了 Skill 的新實例）對相關使用案例使用 Skill。觀察 Claude B 是否找到正確資訊、正確應用規則並成功處理任務。

7. **根據觀察迭代**：如果 Claude B 掙扎或遺漏了什麼，帶著具體情況回到 Claude A：「Claude 使用這個 Skill 時，忘記按日期篩選 Q4。我們應該添加一個關於日期篩選模式的章節嗎？」

**迭代現有 Skills：**

改善 Skills 時繼續相同的階層模式。你在以下之間交替：

* **與 Claude A 合作**（幫助精煉 Skill 的專家）
* **與 Claude B 測試**（使用 Skill 執行真實工作的代理）
* **觀察 Claude B 的行為**並將洞察帶回 Claude A

1. **在真實工作流程中使用 Skill**：給 Claude B（載入了 Skill）實際任務，而非測試情境

2. **觀察 Claude B 的行為**：注意它在哪裡掙扎、成功或做出意外選擇

   **範例觀察**：「當我要求 Claude B 提供區域銷售報告時，它撰寫了查詢但忘記篩選測試帳號，即使 Skill 提到了這個規則。」

3. **回到 Claude A 進行改善**：分享當前的 SKILL.md 並描述你觀察到的內容。問：「我注意到當我要求區域報告時，Claude B 忘記篩選測試帳號。Skill 提到了篩選，但也許不夠突出？」

4. **審查 Claude A 的建議**：Claude A 可能建議重組以使規則更突出，使用更強的語言如「MUST filter」而非「always filter」，或重構工作流程章節。

5. **應用並測試更改**：用 Claude A 的精煉更新 Skill，然後對類似請求再次用 Claude B 測試

6. **根據使用情況重複**：隨著你遇到新情境，繼續這個觀察-精煉-測試循環。每次迭代都基於真實的代理行為（而非假設）改善 Skill。

**收集團隊回饋：**

1. 與隊友分享 Skills 並觀察他們的使用方式
2. 問：Skill 在預期時觸發嗎？說明是否清楚？缺少什麼？
3. 整合回饋以解決你自己使用模式中的盲點

**為什麼這個方法有效**：Claude A 理解代理需求，你提供領域專業知識，Claude B 通過真實使用揭示差距，迭代精煉根據觀察到的行為（而非假設）改善 Skills。

### 觀察 Claude 如何導覽 Skills

在迭代 Skills 時，注意 Claude 在實踐中實際如何使用它們。觀察：

* **意外的探索路徑**：Claude 是否以你未預料的順序讀取檔案？這可能表明你的結構不如你想的直觀
* **遺漏的連結**：Claude 是否無法跟隨到重要檔案的參考？你的連結可能需要更明確或更突出
* **過度依賴某些章節**：如果 Claude 反覆讀取同一個檔案，考慮該內容是否應該放在主 SKILL.md 中
* **被忽略的內容**：如果 Claude 從未存取一個捆綁的檔案，它可能是不必要的或在主要說明中信號不佳

基於這些觀察而非假設進行迭代。你 Skill 元資料中的「name」和「description」特別關鍵。Claude 在決定是否根據當前任務觸發 Skill 時使用這些。確保它們清楚描述 Skill 的功能以及何時應該使用。

## 要避免的反模式

### 避免 Windows 風格路徑

始終在檔案路徑中使用正斜線，即使在 Windows 上：

* ✓ **好**：`scripts/helper.py`、`reference/guide.md`
* ✗ **避免**：`scripts\helper.py`、`reference\guide.md`

Unix 風格路徑在所有平台上都有效，而 Windows 風格路徑在 Unix 系統上會導致錯誤。

### 避免提供太多選項

不要在不必要的情況下提供多種方法：

````markdown  theme={null}
**差範例：太多選擇**（令人困惑）：
「你可以使用 pypdf，或 pdfplumber，或 PyMuPDF，或 pdf2image，或...」

**好範例：提供預設**（帶有逃脫出口）：
「使用 pdfplumber 進行文字提取：
```python
import pdfplumber
```

對於需要 OCR 的掃描 PDF，改用 pdf2image 搭配 pytesseract。」
````

## 進階：帶有可執行程式碼的 Skills

以下章節專注於包含可執行腳本的 Skills。如果你的 Skill 只使用 markdown 說明，請跳至[有效 Skills 的清單](#checklist-for-effective-skills)。

### 解決問題，而非推卸給 Claude

在為 Skills 撰寫腳本時，處理錯誤條件，而非將其推卸給 Claude。

**好範例：明確處理錯誤**：

```python  theme={null}
def process_file(path):
    """處理一個檔案，如果不存在則建立它。"""
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        # 建立帶有預設內容的檔案，而非失敗
        print(f"File {path} not found, creating default")
        with open(path, 'w') as f:
            f.write('')
        return ''
    except PermissionError:
        # 提供替代方案，而非失敗
        print(f"Cannot access {path}, using default")
        return ''
```

**差範例：推卸給 Claude**：

```python  theme={null}
def process_file(path):
    # 直接失敗並讓 Claude 想辦法
    return open(path).read()
```

設定參數也應該有理由和文件，以避免「魔法常數」（Ousterhout 定律）。如果你不知道正確的值，Claude 如何確定它？

**好範例：自我文件化**：

```python  theme={null}
# HTTP 請求通常在 30 秒內完成
# 較長的超時考慮慢速連線
REQUEST_TIMEOUT = 30

# 三次重試在可靠性與速度之間取得平衡
# 大多數間歇性失敗在第二次重試前解決
MAX_RETRIES = 3
```

**差範例：魔法數字**：

```python  theme={null}
TIMEOUT = 47  # 為什麼是 47？
RETRIES = 5   # 為什麼是 5？
```

### 提供實用腳本

即使 Claude 可以撰寫腳本，預製腳本也有優勢：

**實用腳本的優點**：

* 比生成的程式碼更可靠
* 節省 tokens（不需要在 context 中包含程式碼）
* 節省時間（不需要生成程式碼）
* 確保跨次使用的一致性

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=4bbc45f2c2e0bee9f2f0d5da669bad00" alt="將可執行腳本與說明檔案一起捆綁" data-og-width="2048" width="2048" data-og-height="1154" height="1154" data-path="images/agent-skills-executable-scripts.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=9a04e6535a8467bfeea492e517de389f 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=e49333ad90141af17c0d7651cca7216b 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=954265a5df52223d6572b6214168c428 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=2ff7a2d8f2a83ee8af132b29f10150fd 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=48ab96245e04077f4d15e9170e081cfb 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=0301a6c8b3ee879497cc5b5483177c90 2500w" />

上圖顯示可執行腳本如何與說明檔案一起運作。說明檔案（forms.md）引用腳本，Claude 可以在不將其內容載入 context 的情況下執行它。

**重要區別**：在你的說明中明確 Claude 應該：

* **執行腳本**（最常見）：「執行 `analyze_form.py` 以提取欄位」
* **作為參考讀取**（對於複雜邏輯）：「參閱 `analyze_form.py` 了解欄位提取算法」

對於大多數實用腳本，執行是首選，因為它更可靠和高效。有關腳本執行運作方式的詳細資訊，請參閱下方的[執行環境](#runtime-environment)章節。

**範例**：

````markdown  theme={null}
## 實用腳本

**analyze_form.py**：從 PDF 提取所有表單欄位

```bash
python scripts/analyze_form.py input.pdf > fields.json
```

輸出格式：
```json
{
  "field_name": {"type": "text", "x": 100, "y": 200},
  "signature": {"type": "sig", "x": 150, "y": 500}
}
```

**validate_boxes.py**：檢查重疊的邊界框

```bash
python scripts/validate_boxes.py fields.json
# 回傳：「OK」或列出衝突
```

**fill_form.py**：將欄位值應用到 PDF

```bash
python scripts/fill_form.py input.pdf fields.json output.pdf
```
````

### 使用視覺分析

當輸入可以渲染為圖片時，讓 Claude 分析它們：

````markdown  theme={null}
## 表單版面分析

1. 將 PDF 轉換為圖片：
   ```bash
   python scripts/pdf_to_images.py form.pdf
   ```

2. 分析每個頁面圖片以識別表單欄位
3. Claude 可以視覺化地看到欄位位置和類型
````

<Note>
  在此範例中，你需要撰寫 `pdf_to_images.py` 腳本。
</Note>

Claude 的視覺能力幫助理解版面和結構。

### 建立可驗證的中間輸出

當 Claude 執行複雜的開放式任務時，它可能犯錯。「計劃-驗證-執行」模式通過讓 Claude 首先以結構化格式建立計劃，然後在執行之前用腳本驗證該計劃，及早發現錯誤。

**範例**：想像請 Claude 根據試算表更新 PDF 中的 50 個表單欄位。如果沒有驗證，Claude 可能引用不存在的欄位、建立衝突的值、遺漏必填欄位或錯誤應用更新。

**解決方案**：使用上述工作流程模式（PDF 填表），但添加一個在應用更改之前驗證的中間 `changes.json` 檔案。工作流程變為：分析 → **建立計劃檔案** → **驗證計劃** → 執行 → 驗證。

**為什麼此模式有效：**

* **及早發現錯誤**：驗證在應用更改之前找到問題
* **機器可驗證**：腳本提供客觀驗證
* **可逆規劃**：Claude 可以迭代計劃而不碰原始檔案
* **清晰的除錯**：錯誤訊息指向具體問題

**使用時機**：批次操作、破壞性更改、複雜驗證規則、高風險操作。

**實作提示**：使用具體錯誤訊息使驗證腳本冗長，如「Field 'signature\_date' not found. Available fields: customer\_name, order\_total, signature\_date\_signed」，以幫助 Claude 修正問題。

### 套件依賴

Skills 在具有平台特定限制的程式碼執行環境中執行：

* **claude.ai**：可以從 npm 和 PyPI 安裝套件，並從 GitHub 儲存庫拉取
* **Anthropic API**：沒有網路存取和執行時套件安裝

在你的 SKILL.md 中列出所需套件，並在[程式碼執行工具文件](/en/docs/agents-and-tools/tool-use/code-execution-tool)中驗證它們是否可用。

### 執行環境

Skills 在具有檔案系統存取、bash 命令和程式碼執行能力的程式碼執行環境中執行。有關此架構的概念解釋，請參閱概覽中的 [Skills 架構](/en/docs/agents-and-tools/agent-skills/overview#the-skills-architecture)。

**這如何影響你的撰寫：**

**Claude 如何存取 Skills：**

1. **元資料預先載入**：啟動時，所有 Skills 的 YAML frontmatter 中的名稱和 description 都被載入系統提示
2. **按需讀取檔案**：Claude 使用 bash Read 工具根據需要從檔案系統存取 SKILL.md 和其他檔案
3. **高效執行腳本**：實用腳本可以通過 bash 執行，而無需將其完整內容載入 context。只有腳本的輸出消耗 tokens
4. **大型檔案無 context 懲罰**：參考檔案、資料或文件在實際讀取之前不消耗 context tokens

* **檔案路徑很重要**：Claude 像文件系統一樣導覽你的 skill 目錄。使用正斜線（`reference/guide.md`），而非反斜線
* **描述性地命名檔案**：使用指示內容的名稱：`form_validation_rules.md`，而非 `doc2.md`
* **按領域組織以便發現**：按領域或功能構建目錄
  * 好：`reference/finance.md`、`reference/sales.md`
  * 差：`docs/file1.md`、`docs/file2.md`
* **捆綁全面的資源**：包含完整的 API 文件、大量範例、大型資料集；在存取之前沒有 context 懲罰
* **優先使用腳本進行確定性操作**：撰寫 `validate_form.py` 而非請 Claude 生成驗證程式碼
* **明確說明執行意圖**：
  * 「執行 `analyze_form.py` 以提取欄位」（執行）
  * 「參閱 `analyze_form.py` 了解提取算法」（作為參考讀取）
* **測試檔案存取模式**：通過使用真實請求測試，驗證 Claude 可以導覽你的目錄結構

**範例：**

```
bigquery-skill/
├── SKILL.md（概覽，指向參考檔案）
└── reference/
    ├── finance.md（收入指標）
    ├── sales.md（管道資料）
    └── product.md（使用分析）
```

當使用者詢問收入時，Claude 讀取 SKILL.md，看到對 `reference/finance.md` 的參考，並調用 bash 只讀取那個檔案。sales.md 和 product.md 保留在檔案系統中，消耗零 context tokens，直到需要時。這個基於檔案系統的模型使漸進式揭露成為可能。Claude 可以導覽和選擇性地載入每個任務所需的確切內容。

有關技術架構的完整詳細資訊，請參閱 Skills 概覽中的 [Skills 運作方式](/en/docs/agents-and-tools/agent-skills/overview#how-skills-work)。

### MCP 工具參考

如果你的 Skill 使用 MCP（Model Context Protocol）工具，始終使用完整限定的工具名稱以避免「找不到工具」錯誤。

**格式**：`ServerName:tool_name`

**範例**：

```markdown  theme={null}
使用 BigQuery:bigquery_schema 工具檢索表格結構描述。
使用 GitHub:create_issue 工具建立 issues。
```

其中：

* `BigQuery` 和 `GitHub` 是 MCP 伺服器名稱
* `bigquery_schema` 和 `create_issue` 是這些伺服器中的工具名稱

沒有伺服器前綴，Claude 可能無法定位工具，尤其是在有多個 MCP 伺服器可用時。

### 避免假設工具已安裝

不要假設套件可用：

````markdown  theme={null}
**差範例：假設已安裝**：
「使用 pdf 函式庫處理檔案。」

**好範例：明確說明依賴項**：
「安裝所需套件：`pip install pypdf`

然後使用它：
```python
from pypdf import PdfReader
reader = PdfReader("file.pdf")
```"
````

## 技術注記

### YAML Frontmatter 要求

SKILL.md frontmatter 需要 `name`（最多 64 個字元）和 `description`（最多 1024 個字元）欄位。完整的結構細節，請參閱 [Skills 概覽](/en/docs/agents-and-tools/agent-skills/overview#skill-structure)。

### Token 預算

保持 SKILL.md 本文在 500 行以內以獲得最佳效能。如果你的內容超過此限制，使用前面描述的漸進式揭露模式將其拆分為獨立檔案。有關架構細節，請參閱 [Skills 概覽](/en/docs/agents-and-tools/agent-skills/overview#how-skills-work)。

## 有效 Skills 的清單

分享 Skill 之前，驗證：

### 核心品質

* [ ] Description 具體並包含關鍵術語
* [ ] Description 包含 Skill 的功能和何時使用
* [ ] SKILL.md 本文在 500 行以內
* [ ] 額外細節在獨立檔案中（如果需要）
* [ ] 無時效性資訊（或在「舊模式」章節中）
* [ ] 全文術語一致
* [ ] 範例具體，而非抽象
* [ ] 檔案參考一層深
* [ ] 適當使用漸進式揭露
* [ ] 工作流程步驟清晰

### 程式碼和腳本

* [ ] 腳本解決問題，而非推卸給 Claude
* [ ] 錯誤處理明確且有幫助
* [ ] 沒有「魔法常數」（所有值都有理由）
* [ ] 所需套件在說明中列出並驗證可用
* [ ] 腳本有清楚的文件
* [ ] 無 Windows 風格路徑（全部正斜線）
* [ ] 關鍵操作包含驗證/確認步驟
* [ ] 品質關鍵任務包含回饋迴圈

### 測試

* [ ] 至少建立三個評估
* [ ] 使用 Haiku、Sonnet 和 Opus 測試
* [ ] 使用真實使用情境測試
* [ ] 整合團隊回饋（如果適用）

## 後續步驟

<CardGroup cols={2}>
  <Card title="開始使用 Agent Skills" icon="rocket" href="/en/docs/agents-and-tools/agent-skills/quickstart">
    建立你的第一個 Skill
  </Card>

  <Card title="在 Claude Code 中使用 Skills" icon="terminal" href="/en/docs/claude-code/skills">
    在 Claude Code 中建立和管理 Skills
  </Card>

  <Card title="通過 API 使用 Skills" icon="code" href="/en/api/skills-guide">
    以程式方式上傳和使用 Skills
  </Card>
</CardGroup>
