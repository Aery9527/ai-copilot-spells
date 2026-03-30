---
name: using-superpowers
description: Use when starting any conversation - establishes how to find and use skills, requiring Skill tool invocation before ANY response including clarifying questions
source: superpowers/skills/using-superpowers/SKILL.md
---

## 概述

對話開始時建立「先查 skill 再動手」使用習慣的系統 skill。確保任何任務（包括釐清問題）前，都先查詢是否有相關 skill，再按 skill 指示行動。

## 能做什麼

- 建立「1% 機率就呼叫 skill」的使用紀律
- Skill 優先順序規則：流程 skill（brainstorming、debugging）優先；實作 skill 次之
- 辨識 12 個常見的理由化陷阱（「這太簡單」「我只是要快速查一下」等）
- 說明 Claude Code 的 `Skill` 工具使用方式

## 解決什麼問題

「這個任務太簡單不需要 skill」的理由化；忘記先查 skill 直接動手導致走偏；重複犯同樣的流程錯誤。

## 何時使用（觸發條件）

- 每次對話開始時（session start）
- 每個任務前（確認是否有相關 skill）

## 關鍵技術棧

`Skill` 工具（Claude Code）；`activate_skill`（Gemini CLI）。

## 重要注意事項

- **Subagent 可跳過**：skill 開頭有 `<SUBAGENT-STOP>` 標記，被 dispatch 的 subagent 不需要執行。
- 使用者指令（CLAUDE.md、AGENTS.md、直接指示）永遠優先於 superpowers skills。
- 「我記得這個 skill 的內容」不代表可以跳過呼叫；skills 會更新，要讀當前版本。
