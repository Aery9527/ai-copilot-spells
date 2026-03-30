---
name: using-git-worktrees
description: Use when starting feature work that needs isolation from current workspace or before executing implementation plans - creates isolated git worktrees with smart directory selection and safety verification
source: superpowers/skills/using-git-worktrees/SKILL.md
---

## 概述

在開始需要隔離的功能開發或執行計畫前，建立獨立 git worktree 工作空間的設置 skill。Worktrees 共享同一個 `.git`，但各自有獨立的 working directory 與 branch。

## 能做什麼

- 按優先順序選擇 worktree 目錄（`.worktrees` > `worktrees` > CLAUDE.md 設定 > 詢問使用者）
- 安全性驗證（確認 target directory 不是 git repo 本身）
- 建立新 branch 並 checkout 到 worktree
- 確認 worktree 狀態與路徑

## 解決什麼問題

在同一個 workspace 上做多個功能導致狀態混亂；branch 切換中斷正在進行的工作；需要同時在多個功能上工作。

## 何時使用（觸發條件）

- 開始需要隔離的功能開發時
- 執行實作計畫前（brainstorming skill 建議在獨立 worktree 執行計畫）
- 需要同時在多個 branch 工作時
- 修改可能影響主 workspace 的實驗性工作時

## 關鍵技術棧

`git worktree add`、`git worktree list`、`git worktree remove`；bash。

## 重要注意事項

- 優先查 `.worktrees/`，其次 `worktrees/`，再查 CLAUDE.md 偏好設定，最後才詢問使用者。
- Worktrees 共享同一個 `.git`（一個 branch 不能同時被兩個 worktree 使用）。
- 本 skill 開始時宣告：「I'm using the using-git-worktrees skill to set up an isolated workspace.」
