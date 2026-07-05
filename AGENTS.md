# AGENTS.md — AI Tool Skills Knowledge Base

Purpose: track upstream AI tool skills and maintain local sync and governance workflows.

## Repository Governance

### Bilingual AGENTS Rule

- `AGENTS.md` is the English primary version.
- `AGENTS_zhTW.md` is the Traditional Chinese mirror.
- Any addition, deletion, rename, or semantic change to either file MUST update both language versions in the same change slice.
- The agent MUST NOT leave one language temporarily stale with a plan to sync it later.

### `scripts/` Documentation Sync Rule

- When adding, removing, renaming, or materially changing scripts under [`scripts/`](scripts/), the agent MUST update [`scripts/README.md`](scripts/README.md) in the same slice.
- [`scripts/README.md`](scripts/README.md) is the single index for [`scripts/`](scripts/); new scripts MUST document at least purpose, arguments, behavior, risks or side effects, and a minimal usage example.
- If [`README.md`](README.md) already lists script entries or summaries, the agent MUST check whether it also needs to be updated.

## Project Structure

- [`skill-source/`](skill-source/) — Upstream skill sources — Contains skill libraries that come from GitHub as git submodules and remain the upstream targets this project tracks; agents MUST NOT modify upstream content directly.
- [`skill-source-zhTW/`](skill-source-zhTW/) — Localized skill sources — Contains selected Traditional Chinese translations derived from upstream skill content when this project needs a localized copy.
- [`.claude/skills/`](.claude/skills/) — Project skills — Contains local maintenance skills and shared protocols for this repo.
- [`scripts/`](scripts/) — Local maintenance scripts — Contains repo maintenance and automation scripts; the document index lives in [`scripts/README.md`](scripts/README.md).
