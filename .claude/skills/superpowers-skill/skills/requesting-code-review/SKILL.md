---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
source: superpowers/skills/requesting-code-review/SKILL.md
---

## 概述

完成功能或 task 後，精準構建 reviewer 的 context 並派遣獨立 code-reviewer subagent 進行 review，確保符合需求再合併。核心原則：自我 review 有盲點；早 review 早發現。

## 能做什麼

- 取得 git SHA（BASE_SHA 和 HEAD_SHA）
- 精確構建 reviewer 的 context（實作描述 + 需求 + git range）
- 派遣 `superpowers:code-reviewer` subagent（隔離 context，不繼承當前 session 歷史）
- 在 subagent-driven-development 流程中每個 task 後觸發

## 解決什麼問題

自我 review 的盲點（寫了就看不到問題）；「我覺得好了就合」的品質問題；review 太晚導致大量返工。

## 何時使用（觸發條件）

- `subagent-driven-development` 每個 task 完成後
- 重大功能完成後
- 合併到 main/master 前
- 卡住需要新視角時

## 關鍵技術棧

`superpowers:code-reviewer` subagent；`git rev-parse`；Agent 工具。

## 重要注意事項

- Reviewer 的 context 必須精確構建：實作內容 + 需求/計畫 + BASE_SHA + HEAD_SHA。
- Reviewer **不應**繼承當前 session 的歷史（隔離 context）。
- 只看 diff 的部分，不是整個 codebase。
