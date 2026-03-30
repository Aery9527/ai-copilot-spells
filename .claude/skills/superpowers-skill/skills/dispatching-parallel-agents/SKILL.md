---
name: dispatching-parallel-agents
description: Use when facing 2+ independent tasks that can be worked on without shared state or sequential dependencies
source: superpowers/skills/dispatching-parallel-agents/SKILL.md
---

## 概述

面對 2 個以上獨立、無共享狀態的任務時，並行派遣多個專注 subagent 同時處理，縮短總時間並保持各自 context 乾淨的協作 skill。

## 能做什麼

- 判斷任務是否可平行（無共享狀態、可獨立理解）
- 為每個 subagent 精準構建隔離的 context（不繼承當前 session 歷史）
- 並行執行後整合各 subagent 的結果
- 決策流：多個失敗？→ 是否獨立？→ 是否可平行？→ 並行 dispatch

## 解決什麼問題

獨立問題依序調查浪費時間；多個測試失敗各自根因不同時的效率問題；context 污染（一個調查的中間結果影響下一個）。

## 何時使用（觸發條件）

- 3+ 個測試檔案各自失敗且根因不同時
- 多個子系統獨立損壞時
- 每個問題可以在不了解其他問題的情況下獨立理解時
- 各任務間無共享狀態

## 關鍵技術棧

`Agent` 工具（subagent 派遣）；`TaskCreate`/`TaskUpdate`（追蹤進度）。

## 重要注意事項

- Subagent **不應**繼承當前 session 的歷史 context；精確構建它所需的最小 context。
- 有共享狀態的任務**不可**平行（例：同一個 database migration 的多個步驟）。
- 平行結果整合是 orchestrator（當前 session）的工作，不是 subagent 的工作。
