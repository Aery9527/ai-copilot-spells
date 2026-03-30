---
name: subagent-driven-development
description: Use when executing implementation plans with independent tasks in the current session
source: superpowers/skills/subagent-driven-development/SKILL.md
---

## 概述

在當前 session 中，為計畫的每個 task 派遣一個全新的 subagent 執行，並在每個 task 後進行雙階段 review（spec 合規 → 程式碼品質）的執行方式。

## 能做什麼

- 每 task 一個新 subagent（無 context 污染）
- 雙階段 review：第一階段 spec 合規（實作符合需求嗎？）；第二階段程式碼品質
- 每個 task 完成後觸發 `requesting-code-review`
- 比 `executing-plans` 品質更高（更乾淨的 context、更細緻的 review）

## 解決什麼問題

在長 session 中 context 累積導致的遺忘與錯誤；需要頻繁 review 保持品質；「做了一大堆才發現方向錯了」的浪費。

## 何時使用（觸發條件）

- 有已寫好的實作計畫（`docs/superpowers/plans/` 下）
- Tasks 之間大致獨立
- 想在同一個 session 中執行（不需跨 session）
- 平台支援 subagent（Claude Code、Codex 等）

## 關鍵技術棧

`Agent` 工具；`superpowers:code-reviewer` subagent；`TaskCreate`/`TaskUpdate`。

## 重要注意事項

- **需要 subagent 支援**；無 subagent 時改用 `executing-plans`。
- Tasks 緊密耦合（後一個 task 需要前一個的中間狀態）時不適用。
- `subagent-driven-development`（同 session）vs `executing-plans`（跨 session 或無 subagent）。
- Subagent 不繼承當前 session 歷史；orchestrator 負責構建每個 subagent 所需的最小 context。
