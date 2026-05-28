---
name: using-git-worktrees
description: Use when starting feature work that needs isolation from current workspace or before executing implementation plans - ensures an isolated workspace exists via native tools or git worktree fallback
source: skill-source/superpowers/skills/using-git-worktrees/SKILL.md
---

## 概述

在開始需要隔離的功能開發或執行計畫前，確保工作在獨立 workspace 中進行的設置 skill。核心原則：先偵測既有隔離 → 優先用 native tool → 才退回 git worktree；不和 harness 對抗。

## 能做什麼

- **Step 0**：比對 `GIT_DIR` vs `GIT_COMMON` 判斷是否已在 linked worktree；含 submodule guard（submodule 內要當正常 repo 處理）
- **Step 1a**：優先使用平台 native worktree 工具（`EnterWorktree`、`/worktree`、`--worktree` 等）
- **Step 1b**：無 native tool 時，按優先順序選目錄（使用者指定 > 既有 `.worktrees/` > 既有 `worktrees/` > legacy 全域路徑 > 預設 `.worktrees/`），驗證 gitignore 後建立 worktree
- **Step 3**：自動偵測並執行 npm/cargo/pip/go 相依安裝
- **Step 4**：跑測試確認 baseline 乾淨，失敗時報告並詢問是否繼續

## 解決什麼問題

在同一個 workspace 做多個功能導致狀態混亂；branch 切換中斷正在進行的工作；用 `git worktree add` 建立了 harness 追蹤不到的 phantom worktree。

## 何時使用（觸發條件）

- 開始需要隔離的功能開發時
- 執行 `writing-plans` 或 `subagent-driven-development` 前
- 需要同時在多個 branch 工作時

## 關鍵技術棧

`git worktree add/list/remove/prune`；平台 native worktree tool（優先）；`git check-ignore`。

## 重要注意事項

- **Step 0 先偵測，已在 worktree 就跳到 Step 3**，不要再建一層。
- **Submodule guard**：`GIT_DIR != GIT_COMMON` 在 submodule 內也會成立，必須用 `git rev-parse --show-superproject-working-tree` 確認。
- **Native tool 優先**（Step 1a）：有 `EnterWorktree` 等工具時，直接用；跳過 Step 1b 的 git 指令，否則產生 harness 看不到的 phantom state。
- 建立 project-local worktree 前**必須確認 `.gitignore` 已排除該目錄**，否則 worktree 內容會進 git index。
- Sandbox 拒絕 `git worktree add` 時，報告並在原地工作（sandbox fallback）。
