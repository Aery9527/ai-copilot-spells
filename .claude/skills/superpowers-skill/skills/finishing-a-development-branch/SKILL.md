---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup
source: superpowers/skills/finishing-a-development-branch/SKILL.md
---

## 概述

實作完成、測試通過後，引導選擇適合的收尾方式（merge/PR/squash/cleanup）並執行的流程 skill。核心原則：驗證測試 → 提供選項 → 執行選擇 → 清理。

## 能做什麼

- 驗證測試套件通過（進入收尾前的 gate）
- 判斷 base branch（main/master/develop）
- 提供 merge/PR/squash merge/rebase 等選項
- 處理 branch cleanup（刪除 feature branch）

## 解決什麼問題

「我以為完成了，但忘了處理 branch cleanup」；不知道該 merge 還是開 PR 還是 squash；收尾流程不一致。

## 何時使用（觸發條件）

- 所有 task 完成且測試通過後
- `executing-plans` 或 `subagent-driven-development` 結束後
- 準備把功能整合到主線前

## 關鍵技術棧

`git merge`、`git rebase`、`git squash`；`gh pr create`（GitHub CLI）。

## 重要注意事項

- **必須先通過測試才能進入收尾流程**；測試失敗時停下，不繼續。
- 測試失敗時顯示具體失敗訊息，並告知「必須修復後才能收尾」。
- 選項呈現後等使用者選擇，不要自行假設。
