---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup
source: skill-source/superpowers/skills/finishing-a-development-branch/SKILL.md
---

## 概述

實作完成、測試通過後，偵測工作空間環境並引導選擇收尾方式的 skill。核心流程：驗證測試 → 偵測環境 → 決定 base branch → 呈現選項 → 執行選擇 → 清理 worktree（按所有權判斷）。

## 能做什麼

- 驗證測試套件通過（收尾的前置 gate，測試失敗就停下）
- 偵測 workspace 狀態：normal repo / 有名 branch 的 linked worktree / detached HEAD worktree
- Normal repo 和有名 branch worktree：呈現 4 個選項（本地 merge / 開 PR / 保留 / 捨棄）
- Detached HEAD worktree：呈現 3 個選項（開 PR / 保留 / 捨棄，無 merge 選項）
- 按 worktree 所有權判斷清理責任（`.worktrees/`、`worktrees/`、`~/.config/superpowers/worktrees/` 由本 skill 清理；其他由 harness 負責）
- 捨棄前要求輸入 `discard` 確認，防止意外刪除

## 解決什麼問題

「完成了但不知道該 merge/PR/squash 哪個」、忘記清理 worktree 或清理了不該清的 harness worktree、在 merge 前就刪 branch 導致 worktree 報錯。

## 何時使用（觸發條件）

- 所有 task 完成且測試通過後
- `executing-plans` 或 `subagent-driven-development` 最後一步
- 準備把功能整合到主線前

## 關鍵技術棧

`git worktree`、`git merge`、`gh pr create`；`GIT_DIR` vs `GIT_COMMON` 差異用於環境偵測。

## 重要注意事項

- **測試失敗時不進入選項流程**，直接顯示失敗詳情並停下。
- **Option 2（開 PR）和 Option 3（保留）不清理 worktree**，使用者還需要在 PR 疊代期間使用。
- **Merge 先於清理**：必須確認 merge 成功後才移除 worktree，再刪 branch；順序不能錯。
- **永遠在 main repo root 執行 `git worktree remove`**，不能從 worktree 內部呼叫，否則靜默失敗。
- 清理後執行 `git worktree prune` 清除殘留 stale 記錄。
- Harness 建立的 worktree（路徑不在上述三個已知路徑下）由 harness 負責，本 skill 不動它。
