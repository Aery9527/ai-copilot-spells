---
name: systematic-debugging
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
source: superpowers/skills/systematic-debugging/SKILL.md
---

## 概述

遇到任何 bug、測試失敗或非預期行為時，強制先完成根因調查再提出修復的流程 skill。核心原則：症狀修復等於失敗；隨機嘗試修復會製造新 bug 並掩蓋真正問題。

## 能做什麼

- 四階段除錯：根因調查 → 假設形成 → 修復設計 → 驗證
- 仔細閱讀 error message（不跳過、不假設）
- 建立可一致重現的最小重現案例
- 驗證修復確實解決根因（非症狀）

## 解決什麼問題

「打補丁打了三次還沒好」；隨機嘗試修復浪費時間且掩蓋真正問題；在時間壓力下更容易做出導致更多問題的猜測性修復。

## 何時使用（觸發條件）

- 任何測試失敗
- 任何 bug 回報
- 任何效能問題
- 任何建置失敗
- 任何整合問題
- **尤其是**在時間壓力下（壓力讓猜測更誘人）

## 關鍵技術棧

各平台 debugger、log 分析工具、git bisect（用於回歸定位）。

## 重要注意事項

- **Iron Law**：`NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST`。
- 未完成 Phase 1（根因調查），不得提出任何修復。
- 「看起來很明顯的修復」也要先找根因。
- 在時間壓力下更要遵守（系統性方法比亂試更快）。
