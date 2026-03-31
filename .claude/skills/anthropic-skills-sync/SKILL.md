---
name: anthropic-skills-sync
submodule-path: anthropic-skills
description: Use this skill when the user asks to sync, update, refresh, or check for updates to the anthropic-skills library. Triggers when user says "sync skills", "update skills", "check for upstream changes", "pull latest skills from Anthropic", "refresh skill summaries", or any variation of wanting to keep local skills in sync with the upstream Anthropic repository.
---

# Anthropic Skills Sync

## 庫設定

| 欄位 | 值 |
|------|-----|
| 庫名稱 | `anthropic-skills` |
| 上游 URL | `https://github.com/anthropics/skills.git` |
| Submodule 路徑 | `anthropic-skills/` |
| 本地 Router 路徑 | `.claude/skills/anthropic-skill/` |
| Skill 來源模式 | `skills/<name>/SKILL.md` |
| CO_AUTHOR | `Claude Sonnet 4.6 <noreply@anthropic.com>` |

## Sync 流程

參閱 [_shared/upstream-sync-protocol.md](../_shared/upstream-sync-protocol.md)，
以上方「庫設定」填入對應的 `{{變數}}` 後執行。
