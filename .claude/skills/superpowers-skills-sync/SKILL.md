---
name: superpowers-skills-sync
submodule-path: superpowers
description: Use this skill when the user asks to sync, update, refresh, or check for updates to the superpowers skills library. Triggers when user says "sync superpowers", "update superpowers skills", "check superpowers upstream", "pull latest superpowers", or any variation of keeping superpowers local descriptions in sync with the upstream repo.
---

# Superpowers Skills Sync

## 庫設定

| 欄位 | 值 |
|------|-----|
| 庫名稱 | `superpowers` |
| 上游 URL | `https://github.com/obra/superpowers.git` |
| Submodule 路徑 | `superpowers/` |
| 本地 Router 路徑 | `.claude/skills/superpowers-skill/` |
| Skill 來源模式 | `skills/<name>/SKILL.md` |
| CO_AUTHOR | `Claude Sonnet 4.6 <noreply@anthropic.com>` |

## Sync 流程

參閱 [_shared/upstream-sync-protocol.md](../_shared/upstream-sync-protocol.md)，
以上方「庫設定」填入對應的 `{{變數}}` 後執行。
