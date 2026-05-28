---
name: subagent-driven-development
description: Use when executing implementation plans with independent tasks in the current session
source: skill-source/superpowers/skills/subagent-driven-development/SKILL.md
---

## 概述

在當前 session 中，為計畫的每個 task 派遣一個全新 subagent 執行，並在每個 task 後進行雙階段 review（spec 合規 → 程式碼品質）的執行方式。核心原則：每 task 一個新 subagent + 雙階段 review = 高品質、快速疊代。

## 能做什麼

- 一次讀取計畫並提取所有 task 文字，建立 TodoWrite，不再重複讀取檔案
- 每 task 派遣一個新 implementer subagent（無 context 污染）；subagent 可在開始前提問
- 雙階段 review：先 spec 合規（`spec-reviewer-prompt.md`）→ 後程式碼品質（`code-quality-reviewer-prompt.md`）；兩者都通過才進下一個 task
- 按 task 複雜度選模型：1-2 個檔案的機械性 task 用便宜模型；多檔整合用標準模型；架構/判斷用最強模型
- 所有 task 完成後派遣 final code reviewer，再呼叫 `finishing-a-development-branch`
- 持續執行不中途報告：唯一的停止原因是 BLOCKED（無法解決）、真正的歧義，或全部完成

## 解決什麼問題

長 session context 累積導致的遺忘與錯誤；需要頻繁 review 保持品質；「做了一大堆才發現方向錯了」的浪費。

## 何時使用（觸發條件）

- 有已寫好的實作計畫（`docs/superpowers/plans/` 下）
- Tasks 之間大致獨立
- 在同一個 session 中執行（不需跨 session）
- 平台支援 subagent（Claude Code、Codex 等）

## 關鍵技術棧

`Agent`/`Task` 工具（implementer、spec reviewer、code quality reviewer subagents）；`TaskCreate`/`TaskUpdate`；`superpowers:requesting-code-review`。

## 重要注意事項

- **需要 subagent 支援**；無 subagent 時改用 `executing-plans`。
- **Spec 合規必須先過，才能進 code quality review**；順序不能顛倒。
- **不在 main/master branch 上開始實作**，除非使用者明確同意。
- Implementer 回報 BLOCKED 時：先給更多 context → 改用更強模型 → 拆解 task → 才升級給人處理；不能讓同一個模型不帶任何變化重試。
- Subagent 不繼承當前 session 歷史；orchestrator 負責構建每個 subagent 所需的最小精確 context。
- DONE_WITH_CONCERNS：讀懂疑慮後決定是否先處理；Minor 觀察可以繼續。
