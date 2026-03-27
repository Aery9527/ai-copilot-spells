---
name: plan-extension
description: 補強所有規劃情境的強制守則。只要使用者提到 `/plan`、plan、規劃、proposal、approach、implementation plan、design plan、refactor plan、spec、roadmap、先拆需求、先提方案、先不要做先規劃，或任何「先想清楚再做」的意圖，就應優先使用此 skill；**寧可多觸發，不要漏觸發**。此 skill 會把正式計畫固定寫進 `docs-plan\{topic}-plan.md`（統一視為 `@docs-plan`）、要求先使用 `write-md` 來撰寫/更新 Markdown，並要求每份 plan 都包含可確認的「測試與驗收標準」，必要時用 Mermaid 視覺化，再拿給使用者確認。
---

# Plan Extension

此 skill 是所有規劃請求的補充守則，目的不是取代原本的規劃流程，而是把正式 plan 的落點、文件撰寫方式與驗收定義統一起來。

---

## 核心原則

### 1. 觸發策略要偏積極

- 只要使用者意圖是「先規劃、先分析、先設計、先提方案、先拆需求、先定驗收」，就應觸發此 skill。
- 不要把觸發條件限縮成只有 `/plan` 指令。
- **寧可多觸發一次，也不要漏掉正式規劃。**
- 若你正在猶豫某句話算不算規劃，預設答案是「算」。

常見應觸發說法：

- `/plan`
- 「先幫我規劃」
- 「先不要做，先提方案」
- 「先給我 implementation plan」
- 「先整理 design / spec / roadmap」
- 「先拆需求」
- 「先想清楚再動手」
- 「先列驗收標準」
- 「先寫成文件給我 review」

### 2. 正式 plan 一律寫在 `@docs-plan`

- 將 `@docs-plan` 視為 repo 內正式的 plan 文件位置。
- `@docs-plan` 固定代表 `docs-plan\` 目錄，不再寫到 `docs\`。
- 預設路徑為 `docs-plan\{topic}-plan.md`。
- 若是延續既有議題，優先更新既有的 `docs-plan\*-plan.md`，不要重複開新檔。
- 若執行環境另外要求維護 session `plan.md` 或 SQL todos，照做；但**給使用者確認與後續協作的正式文件仍以 `@docs-plan` 為準**。
- 不要因為目錄暫時不存在、或看到舊的 `docs\*-plan.md` 慣例，就把新的正式 plan 改寫到別處。

### 3. 寫 plan 前先使用 `write-md`

- 只要要建立或更新 `@docs-plan` 的 Markdown 文件，就先使用 `write-md` skill。
- `write-md` 負責 Markdown 結構、語言規範與 Mermaid 使用判斷。
- 不要跳過 `write-md` 直接草率寫 Markdown。
- `plan-extension` 決定「要不要做正式規劃」與「plan 要長什麼樣」，`write-md` 負責「如何把 Markdown 寫好」。

### 4. 每份 plan 都必須有「測試與驗收標準」

- 不能只寫一句「之後補測試」或「跑測試確認」。
- 必須明確列出使用者可以拿來確認的驗收條件。
- 寫完後，必須在回覆中摘要這些條件，並請使用者確認是否接受。
- 若驗收方向會影響方案內容（例如要不要做 migration、要不要保證 backward compatibility、要驗證哪些 failure path），在定稿前先用 `ask_user` 問清楚。

---

## `@docs-plan` 命名規則

預設使用：

```text
docs-plan\{topic}-plan.md
```

規則：

- `{topic}` 使用 kebab-case
- 名稱描述「問題/主題」，不要描述低階操作
- 優先簡短且可搜尋，例如：
  - `docs-plan\retry-flow-refactor-plan.md`
  - `docs-plan\data-model-split-plan.md`
  - `docs-plan\api-versioning-plan.md`

若不確定檔名，用目前需求主題生成一個最直觀的名稱即可，不要為了檔名反覆卡住。

---

## 工作流程

### Step 1: 判斷是否進入正式規劃

以下情境直接視為應套用此 skill：

- 使用者明確輸入 `/plan`
- 使用者說「先不要做，先規劃」
- 使用者要你先產出 implementation plan / design plan / refactor plan
- 使用者要你把規劃寫成文件
- 使用者要求先定驗收標準、先拆需求、先想清楚再實作
- 任務明顯跨多檔案、多階段，且使用者要先確認方案

### Step 2: 決定 `@docs-plan`

1. 先找 repo 內是否已有同議題的 `docs-plan\*-plan.md`
2. 若有，更新既有檔案
3. 若沒有，建立新的 `docs-plan\{topic}-plan.md`
4. 在回覆中明確告知使用者目前的 `@docs-plan` 是哪一份

### Step 3: 先使用 `write-md`

在建立或更新 `@docs-plan` 之前，先 invoke `write-md` skill，並遵守其規則：

- 文件正文預設使用繁體中文
- 先起草 Markdown 結構，再補內容
- 對每個章節判斷是否需要 Mermaid
- 只有在圖能明顯降低理解難度時才加 Mermaid

### Step 4: 撰寫 plan 內容

建議至少包含以下章節：

```markdown
# {主題}

## 問題與目標

## 範圍

## 方案概述

## 影響檔案 / 模組

## 風險與待確認事項

## 測試與驗收標準
```

可依需求補充：

- `## 現況分析`
- `## 資料流 / 架構`
- `## 分階段實作`
- `## 回滾 / 相容性策略`

### 撰寫要求

- 方案要能讓後續實作者直接接手，不要只寫抽象方向
- 若已有明顯技術限制或依賴，直接寫在 plan 裡，不要埋在對話中
- 若有多個方案，應交代取捨理由，不要只列選項

### Mermaid 使用規則

Mermaid 不是固定必備，但在下列情境應優先考慮：

- 多個模組或服務之間的相依關係不直觀
- 資料流、狀態轉換、流程分支難以用文字追蹤
- 規劃涉及跨 ≥3 個角色/元件的互動

不需要 Mermaid 的情境：

- 單純條列 TODO 就已經夠清楚
- 只有 2–3 個線性步驟
- 圖只是在重述文字

若需要圖，交給 `write-md` 的規則來選 `flowchart TD`、`sequenceDiagram`、`stateDiagram-v2` 等適合的圖型。

### `測試與驗收標準` 章節要求

此章節至少要讓人回答下面問題：

- 要驗證什麼行為？
- 用什麼方式驗證？（unit test、integration test、manual check、CI、資料比對……）
- 要跑什麼指令或操作什麼步驟？
- 看到什麼結果才算通過？
- 是否有重要的邊界條件、失敗情境或相容性檢查？

優先使用表格，格式例如：

```markdown
## 測試與驗收標準

| 驗收項目 | 測試方式 | 指令 / 步驟 | 預期結果 |
|---------|---------|------------|---------|
| API 回傳新欄位正確 | integration test | `go test ./...` | 測試通過，response schema 含新欄位 |
| 舊資料不被破壞 | manual + regression | 以既有資料跑查詢比對 | 舊欄位語意不變，結果與改版前一致 |
| 錯誤路徑可觀測 | manual | 模擬缺少設定啟動服務 | 啟動失敗且錯誤訊息含缺失 key |
```

若目前沒有可直接執行的自動化測試，也必須寫出具體 manual 驗收步驟；不要空著。

### 驗收項目的預設思路

依任務類型至少涵蓋：

- **程式碼功能變更**：happy path、主要錯誤路徑、回歸風險
- **資料結構 / migration**：新舊資料相容性、回填或查詢結果一致性
- **腳本 / 自動化**：成功案例、重跑行為、錯誤輸入
- **文件 / 規範**：內容完整性、範例可用性、讀者是否能依文件操作

---

## 與使用者確認的方式

寫完 `@docs-plan` 後，不要只說「plan 已完成」。

你應該在回覆中：

1. 明確指出 `@docs-plan` 路徑
2. 摘要方案重點
3. 列出或摘要 `測試與驗收標準`
4. 請使用者確認這些驗收條件是否符合預期
5. 若有使用 Mermaid，順手說明圖在幫助讀者理解哪一段結構或流程

如果存在重大不確定性，優先用 `ask_user` 聚焦詢問，例如：

- 是否要把 backward compatibility 視為必要驗收項？
- 是否需要把 migration 驗證納入此次規劃？
- 驗收以單元測試為主，還是需要端到端流程？

---

## 什麼不算完成

以下情況都不算完成 plan：

- 只把內容寫進 session `plan.md`，沒有落到 repo 的 `docs-plan\*-plan.md`
- 沒有 `測試與驗收標準` 章節
- 驗收標準只有模糊敘述，沒有步驟或預期結果
- 沒有把驗收條件拿給使用者確認
- 沒有先使用 `write-md` 就直接寫 Markdown
- 明明結構或流程很複雜，卻完全沒考慮 Mermaid 是否能降低理解成本

---

## 範例

**使用者：**

```text
/plan 幫我規劃統計欄位拆分
```

**你應該做的事：**

1. 建立或更新 `docs-plan\data-model-split-plan.md`
2. 在動手寫檔前先使用 `write-md`
3. 在 plan 中寫清楚資料模型方案、影響模組、相容性風險
4. 若資料流或模組互動難追蹤，考慮補 Mermaid
5. 補上 `測試與驗收標準`，例如：
   - 新舊資料相容性驗證
   - 舊查詢或舊 API 語意不變
   - 新欄位可被下游模組正確讀取
6. 回覆使用者：plan 已寫到哪裡，並請對驗收標準做確認

---

## 與其他規則的關係

- 若宿主環境已有 `/plan`、`[[PLAN]]`、session `plan.md`、SQL todo 追蹤等規則，**全部照常執行**
- 此 skill 負責補上三件事：
  - 正式 plan 文件要落在 `@docs-plan`
  - 寫 plan 時要先使用 `write-md`
  - 驗收標準必須成為 plan 的固定輸出，且需要使用者確認
