// 以條件為基礎的等待工具函式完整實作
// 來源：Lace 測試基礎設施改善（2025-10-03）
// 背景：以條件等待取代任意逾時，修復了 15 個 flaky tests

import type { ThreadManager } from '~/threads/thread-manager';
import type { LaceEvent, LaceEventType } from '~/threads/types';

/**
 * 等待特定事件類型出現在 thread 中
 *
 * @param threadManager - 要查詢的 thread manager
 * @param threadId - 要檢查事件的 thread
 * @param eventType - 要等待的事件類型
 * @param timeoutMs - 最大等待時間（預設 5000ms）
 * @returns 解析為第一個符合事件的 Promise
 *
 * 範例：
 *   await waitForEvent(threadManager, agentThreadId, 'TOOL_RESULT');
 */
export function waitForEvent(
  threadManager: ThreadManager,
  threadId: string,
  eventType: LaceEventType,
  timeoutMs = 5000
): Promise<LaceEvent> {
  return new Promise((resolve, reject) => {
    const startTime = Date.now();

    const check = () => {
      const events = threadManager.getEvents(threadId);
      const event = events.find((e) => e.type === eventType);

      if (event) {
        resolve(event);
      } else if (Date.now() - startTime > timeoutMs) {
        reject(new Error(`Timeout waiting for ${eventType} event after ${timeoutMs}ms`));
      } else {
        setTimeout(check, 10); // 每 10ms 輪詢一次以兼顧效率
      }
    };

    check();
  });
}

/**
 * 等待特定數量的指定類型事件
 *
 * @param threadManager - 要查詢的 thread manager
 * @param threadId - 要檢查事件的 thread
 * @param eventType - 要等待的事件類型
 * @param count - 要等待的事件數量
 * @param timeoutMs - 最大等待時間（預設 5000ms）
 * @returns 達到指定數量後，解析為所有符合事件的 Promise
 *
 * 範例：
 *   // 等待 2 個 AGENT_MESSAGE 事件（初始回應 + 續接）
 *   await waitForEventCount(threadManager, agentThreadId, 'AGENT_MESSAGE', 2);
 */
export function waitForEventCount(
  threadManager: ThreadManager,
  threadId: string,
  eventType: LaceEventType,
  count: number,
  timeoutMs = 5000
): Promise<LaceEvent[]> {
  return new Promise((resolve, reject) => {
    const startTime = Date.now();

    const check = () => {
      const events = threadManager.getEvents(threadId);
      const matchingEvents = events.filter((e) => e.type === eventType);

      if (matchingEvents.length >= count) {
        resolve(matchingEvents);
      } else if (Date.now() - startTime > timeoutMs) {
        reject(
          new Error(
            `Timeout waiting for ${count} ${eventType} events after ${timeoutMs}ms (got ${matchingEvents.length})`
          )
        );
      } else {
        setTimeout(check, 10);
      }
    };

    check();
  });
}

/**
 * 等待符合自訂條件的事件
 * 適用於需要檢查事件資料而非僅檢查類型的情況
 *
 * @param threadManager - 要查詢的 thread manager
 * @param threadId - 要檢查事件的 thread
 * @param predicate - 當事件符合時回傳 true 的函式
 * @param description - 用於錯誤訊息的人類可讀描述
 * @param timeoutMs - 最大等待時間（預設 5000ms）
 * @returns 解析為第一個符合事件的 Promise
 *
 * 範例：
 *   // 等待具有特定 ID 的 TOOL_RESULT
 *   await waitForEventMatch(
 *     threadManager,
 *     agentThreadId,
 *     (e) => e.type === 'TOOL_RESULT' && e.data.id === 'call_123',
 *     'TOOL_RESULT with id=call_123'
 *   );
 */
export function waitForEventMatch(
  threadManager: ThreadManager,
  threadId: string,
  predicate: (event: LaceEvent) => boolean,
  description: string,
  timeoutMs = 5000
): Promise<LaceEvent> {
  return new Promise((resolve, reject) => {
    const startTime = Date.now();

    const check = () => {
      const events = threadManager.getEvents(threadId);
      const event = events.find(predicate);

      if (event) {
        resolve(event);
      } else if (Date.now() - startTime > timeoutMs) {
        reject(new Error(`Timeout waiting for ${description} after ${timeoutMs}ms`));
      } else {
        setTimeout(check, 10);
      }
    };

    check();
  });
}

// 來自實際除錯 session 的使用範例：
//
// 修改前（不穩定）：
// ---------------
// const messagePromise = agent.sendMessage('Execute tools');
// await new Promise(r => setTimeout(r, 300)); // 寄望工具在 300ms 內啟動
// agent.abort();
// await messagePromise;
// await new Promise(r => setTimeout(r, 50));  // 寄望結果在 50ms 內抵達
// expect(toolResults.length).toBe(2);         // 隨機失敗
//
// 修改後（可靠）：
// ----------------
// const messagePromise = agent.sendMessage('Execute tools');
// await waitForEventCount(threadManager, threadId, 'TOOL_CALL', 2); // 等待工具啟動
// agent.abort();
// await messagePromise;
// await waitForEventCount(threadManager, threadId, 'TOOL_RESULT', 2); // 等待結果
// expect(toolResults.length).toBe(2); // 永遠成功
//
// 結果：通過率 60% → 100%，執行速度快 40%
