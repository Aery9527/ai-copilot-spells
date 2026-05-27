---
name: superpowers-skills-sync
description: >-
  Use this skill when the user asks to sync, update, refresh, or check for
  updates to the superpowers skills library. Triggers when user says "sync
  superpowers", "update superpowers skills", "check superpowers upstream",
  "pull latest superpowers", "refresh superpowers catalog", or any variation of
  keeping the local superpowers skills catalog in sync with the upstream repo.
---

# Superpowers Skills Sync

## Library Configuration

- `LIBRARY_NAME` -> `superpowers`
- `UPSTREAM_URL` -> [obra/superpowers.git](https://github.com/obra/superpowers.git)
- `SUBMODULE_PATH` -> `superpowers/`
- `CATALOG_PATH` -> `docs/skills/superpowers-skills-catalog.md`
- `SKILL_SOURCE_PATTERN` -> `skills/<name>/SKILL.md`
- `CO_AUTHOR` -> `Claude Sonnet 4.6 <noreply@anthropic.com>`

## Workflow

Read [upstream-sync-protocol.md](../_shared/upstream-sync-protocol.md), substitute the library configuration above into the protocol variables, and execute the shared sync workflow in order.
