---
name: plan-extension
description: 補強所有規劃情境的強制守則。只要使用者提到 `/plan`、plan、規劃、proposal、approach、implementation plan、design plan、refactor plan、spec、roadmap、先拆需求、先提方案、先不要做先規劃，或任何「先想清楚再做」的意圖，就應優先使用此 skill；**寧可多觸發，不要漏觸發**。此 skill 會把正式計畫固定寫進 `docs-plan\{topic}-plan.md`（統一視為 `@docs-plan`）、要求先使用 `write-md` 來撰寫/更新 Markdown，**強制 TDD — 每個實作階段必須先設計測試案例再寫實作代碼**，並要求每份 plan 都包含可確認的「測試設計」與「驗收標準」，必要時用 Mermaid 視覺化，再拿給使用者確認。
---

# Plan Extension

此 skill 是所有規劃請求的補充守則，目的不是取代原本的規劃流程，而是把正式 plan 的落點、文件撰寫方式、**TDD 測試先行流程**與驗收定義統一起來。

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
- 預設路徑為 `docs-plan\{topic}-plan.md`（方案文件）與 `docs-plan\{topic}-plan-test.md`（測試文件）。
- **測試相關內容一律寫在 `{topic}-plan-test.md`**，不要混在 plan 本體中。兩份文件互相引用。
- 若是延續既有議題，優先更新既有的 `docs-plan\*-plan.md` 與 `*-plan-test.md`，不要重複開新檔。
- 若執行環境另外要求維護 session `plan.md` 或 SQL todos，照做；但**給使用者確認與後續協作的正式文件仍以 `@docs-plan` 為準**。
- 不要因為目錄暫時不存在、或看到舊的 `docs\*-plan.md` 慣例，就把新的正式 plan 改寫到別處。

### 3. 寫 plan 前先使用 `write-md`

- 只要要建立或更新 `@docs-plan` 的 Markdown 文件，就先使用 `write-md` skill。
- `write-md` 負責 Markdown 結構、語言規範與 Mermaid 使用判斷。
- 不要跳過 `write-md` 直接草率寫 Markdown。
- `plan-extension` 決定「要不要做正式規劃」與「plan 要長什麼樣」，`write-md` 負責「如何把 Markdown 寫好」。

### 4. 每份 plan 都必須有配套的測試文件

- 每份 `{topic}-plan.md` 都必須有對應的 `{topic}-plan-test.md`。
- **所有測試相關內容（測試設計、test case、驗收標準）一律寫在 test 文件**，不要混進 plan 本體。
- Plan 本體只需在「分階段實作」中引用 test 文件的 test case 編號，不重複展開內容。
- 不能只寫一句「之後補測試」或「跑測試確認」。
- 寫完後，必須在回覆中摘要測試文件的內容，並請使用者確認是否接受。
- 若驗收方向會影響方案內容（例如要不要做 migration、要不要保證 backward compatibility、要驗證哪些 failure path），在定稿前先用 `ask_user` 問清楚。

### 5. 強制 TDD — 測試先行

本專案的所有程式碼規劃都必須遵循 **Test-Driven Development** 流程。測試不是實作完的補充品，而是驅動設計與實作的第一步。

**TDD 循環**：

```
寫測試（Red）→ 看到測試失敗 → 寫最少實作讓測試通過（Green）→ 重構（Refactor）
```

**對 plan 的具體要求**：

1. **測試設計寫在獨立的 test 文件**：所有 test case 定義、驗收標準都寫在 `{topic}-plan-test.md`，plan 本體透過引用 test case 編號來串接。
2. **測試設計必須在實作方案之前完成**：先寫完 test 文件，再回頭完善 plan 的實作方案。先定義「怎麼驗證」再決定「怎麼寫」。
3. **每個實作階段都必須先定義 test case**：不允許出現「Phase N: 實作 X」卻沒有對應 test case 的情況。每個 phase 的第一步永遠是「撰寫 X 的測試」。
4. **Test case 必須具體到可直接撰寫**：必須列出測試函式名稱、測試情境（場景描述 + 輸入 + 預期輸出）、以及要驗證的邊界條件。不能只寫「測試 X 功能」這種模糊描述。
5. **測試案例驅動介面設計**：在寫測試的過程中，會自然逼出函式簽名、介面定義、輸入輸出格式。test 文件應記錄這些被測試「逼出來」的設計決策。
6. **失敗路徑與邊界條件是一等公民**：每個功能的 test case 至少要涵蓋 happy path、主要 error path、以及已知的邊界條件。不能只測 happy path。

---

## `@docs-plan` 命名規則

預設使用：

```text
docs-plan\{topic}-plan.md         ← 方案文件
docs-plan\{topic}-plan-test.md    ← 測試文件
```

規則：

- `{topic}` 使用 kebab-case
- 名稱描述「問題/主題」，不要描述低階操作
- 兩份文件的 `{topic}` 必須一致
- 優先簡短且可搜尋，例如：
  - `docs-plan\retry-flow-refactor-plan.md` + `docs-plan\retry-flow-refactor-plan-test.md`
  - `docs-plan\data-model-split-plan.md` + `docs-plan\data-model-split-plan-test.md`

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

1. 先找 repo 內是否已有同議題的 `docs-plan\*-plan.md` 與 `*-plan-test.md`
2. 若有，更新既有檔案
3. 若沒有，建立新的 `docs-plan\{topic}-plan.md` 與 `docs-plan\{topic}-plan-test.md`
4. 在回覆中明確告知使用者目前的 `@docs-plan` 是哪一對檔案

### Step 3: 先使用 `write-md`

在建立或更新 `@docs-plan` 之前，先 invoke `write-md` skill，並遵守其規則：

- 文件正文預設使用繁體中文
- 先起草 Markdown 結構，再補內容
- 對每個章節判斷是否需要 Mermaid
- 只有在圖能明顯降低理解難度時才加 Mermaid

### Step 4: 撰寫 plan 內容

建議至少包含以下章節：

**`{topic}-plan.md`（方案文件）**：

```markdown
# {主題}

## 問題與目標

## 範圍

## 方案概述

## 分階段實作（TDD）

## 影響檔案 / 模組

## 風險與待確認事項
```

**`{topic}-plan-test.md`（測試文件）**：

```markdown
# {主題} — 測試設計

## 測試總覽

## 測試設計

### Phase 1: {階段名稱}

### Phase 2: {階段名稱}

## 驗收標準
```

可依需求在 plan 中補充：

- `## 現況分析`
- `## 資料流 / 架構`
- `## 回滾 / 相容性策略`

> **兩份文件的關係**：plan 的「分階段實作」引用 test 文件的 test case 編號（如 `Test Case 1-1`）；test 文件的 Phase 劃分必須與 plan 一致。先完成 test 文件，再回頭寫 plan 的實作方案。

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

### `測試設計` 章節要求（寫在 test 文件）

這是整份規劃中**最重要的內容**，不是附錄。它定義了整份 plan 的品質門檻，且獨立存放在 `{topic}-plan-test.md`。

#### 結構

每個實作階段（Phase）都必須有對應的 test case 區塊，格式如下：

```markdown
## 測試設計

### Phase 1: {階段名稱}

#### Test Case 1-1: {測試函式名稱}

- **場景**：{一句話描述測試情境}
- **前置條件**：{測試開始前需要的狀態/資料}
- **操作**：{呼叫什麼函式、傳入什麼參數}
- **預期結果**：{回傳值、狀態變化、side effect}
- **分類**：happy path / error path / 邊界條件

#### Test Case 1-2: {測試函式名稱}

...

### Phase 2: {階段名稱}

...
```

#### 必要內容

每個 test case 至少要回答：

1. **測試什麼行為？** — 不是「測試 X 模組」，而是「當 Y 條件下呼叫 Z，應該回傳 W」
2. **輸入是什麼？** — 具體的參數值或狀態，不是「一些測試資料」
3. **預期輸出是什麼？** — 具體的回傳值、錯誤類型、或狀態變化
4. **這是測 happy path 還是 error path？** — 明確標註分類

#### 涵蓋範圍要求

每個功能的 test case 至少涵蓋：

| 分類 | 最低要求 | 說明 |
|------|---------|------|
| Happy path | ≥ 1 個 | 正常流程的主要路徑 |
| Error path | ≥ 1 個 | 主要的錯誤情境（無效輸入、依賴失敗等） |
| 邊界條件 | 視情況 | nil/zero/empty、上限值、型別邊界等 |
| 回歸保護 | 視情況 | 確保既有行為不被破壞的測試 |

若某個 phase 沒有 error path（極罕見），必須在 plan 中明確說明原因。

### `分階段實作（TDD）` 章節要求（寫在 plan 文件）

每個 Phase 的結構必須遵循 TDD 循環，並引用 test 文件中的 test case：

```markdown
## 分階段實作（TDD）

### Phase 1: {階段名稱}

**Step 1 — 寫測試（Red）**

建立 `xxx_test.go`，實作 test 文件中以下 test case：
- Test Case 1-1: {簡述}
- Test Case 1-2: {簡述}

預期結果：編譯失敗或測試全部 FAIL（因為還沒有實作）。

**Step 2 — 最少實作（Green）**

建立/修改 `xxx.go`，實作最少代碼讓 Step 1 的測試全部通過。

**Step 3 — 重構（Refactor）**

在測試保護下重構，確保測試仍全部通過。
```

> **不允許出現沒有 Step 1（寫測試）的 Phase。** 如果某個 Phase 純粹是配置/文件變更不涉及程式碼，可以標註「此 Phase 無需 TDD」並說明原因。

### `驗收標準` 章節要求（寫在 test 文件）

此章節整合所有 Phase 的測試結果，作為最終驗收的 checklist：

至少要讓人回答以下問題：

- 所有 Phase 的測試是否全部通過？
- 用什麼方式驗證？（unit test、integration test、manual check、CI、資料比對……）
- 要跑什麼指令？
- 看到什麼結果才算通過？
- 是否有跨 Phase 的整合驗證？

優先使用表格，格式例如：

```markdown
## 驗收標準

| # | 驗收項目 | 對應 Phase | 測試方式 | 指令 / 步驟 | 預期結果 |
|---|---------|-----------|---------|------------|---------|
| 1 | API 回傳新欄位正確 | Phase 1 | unit test | `go test ./pkg/xxx/...` | 測試通過，response 含新欄位 |
| 2 | cost=0 不擋流程 | Phase 3 | unit test | `go test -run TestZeroCost ./...` | 餘額不足但 cost=0 時流程繼續 |
| 3 | 舊資料不被破壞 | Phase 1-2 | regression | 以既有測試跑全量 | 所有既有測試仍通過 |
| 4 | 錯誤路徑可觀測 | Phase 2 | manual | 模擬依賴失敗啟動服務 | 啟動失敗且錯誤訊息含具體 context |
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

1. 明確指出 `@docs-plan` 路徑（plan 文件與 test 文件各一）
2. 摘要方案重點
3. 列出或摘要 test 文件中「測試設計」的 test case 總覽（多少個 Phase、多少個 test case、覆蓋了哪些面向）
4. 列出或摘要 test 文件中「驗收標準」
5. 請使用者確認這些測試設計與驗收條件是否符合預期
6. 若有使用 Mermaid，順手說明圖在幫助讀者理解哪一段結構或流程

如果存在重大不確定性，優先用 `ask_user` 聚焦詢問，例如：

- 是否要把 backward compatibility 視為必要驗收項？
- 是否需要把 migration 驗證納入此次規劃？
- 驗收以單元測試為主，還是需要端到端流程？
- 某個 error path 的處理策略是什麼？（這會影響 test case 的預期結果）

---

## 什麼不算完成

以下情況都不算完成 plan：

- 只把內容寫進 session `plan.md`，沒有落到 repo 的 `docs-plan\*-plan.md`
- 沒有建立對應的 `{topic}-plan-test.md` 測試文件
- 測試內容混在 plan 本體中，沒有獨立到 test 文件
- 沒有 `測試設計` 章節（在 test 文件中）
- 沒有 `驗收標準` 章節（在 test 文件中）
- 測試設計只有模糊描述（例如「測試 X 功能」），沒有具體的場景、輸入、預期輸出
- 實作階段（Phase）沒有以「寫測試」作為第一步
- 某個 Phase 有實作內容但完全沒有對應的 test case
- 只測了 happy path，沒有 error path 或邊界條件
- 驗收標準只有模糊敘述，沒有指令或預期結果
- 沒有把測試設計與驗收條件拿給使用者確認
- 沒有先使用 `write-md` 就直接寫 Markdown
- 明明結構或流程很複雜，卻完全沒考慮 Mermaid 是否能降低理解成本

---

## 範例

**使用者：**

```text
/plan 幫我規劃統計欄位拆分
```

**你應該做的事：**

1. 建立或更新 `docs-plan\data-model-split-plan.md` 與 `docs-plan\data-model-split-plan-test.md`
2. 在動手寫檔前先使用 `write-md`
3. **先寫 test 文件 `data-model-split-plan-test.md`**：針對資料模型拆分，列出具體 test case：
   - 新 schema 寫入/讀取的 happy path
   - 舊資料相容性（migration 前後查詢結果一致）
   - 空值/邊界值處理
   - 下游模組讀取新欄位的整合測試
   - 驗收標準表格
4. **再寫 plan 文件 `data-model-split-plan.md`**：方案概述、分階段實作（引用 test case 編號）、影響模組、相容性風險
5. 若資料流或模組互動難追蹤，考慮補 Mermaid
6. 回覆使用者：兩份文件已寫到哪裡，摘要 test case 總覽，並請對測試設計與驗收標準做確認

---

## 與其他規則的關係

- 若宿主環境已有 `/plan`、`[[PLAN]]`、session `plan.md`、SQL todo 追蹤等規則，**全部照常執行**
- 此 skill 負責補上四件事：
  - 正式 plan 文件要落在 `@docs-plan`，測試內容獨立到 `{topic}-plan-test.md`
  - 寫 plan 與 test 文件時要先使用 `write-md`
  - **強制 TDD：先完成 test 文件，再寫 plan 的實作方案；每個 Phase 必須先寫測試**
  - 驗收標準必須寫在 test 文件中，且需要使用者確認
