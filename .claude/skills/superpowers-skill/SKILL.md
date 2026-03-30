---
name: superpowers-skill
description: Use this skill when a user asks which superpowers skill fits a task, or when the task involves development workflow (brainstorming, planning, TDD, debugging), code review, parallel agent coordination, git worktree management, or skill engineering covered by the superpowers catalog. Start here, route by category, then load only the relevant category and skill notes.
---

# Superpowers Skill Router

## 快速導覽

- [定位原則](#定位原則)
- [快速查詢：問題 → Skill](#快速查詢問題--skill)
- [第二層讀取規則](#第二層讀取規則)
- [分類入口](#分類入口)
- [注意事項](#注意事項)

## 定位原則

`superpowers-skill` 是本 repo 針對 superpowers skills 整理後的唯一第一層入口。它的工作不是一次把所有 skill 細節載入，而是先做路由，再按需揭露第二層內容。

執行順序固定如下：

1. 先用本檔的「快速查詢：問題 → Skill」判斷需求落在哪個類別。
2. 再讀對應的分類檔（`categories/`）。
3. 最後只讀需要的 skill 細節檔（`skills/<name>/SKILL.md`）。
4. 除非任務真的跨類別，否則不要一口氣讀完整個 `skills/` 目錄。

[返回開頭](#快速導覽)

## 快速查詢：問題 → Skill

### 🔄 開發流程

| 我需要... | 使用 Skill |
|----------|-----------|
| 開始任何新功能、組件或修改前，先釐清需求與設計 | **brainstorming** |
| 把確認好的 spec 轉成逐步實作計畫 | **writing-plans** |
| 在新 session 按計畫逐步執行（含 checkpoint） | **executing-plans** |
| 寫任何功能或 bug fix 時，強制先寫失敗測試 | **test-driven-development** |
| 遇到 bug、測試失敗、非預期行為，先找根因 | **systematic-debugging** |
| 宣告工作完成、準備 commit 或 PR 前，強制先驗證 | **verification-before-completion** |

### 👀 Review 與收尾

| 我需要... | 使用 Skill |
|----------|-----------|
| 收到 code review 意見，先技術評估再決定是否實作 | **receiving-code-review** |
| 完成功能後，派遣 reviewer subagent 進行 review | **requesting-code-review** |
| 所有 task 完成、測試通過，選擇收尾方式（merge/PR） | **finishing-a-development-branch** |

### 🤝 協作與並行

| 我需要... | 使用 Skill |
|----------|-----------|
| 面對 2+ 個獨立任務，並行派遣多個 subagent | **dispatching-parallel-agents** |
| 在當前 session 中，為每個計畫 task 派遣新 subagent | **subagent-driven-development** |
| 開始功能開發前，建立隔離的 git worktree 工作空間 | **using-git-worktrees** |

### ⚙️ 系統與維運

| 我需要... | 使用 Skill |
|----------|-----------|
| 對話開始，建立「先查 skill 再動手」的使用習慣 | **using-superpowers** |
| 創建新 skill、修改 skill、部署前驗證 skill 有效性 | **writing-skills** |

[返回開頭](#快速導覽)

## 第二層讀取規則

- 若需求涉及 brainstorming、planning、TDD、debugging、verification，讀 [categories/development-process.md](categories/development-process.md)
- 若需求涉及 code review 或 branch 收尾，讀 [categories/review-and-wrap-up.md](categories/review-and-wrap-up.md)
- 若需求涉及平行 agent、subagent 執行、worktree，讀 [categories/collaboration.md](categories/collaboration.md)
- 若需求涉及 skill 使用紀律或 skill 工程，讀 [categories/system-and-meta.md](categories/system-and-meta.md)

若分類檔已足夠回答，就不要再展開更多 skill 細節；只有在需要具體 Iron Law、觸發條件或注意事項時，才往 `skills/<name>/SKILL.md` 深入。

[返回開頭](#快速導覽)

## 分類入口

- [Development Process](categories/development-process.md)
- [Review & Wrap-up](categories/review-and-wrap-up.md)
- [Collaboration](categories/collaboration.md)
- [System & Meta](categories/system-and-meta.md)

[返回開頭](#快速導覽)

## 注意事項

- Superpowers skills 在 Claude Code plugin 系統中有 `superpowers:` prefix，透過 `Skill` 工具呼叫（例：`Skill("superpowers:brainstorming")`）。
- `superpowers-skills-sync` 是獨立的維運 skill，位於 [`.claude/skills/superpowers-skills-sync/SKILL.md`](../superpowers-skills-sync/SKILL.md)，不屬於這個 router 的第二層內容。
- 若需求跨多個 skill，先找主 skill，再只補讀必要的次要 skill，避免一開始就把所有內容灌進 context。

[返回開頭](#快速導覽)
