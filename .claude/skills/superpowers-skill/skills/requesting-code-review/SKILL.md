---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
source: skill-source/superpowers/skills/requesting-code-review/SKILL.md
---

## 概述

完成功能或 task 後，精準構建 reviewer 的 context 並派遣獨立 code-reviewer subagent 進行 review，確保符合需求再繼續。核心原則：early review + 隔離 context = 不受當前 session 思維定勢影響。

## 能做什麼

- 取得 git SHA（BASE_SHA 和 HEAD_SHA）
- 使用 `code-reviewer.md` 模板精確構建 reviewer context（實作描述 + 需求/計畫 + git range）
- 派遣 `general-purpose` type subagent 進行 review（不繼承當前 session 歷史）
- 依 Critical / Important / Minor 三個等級給出處理優先順序

## 解決什麼問題

自我 review 的盲點（寫了就看不到問題）；「我覺得好了就合」的品質問題；review 太晚導致大量返工。

## 何時使用（觸發條件）

- `subagent-driven-development` 每個 task 完成後（**必做**）
- 重大功能完成後（**必做**）
- 合併到 main 前（**必做**）
- 卡住需要新視角時（選用）
- 重構前建立 baseline（選用）

## 關鍵技術棧

`code-reviewer.md` 模板；`git rev-parse`；Agent / Task 工具（`general-purpose` subagent type）。

## 重要注意事項

- **Reviewer 的 context 必須精確構建**：實作內容 + 需求/計畫 + BASE_SHA + HEAD_SHA；不讓 reviewer 繼承當前 session 歷史。
- **Critical 問題必須立即修復**；**Important 問題必須在繼續前修復**；Minor 記錄即可。
- Reviewer 若有誤判，用技術論據反駁，不要盲目接受。
- 見模板：`requesting-code-review/code-reviewer.md`。
