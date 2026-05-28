# AGENTS.md — Skill Combination Lookup

Purpose: quickly find the right skill combination for the current task. Follow the linked skill files for details. This file stays at the first routing layer only.

## Task Routing

### Development Flow

- If the user wants to build a new feature end-to-end, use `brainstorming` -> `writing-plans` -> `test-driven-development` -> `subagent-driven-development` -> `requesting-code-review`.
- If the user wants to debug a bug, use `systematic-debugging`.
- If the user wants to declare completion or prepare before commit or PR, use `verification-before-completion`.
- If the user wants to execute a plan in a new session, use `executing-plans`.
- If the user wants to execute a plan in the current session task-by-task with subagents, use `subagent-driven-development`.
- If the user wants to run multiple independent subtasks in parallel, use `dispatching-parallel-agents`.
- If the user wants to isolate the workspace before starting work, use `using-git-worktrees`.

### Review And Wrap-Up

- If the user wants to evaluate code review feedback before implementing changes, use `receiving-code-review`.
- If the user wants to request a review after finishing a feature, use `requesting-code-review`.
- If the user wants to choose a wrap-up path after all tasks are done, use `finishing-a-development-branch`.

### Creative, Frontend, And Docs

- If the user wants to build a Web UI or landing page, use `brainstorming` -> `frontend-design`.
- If the user wants to build a complex Claude artifact with React and shadcn, use `web-artifacts-builder`.
- If the user wants to test a local web app with Playwright, use `webapp-testing`.
- If the user wants to generate posters or static visuals in PNG or PDF, use `canvas-design`.
- If the user wants to generate algorithmic art such as flow fields, particles, or geometry, use `algorithmic-art`.
- If the user wants to theme an artifact, use `theme-factory`.
- If the user wants to apply Anthropic brand colors, use `brand-guidelines`.
- If the user wants to create an animated Slack GIF, use `slack-gif-creator`.

### AI Engineering, Document Operations, And Writing

- If the user wants to build a Claude API app or Anthropic SDK integration, use `brainstorming` -> `claude-api`.
- If the user wants to build an MCP server, use `brainstorming` -> `mcp-builder`.
- If the user wants to work with PDFs, use `pdf`.
- If the user wants to work with Word documents, use `docx`.
- If the user wants to work with Excel files, use `xlsx`.
- If the user wants to work with PowerPoint files, use `pptx`.
- If the user wants to write technical specs or design docs, use `doc-coauthoring`.
- If the user wants to write internal communications such as 3P updates or incident reports, use `internal-comms`.

### Skill Maintenance

- If the user wants to create or improve an AI skill, use `brainstorming` -> `writing-skills`.
- If the user wants to maintain governance rules for this repo's project skills, use `skills-governance`.
- If the user wants to sync Anthropic skills upstream, use `anthropic-skills-sync`.
- If the user wants to sync superpowers upstream, use `superpowers-skills-sync`.
- If the user wants to sync CLI docs for Claude Code or GitHub Copilot, use `cli-doc-sync`.
- If the user wants to sync all upstream changes in one pass from Dependabot PRs, use `sync-all`.

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

## Skill Catalog References

- If the user asks which Anthropic upstream skill fits a task, read [Anthropic Skills Catalog](docs/skills/anthropic-skills-catalog.md).
- If the user asks which superpowers upstream skill fits a task, read [Superpowers Skills Catalog](docs/skills/superpowers-skills-catalog.md).
- Catalog documents are references for answering questions. They are not executable skills.

## Skill Locations

- [`skill-source/`](skill-source/) — Upstream submodule container — Holds upstream skill libraries as git submodules; the agent MUST NOT modify upstream content directly.
- [`skill-source/anthropic-skills/`](skill-source/anthropic-skills/) — Anthropic upstream — Original skill definitions; do not modify directly.
- [`skill-source/superpowers/`](skill-source/superpowers/) — superpowers upstream — Original workflow skill definitions; do not modify directly.
- [`docs/skills/anthropic-skills-catalog.md`](docs/skills/anthropic-skills-catalog.md) — Human-readable catalog for choosing Anthropic upstream skills.
- [`docs/skills/superpowers-skills-catalog.md`](docs/skills/superpowers-skills-catalog.md) — Human-readable catalog for choosing superpowers upstream skills.
- [`.claude/skills/_shared/`](.claude/skills/_shared/) — Shared protocol — Contains [`upstream-sync-protocol.md`](.claude/skills/_shared/upstream-sync-protocol.md) referenced by sync skills.
- [`.claude/skills/skills-governance/`](.claude/skills/skills-governance/) — Project skill governance for this repo.
- [`.claude/skills/anthropic-skills-sync/`](.claude/skills/anthropic-skills-sync/) — Maintenance skill — Sync Anthropic skills upstream.
- [`.claude/skills/superpowers-skills-sync/`](.claude/skills/superpowers-skills-sync/) — Maintenance skill — Sync superpowers upstream.
- [`.claude/skills/cli-doc-sync/`](.claude/skills/cli-doc-sync/) — Maintenance skill — Sync CLI documentation for Claude Code and GitHub Copilot.
- [`.claude/skills/sync-all/`](.claude/skills/sync-all/) — Local custom skill — Unified orchestrator that detects Dependabot PRs and invokes sync skills.
- [`scripts/`](scripts/) — Local maintenance scripts — Repo maintenance and automation; document index lives in [`scripts/README.md`](scripts/README.md).
