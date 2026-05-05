# AGENTS.md — Skill Combination Lookup

Purpose: **quickly find the right skill combination for the task at hand**. Follow the skill links for details; this file stays at the first routing layer only.

## Quick Navigation

- [Task → Skill Combination](#task--skill-combination)
- [Repository Governance](#repository-governance)
- [Top-Level Router Entry Points](#top-level-router-entry-points)
- [Skill Locations](#skill-locations)

---

## Task → Skill Combination

### Development Flow

| I want to... | Use Skills (in order) |
|--------------|-----------------------|
| Build a new feature end-to-end | `brainstorming` → `writing-plans` → `test-driven-development` → `subagent-driven-development` → `requesting-code-review` |
| Debug a bug | `systematic-debugging` |
| Declare completion / prepare before commit / PR | `verification-before-completion` |
| Execute a plan in a new session | `executing-plans` |
| Execute a plan in the current session task-by-task with subagents | `subagent-driven-development` |
| Run multiple independent subtasks in parallel | `dispatching-parallel-agents` |
| Isolate the workspace before starting work | `using-git-worktrees` |

### Review And Wrap-Up

| I want to... | Use Skills |
|--------------|------------|
| Evaluate code review feedback before implementing changes | `receiving-code-review` |
| Request a review after finishing a feature | `requesting-code-review` |
| Choose a wrap-up path after all tasks are done | `finishing-a-development-branch` |

### Creative, Frontend, And Docs

| I want to... | Use Skills |
|--------------|------------|
| Build a Web UI / landing page | `brainstorming` → `frontend-design` |
| Build a complex Claude artifact (React + shadcn) | `web-artifacts-builder` |
| Test a local web app (Playwright) | `webapp-testing` |
| Generate posters / static visuals (PNG/PDF) | `canvas-design` |
| Generate algorithmic art (flow fields, particles, geometry) | `algorithmic-art` |
| Theme an artifact | `theme-factory` |
| Apply Anthropic brand colors | `brand-guidelines` |
| Create an animated Slack GIF | `slack-gif-creator` |

### AI Engineering, Document Operations, And Writing

| I want to... | Use Skills |
|--------------|------------|
| Build a Claude API app / Anthropic SDK integration | `brainstorming` → `claude-api` |
| Build an MCP server | `brainstorming` → `mcp-builder` |
| Work with PDFs | `pdf` |
| Work with Word documents | `docx` |
| Work with Excel files | `xlsx` |
| Work with PowerPoint files | `pptx` |
| Write technical specs / design docs | `doc-coauthoring` |
| Write internal communications (3P updates, incident reports) | `internal-comms` |

### Skill Maintenance

| I want to... | Use Skills |
|--------------|------------|
| Create or improve an AI skill | `brainstorming` → `writing-skills` |
| Maintain governance rules for this repo's custom skills | `skills-governance` |
| Sync Anthropic skills upstream | `anthropic-skills-sync` |
| Sync superpowers upstream | `superpowers-skills-sync` |
| Sync CLI docs (Claude Code / Copilot) | `cli-doc-sync` |
| Sync all upstream changes in one pass (Dependabot PR trigger) | `sync-all` |

---

## Repository Governance

### Bilingual AGENTS Rule

- `AGENTS.md` is the English primary version.
- `AGENTS_zhTW.md` is the Traditional Chinese mirror.
- Any addition, deletion, rename, or semantic change to either file must update both language versions in the same change slice.
- Do not leave one language temporarily stale with a plan to sync it later.

### `scripts/` Documentation Sync Rule

- When adding, removing, renaming, or materially changing scripts under `scripts/`, you **must** update [`scripts/README.md`](scripts/README.md) in the same slice.
- [`scripts/README.md`](scripts/README.md) is the single index for `scripts/`; new scripts must document at least purpose, arguments, behavior, risks / side effects, and a minimal usage example.
- If root [`README.md`](README.md) already lists script entries or summaries, check whether it also needs to be updated.

---

## Top-Level Router Entry Points

Enter only as needed; do not expand everything at once:

| Scope | Router |
|-------|--------|
| Creative design, frontend engineering, AI engineering, Office docs, technical writing | [anthropic-skill](.claude/skills/anthropic-skill/SKILL.md) |
| Development workflow, code review, parallel collaboration, git workflow, maintenance | [superpowers-skill](.claude/skills/superpowers-skill/SKILL.md) |

---

## Skill Locations

| Directory | Source | Description |
|-----------|--------|-------------|
| `anthropic-skills/` | Anthropic upstream | Original skill definitions; do not modify directly |
| `superpowers/` | superpowers upstream | Original workflow skill definitions; do not modify directly |
| `.claude/skills/anthropic-skill/` | Local router | Top-level category entry point for Anthropic skills |
| `.claude/skills/superpowers-skill/` | Local router | Top-level category entry point for superpowers skills |
| `.claude/skills/_shared/` | Shared protocol | `upstream-sync-protocol.md` referenced by sync skills |
| `.claude/skills/anthropic-skills-sync/` | Maintenance skill | Sync Anthropic skills upstream |
| `.claude/skills/superpowers-skills-sync/` | Maintenance skill | Sync superpowers upstream |
| `.claude/skills/cli-doc-sync/` | Maintenance skill | Sync CLI documentation for Claude Code and GitHub Copilot |
| `.claude/skills/sync-all/` | Local custom skill | Unified orchestrator: detect Dependabot PRs and invoke sync skills |
| `.agents/skills/` | Local project-specific custom skills | Internal governance and repo-specific workflows such as `skills-governance` |
| `scripts/` | Local maintenance scripts | Repo maintenance and automation; documentation index lives in [`scripts/README.md`](scripts/README.md) |
