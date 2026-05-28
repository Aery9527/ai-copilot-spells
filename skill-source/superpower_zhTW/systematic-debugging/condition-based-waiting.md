# 以條件為基礎的等待

## 概觀

Flaky tests 常用任意延遲去猜測 timing，這會造成 race condition：在快機器上能過，但在高負載或 CI 環境下就失敗。

**核心原則：** 等待你真正在乎的那個條件成立，而非猜測需要多久時間。

## 使用時機

```dot
digraph when_to_use {
    "Test uses setTimeout/sleep?" [shape=diamond];
    "Testing timing behavior?" [shape=diamond];
    "Document WHY timeout needed" [shape=box];
    "Use condition-based waiting" [shape=box];

    "Test uses setTimeout/sleep?" -> "Testing timing behavior?" [label="yes"];
    "Testing timing behavior?" -> "Document WHY timeout needed" [label="yes"];
    "Testing timing behavior?" -> "Use condition-based waiting" [label="no"];
}
```

**使用時機：**
- 測試含有任意延遲（`setTimeout`、`sleep`、`time.sleep()`）
- 測試不穩定（有時通過，高負載下失敗）
- 平行執行時測試逾時
- 等待非同步操作完成

**不適用時機：**
- 測試實際的 timing 行為（debounce、throttle 間隔）
- 若使用任意逾時，務必記錄原因

## 核心模式

```typescript
// ❌ BEFORE: Guessing at timing
await new Promise(r => setTimeout(r, 50));
const result = getResult();
expect(result).toBeDefined();

// ✅ AFTER: Waiting for condition
await waitFor(() => getResult() !== undefined);
const result = getResult();
expect(result).toBeDefined();
```

## 快速模式參考

| 情境 | 模式 |
|----------|---------|
| 等待事件 | `waitFor(() => events.find(e => e.type === 'DONE'))` |
| 等待狀態 | `waitFor(() => machine.state === 'ready')` |
| 等待數量 | `waitFor(() => items.length >= 5)` |
| 等待檔案 | `waitFor(() => fs.existsSync(path))` |
| 複雜條件 | `waitFor(() => obj.ready && obj.value > 10)` |

## 實作

通用輪詢函式：
```typescript
async function waitFor<T>(
  condition: () => T | undefined | null | false,
  description: string,
  timeoutMs = 5000
): Promise<T> {
  const startTime = Date.now();

  while (true) {
    const result = condition();
    if (result) return result;

    if (Date.now() - startTime > timeoutMs) {
      throw new Error(`Timeout waiting for ${description} after ${timeoutMs}ms`);
    }

    await new Promise(r => setTimeout(r, 10)); // Poll every 10ms
  }
}
```

完整實作含有領域特定的輔助函式（`waitForEvent`、`waitForEventCount`、`waitForEventMatch`），來自實際除錯 session，請見本目錄中的 `condition-based-waiting-example.ts`。

## 常見錯誤

**❌ 輪詢太頻繁：** `setTimeout(check, 1)` — 浪費 CPU
**✅ 修復：** 每 10ms 輪詢一次

**❌ 無逾時：** 若條件永遠未成立則無限循環
**✅ 修復：** 務必包含有清楚訊息的逾時

**❌ 過時資料：** 在迴圈外快取狀態
**✅ 修復：** 在迴圈內呼叫 getter 以取得最新資料

## 何時任意逾時是正確的

```typescript
// Tool ticks every 100ms - need 2 ticks to verify partial output
await waitForEvent(manager, 'TOOL_STARTED'); // First: wait for condition
await new Promise(r => setTimeout(r, 200));   // Then: wait for timed behavior
// 200ms = 2 ticks at 100ms intervals - documented and justified
```

**要求：**
1. 先等待觸發條件
2. 基於已知的 timing（非猜測）
3. 附上說明原因的註解

## 真實世界影響

來自除錯 session（2025-10-03）：
- 修復了 3 個檔案中的 15 個 flaky tests
- 通過率：60% → 100%
- 執行時間：快 40%
- 不再有 race condition
