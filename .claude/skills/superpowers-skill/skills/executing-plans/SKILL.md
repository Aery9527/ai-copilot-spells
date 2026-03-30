---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
source: superpowers/skills/executing-plans/SKILL.md
---

## 概述

在獨立的對話 session 中，載入已寫好的實作計畫並逐步執行，含 checkpoint review。適合在沒有 subagent 支援的環境，或需要跨 session 繼續執行的情境。

## 能做什麼

- 載入並批判性地 review 計畫文件
- 逐 task 執行（標記 in_progress → completed）
- 遇到阻塞時停下詢問，不猜測
- 所有 task 完成後呼叫 `finishing-a-development-branch`

## 解決什麼問題

計畫執行時「跳步」或「假設未知細節」導致的品質問題；在不同 session 中繼續執行計畫的需求。

## 何時使用（觸發條件）

- 有已寫好的計畫文件（`docs/superpowers/plans/` 下）
- 在新的 session 開始執行計畫時
- 不需要每個 task 後都進行 review 的情境
- 平台無 subagent 支援時的替代方案

## 關鍵技術棧

搭配 `subagent-driven-development`（同 session 執行時更優）；計畫由 `writing-plans` 產出。

## 重要注意事項

- 有 subagent 支援時，優先使用 `subagent-driven-development`（品質更高）。
- 遇到任何阻塞（missing dependency、測試失敗、指令不清楚）立即停下詢問，不要強行繼續。
- 先 review 計畫再執行；有疑慮先提出，不要默默跳過問題步驟。
