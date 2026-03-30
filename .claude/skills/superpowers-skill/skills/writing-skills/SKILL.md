---
name: writing-skills
description: Use when creating new skills, editing existing skills, or verifying skills work before deployment
source: superpowers/skills/writing-skills/SKILL.md
---

## 概述

用 TDD 方法學創建、編輯、驗證 AI skill 文件的流程 skill。核心原則：Writing skills IS TDD applied to process documentation — 先看到 agent 在沒有 skill 時失敗（RED），再寫 skill 讓它通過（GREEN），再關閉漏洞（REFACTOR）。

## 能做什麼

- 壓力測試情境設計（測試案例 = 容易出錯的情境）
- RED 階段：在沒有 skill 的情況下執行 subagent，記錄它的理由化模式
- GREEN 階段：撰寫 skill 文件讓 subagent 合規
- REFACTOR 階段：識別並關閉 skill 中的漏洞
- Skill 的 description 欄位優化（供 Skill picker 用）

## 解決什麼問題

沒有驗證的 skill 可能不會被遵守；「我寫了 skill 但 AI 不按照做」；skill 有漏洞讓 agent 找到藉口跳過。

## 何時使用（觸發條件）

- 創建新的 SKILL.md 時
- 修改或改善現有 skill 時
- 部署前驗證 skill 是否有效時
- skill 被 agent 忽略或理由化跳過時

## 關鍵技術棧

`superpowers:test-driven-development`（前置需求，必須先理解）；SKILL.md frontmatter 格式；subagent 派遣工具。

## 重要注意事項

- **前置需求**：必須先理解 `test-driven-development` 才能有效使用本 skill。
- 必須先在沒有 skill 的情況下執行並看到 agent 失敗（RED），才算真正驗證了 skill 有效。
- Personal skills 位置：`~/.claude/skills/`（Claude Code）或 `~/.agents/skills/`（Codex）。
- 官方 Anthropic 最佳實踐：參閱 `anthropic-best-practices.md`（在 superpowers 上游 repo 中）。
