# Collaboration

## 快速導覽

- [何時讀這份](#何時讀這份)
- [問題 → Skill](#問題--skill)
- [Skill 細節入口](#skill-細節入口)
- [注意事項](#注意事項)

## 何時讀這份

當需求涉及平行派遣多個 subagent、在當前 session 中執行計畫、或建立隔離工作空間時，先讀這份分類檔。

[返回開頭](#快速導覽)

## 問題 → Skill

| 情境 | 建議 Skill |
|------|------------|
| 有 2+ 個獨立問題，想同時調查 | [dispatching-parallel-agents](../skills/dispatching-parallel-agents/SKILL.md) |
| 有計畫文件，想在當前 session 逐 task 執行（每 task 一個新 subagent） | [subagent-driven-development](../skills/subagent-driven-development/SKILL.md) |
| 開始功能前需要隔離 workspace 避免互相干擾 | [using-git-worktrees](../skills/using-git-worktrees/SKILL.md) |

[返回開頭](#快速導覽)

## Skill 細節入口

- [dispatching-parallel-agents](../skills/dispatching-parallel-agents/SKILL.md) — 平行派遣、isolated context 構建
- [subagent-driven-development](../skills/subagent-driven-development/SKILL.md) — 每 task 一個新 subagent、雙階段 review
- [using-git-worktrees](../skills/using-git-worktrees/SKILL.md) — 目錄優先順序、安全性驗證、branch 設置

[返回開頭](#快速導覽)

## 注意事項

- `dispatching-parallel-agents`：subagent 不應繼承當前 session 的歷史 context；共享狀態的任務不可平行。
- `subagent-driven-development`：需要 subagent 支援；比 `executing-plans` 品質更高但要求更多。
- `subagent-driven-development` vs `executing-plans`：同 session 用前者；跨 session 或無 subagent 支援用後者。
- `using-git-worktrees`：優先查 `.worktrees/`，其次 `worktrees/`，再查 CLAUDE.md 偏好設定，最後才詢問使用者。

[返回開頭](#快速導覽)
