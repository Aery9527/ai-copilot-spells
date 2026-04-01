---
name: mongo-guidelines
description: >-
  MongoDB 開發守則與陷阱防範。任何涉及 MongoDB 查詢、aggregation pipeline、
  Go mongo-go-driver 程式碼、或 MongoDB shell 腳本（.js）的開發任務都應使用此 skill。
  涵蓋：JS shell 中 NumberLong/ISODate 等型別的隱性比對陷阱、Go 中 bson.M 與 bson.D
  的正確使用時機（尤其 $sort/$group 等依賴順序的場景）、以及「優先 aggregation
  單次請求 vs 多次指令」的決策原則與文件記錄規範。
  當需要新增、修改、review 任何 MongoDB 相關程式碼時，務必先讀完此 skill 再動手。
---

# MongoDB 開發守則

## Overview

防範 MongoDB 常見陷阱、規範 BSON 型別選用與 aggregation 決策，確保每一次 MongoDB 操作
都是型別安全、低 round-trip、且意圖明確的。

---

## 守則一：型別安全 — 比對前先確認型別

MongoDB 的型別系統在不同語境（shell JS、Go driver、BSON wire protocol）之間存在隱性轉換，
任何比對或 key 操作前，必須明確確認目標型別。

### JavaScript / Mongo Shell

MongoDB shell 回傳的數值可能是 `NumberLong`（BSON Int64），它是一個**物件**，不是原生 JS number。

**最常見的陷阱：用 NumberLong 當 Object key**

```js
// 錯誤 — NumberLong 作為 Object key 時呼叫 .toString()
//    產生 "NumberLong(260128)"，parseInt("NumberLong(260128)") → NaN
const targetSet = {};
dc.targets.forEach(function(t) {
    targetSet[t] = true;               // key = "NumberLong(260128)" ← 看不出來的 bug
});
const yymmdd = parseInt(key, 10);      // NaN → collection name 錯誤 → 靜默漏查

// 正確 — 明確轉為 JS number 再用作 key
dc.targets.forEach(function(t) {
    targetSet[Number(t)] = true;       // key = "260128" ✓
});
```

**其他 NumberLong 陷阱**

```js
// 嚴格相等 — NumberLong 是物件，=== 永遠 false
if (doc.yymmdd === 260205) { ... }     // 永遠 false → 改用 Number(doc.yymmdd) === 260205

// 算術 — NumberLong 不自動轉型
var next = doc.yymmdd + 1;            // "[object Object]1" → 改用 Number(doc.yymmdd) + 1
```

**ISODate 比對**

```js
// ISODate 是物件，直接用 < > 比對即可（有實作 valueOf）
if (doc.createdAt >= ISODate("2026-02-01T00:00:00Z")) { ... }  // OK

// 禁止字串化後比對 — toString() 格式不穩定
if (doc.createdAt.toString() > "2026-02-01") { ... }  // 結果不確定
```

> 每次在 shell 腳本處理 cursor 結果時，凡涉及數值欄位，先印出 `typeof` 或觀察 shell 輸出是否顯示 `NumberLong(...)`，若是，後續所有使用該欄位的地方都要 `Number()` 包裹。

### Go / mongo-go-driver

```go
// BSON 型別對應（常見）
// MongoDB Int32  ↔  Go int32   / primitive.Int32
// MongoDB Int64  ↔  Go int64   / primitive.Int64
// MongoDB Double ↔  Go float64
// MongoDB Date   ↔  Go time.Time / primitive.DateTime
// MongoDB OID    ↔  Go primitive.ObjectID

// 錯誤：用 int 查 Int64 欄位可能不 match（int 預設編碼為 Int32）
filter := bson.M{"yymmdd": 260205}        // 可能被編碼為 Int32

// 正確：明確指定 Int64
filter := bson.M{"yymmdd": int64(260205)}

// 錯誤：用 string 查 ObjectID 欄位
filter := bson.M{"_id": "507f1f77bcf86cd799439011"}

// 正確：先解析成 primitive.ObjectID
oid, _ := primitive.ObjectIDFromHex("507f1f77bcf86cd799439011")
filter := bson.M{"_id": oid}
```

---

## 守則二：bson.M vs bson.D — 依賴順序才用 bson.D

| 類型 | 底層結構 | 特性 | 用途 |
|------|---------|------|------|
| `bson.M` | `map[string]any` | **無序** | filter、projection、`$match` 條件 |
| `bson.D` | `[]bson.E`（有序 slice） | **有序** | `$sort`、依賴宣告順序的 aggregation stage |

**使用 bson.D 的判斷標準：操作結果是否依賴宣告順序？**

```go
// 錯誤 — $sort 用 bson.M，map 無序，sort key 優先順序不確定（難復現的 bug）
bson.M{"$sort": bson.M{"day": 1, "user": -1}}

// 正確 — $sort 用 bson.D，保證 day 優先於 user 排序
bson.D{{Key: "$sort", Value: bson.D{
    {Key: "day", Value: 1},
    {Key: "user", Value: -1},
}}}

// Aggregation pipeline 正確寫法
pipeline := mongo.Pipeline{
    bson.D{{Key: "$match",  Value: bson.M{"flag": 0}}},          // $match 內部無序 → bson.M
    bson.D{{Key: "$group",  Value: bson.D{
        {Key: "_id",   Value: "$user"},
        {Key: "count", Value: bson.M{"$sum": 1}},
    }}},
    bson.D{{Key: "$sort",   Value: bson.D{{Key: "count", Value: -1}}}}, // $sort → bson.D
    bson.D{{Key: "$limit",  Value: 10}},
}
```

**快速口訣**：
- `$sort` → 永遠 `bson.D`
- filter / `$match` 條件 → `bson.M`（除非欄位順序有業務意義）
- 整個 pipeline 本身 → `mongo.Pipeline`（`[]bson.D`）

---

## 守則三：評估查詢策略，按情境選擇最適方式

每次實作 MongoDB 操作前，先做情境分析，再決定採用 aggregation 或多次指令。
**沒有放諸四海皆準的答案**，下表提供明確傾向與需要抉擇的指引。

### 明確傾向 Aggregation 的情境

| 情境 | 原因 |
|------|------|
| 跨 collection join | `$lookup` 在 server 端完成，避免 N+1 |
| 跨多個 collection 合併結果 | `$unionWith` 單次回傳，避免多次 round-trip |
| 聚合統計（count/sum/avg） | `$group` 一次掃描即完成，多次查詢無法替代 |
| 動態 collection 名稱的跨集合查詢 | 只有 aggregation 能動態組裝 `$unionWith` stages |
| 分頁 | `$skip + $limit` 在 server 端限制資料量 |

### 明確傾向多次指令的情境

| 情境 | 原因 |
|------|------|
| 需要 transaction 寫入 | aggregation 無法在 `session.WithTransaction` 中執行寫入 |
| 業務邏輯依賴上一步結果再決定操作 | 例如「先查版本號 → 條件 upsert」，分支邏輯無法在 pipeline 表達 |
| 單純 CRUD（單 doc insert/update/delete） | 直接指令更清晰，aggregation 反而增加複雜度 |

### 無明顯傾向時 — 列出優缺點供使用者抉擇

當情境不屬於上述任何一類時（例如：少量跨集合查詢、已有現成多次指令的邏輯要不要重構），
**不自行決定，先呈現分析**：

```
方案 A：Aggregation 單次 pipeline
  優點：
    - 1 次 round-trip，延遲低
    - Server-side 過濾，回傳資料量小
  缺點：
    - Pipeline 複雜度高，debug 較困難
    - 若資料量小，效能差異可忽略，pipeline 反而增加維護成本

方案 B：多次指令（Find × N）
  優點：
    - 邏輯直觀，易讀易 debug
    - 每步結果可獨立 log/驗證
  缺點：
    - N+1 風險；資料量大時延遲明顯
    - 需自行在應用層做 join/merge

建議：[若有傾向給出建議，否則由使用者依可維護性/效能需求決定]
```

---

## 守則四：每個 MongoDB 任務必須聲明執行策略

實作任何 MongoDB 操作前，**先在 code comment 或說明中聲明**：

```go
// 查詢策略：Aggregation（單次 pipeline）
// 原因：需跨 gp_{yymmdd}_detail 多個 collection 合併結果，
//        透過 $unionWith 動態組裝 stages，避免 N 次 Find 請求。
```

```go
// 查詢策略：多次指令（Find + UpdateOne）
// 原因：需 optimistic lock — 先讀取版本號，比對後再條件更新，
//        無法在單一 aggregation 中完成寫入。
```

```js
// 查詢策略：Aggregation（$unionWith 動態多 collection）
// 原因：detail 分散在 gp_YYMMDD_detail 各日期 collection，
//        加上 DetailConsume 跨日 target，必須 server-side 合併後再 $match。
```

**聲明格式**：
```
查詢策略：<Aggregation 單次 pipeline | 多次指令 | 混合>
原因：<一句話說明為何選擇此策略，或無法用 aggregation 的限制>
```

---

## 快速 Checklist（每次 MongoDB 任務前過一遍）

- [ ] 所有從 cursor/結果取出的數值欄位，是否確認過型別（尤其 NumberLong / Int64）？
- [ ] 有無將 NumberLong/BSON 物件直接用作 map key、陣列 index 或算術？
- [ ] Go 程式碼中，`$sort`、依賴順序的 aggregation stage，是否使用 `bson.D`？
- [ ] 是否做過情境分析，確認用 aggregation 或多次指令（若無明顯傾向，是否已列出優缺點）？
- [ ] 是否已在 comment 中聲明「查詢策略」與原因？
