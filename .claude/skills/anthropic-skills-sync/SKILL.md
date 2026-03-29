---
name: anthropic-skills-sync
description: Use this skill when the user asks to sync, update, refresh, or check for updates to the anthropic-skills library. Triggers when user says "sync skills", "update skills", "check for upstream changes", "pull latest skills from Anthropic", "refresh skill summaries", or any variation of wanting to keep local skills in sync with the upstream Anthropic repository.
---

# Anthropic Skills Sync

Synchronizes the local Anthropic router package at [`.claude/skills/anthropic-skill/`](../anthropic-skill/) with the upstream `anthropic-skills/` repo (`https://github.com/anthropics/skills.git`).

## Repository Layout

```
ai-research/
├── anthropic-skills/
│   └── skills/
│       └── <name>/
│           └── SKILL.md        ← upstream source of truth
└── .claude/skills/
    ├── anthropic-skill/
    │   ├── SKILL.md            ← first-layer router
    │   ├── categories/
    │   │   └── *.md            ← category guides
    │   └── skills/
    │       └── <name>/
    │           └── SKILL.md    ← normalized local summary for each upstream skill
    └── anthropic-skills-sync/
        └── SKILL.md            ← this maintenance skill
```

All Anthropic skills, including `skill-creator`, follow the same local sync rule:

- Read upstream `anthropic-skills/skills/<name>/SKILL.md`
- Regenerate local `.claude/skills/anthropic-skill/skills/<name>/SKILL.md`
- Do **not** create top-level `.claude/skills/<name>/` entries for Anthropic skills
- Do **not** keep any dedicated full-sync or `SUMMARY.md` exception for `skill-creator`

## Sync Workflow

### Step 1 — Check for upstream updates

```powershell
cd anthropic-skills
git fetch origin
git log HEAD..origin/main --oneline
```

- If output is **empty** → no updates. Inform user and stop.
- If output has commits → proceed to Step 2.

### Step 2 — Identify changed and added skills

```powershell
# All changed files
git diff HEAD..origin/main --name-only

# Only added files (new skills)
git diff HEAD..origin/main --name-only --diff-filter=A
```

Parse the output to extract skill directory names.  
Pattern: `skills/<name>/...` → skill name is `<name>`.

Collect two lists:
- `CHANGED_SKILLS` — skill directories with any changes
- `NEW_SKILLS` — skills whose directory is brand new (subset of changed)

### Step 3 — Pull updates

```powershell
git pull origin main
```

Note the new HEAD commit hash for the commit message.

### Step 4 — Sync each changed skill

Iterate `CHANGED_SKILLS`:

1. Read `anthropic-skills/skills/<name>/SKILL.md` (upstream source of truth)
2. Regenerate `.claude/skills/anthropic-skill/skills/<name>/SKILL.md` using the **Summary Format** below
3. If this is a NEW skill (in `NEW_SKILLS`): create `.claude/skills/anthropic-skill/skills/<name>/` first
4. Apply the same rule to `skill-creator`; it is **not** a privileged case

### Step 5 — Update router and category docs when needed

If `NEW_SKILLS` is non-empty, or if a changed skill should move categories:

- Read [`.claude/skills/anthropic-skill/SKILL.md`](../anthropic-skill/SKILL.md)
- Read the relevant file under [`.claude/skills/anthropic-skill/categories/`](../anthropic-skill/categories/)
- Update [AGENTS.md](../../../AGENTS.md) and [README.md](../../../README.md) so links and routing docs stay aligned
- Use the upstream `description` to determine which category the skill belongs to

### Step 6 — Commit and push

```powershell
# From project root
$newHead = git -C anthropic-skills rev-parse --short HEAD
$skillList = ($changedSkills -join ", ")
git add -A
git commit -m "sync: update anthropic-skill summaries from anthropic-skills upstream

Synced from anthropic-skills @ $newHead
Updated skills: $skillList

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
git push
```

---

## Summary Format for SKILL.md

Use this exact structure when creating or regenerating `.claude/skills/anthropic-skill/skills/<name>/SKILL.md`:

```markdown
---
name: <skill-name>
description: <exact description string from upstream SKILL.md frontmatter>
source: anthropic-skills/skills/<name>/SKILL.md
---

## 概述

<1-2 sentence summary in Traditional Chinese explaining what this skill does>

## 能做什麼

<bulleted list or table of capabilities, be specific about tools/formats supported>

## 解決什麼問題

<the pain points / context this skill addresses; why it exists>

## 何時使用（觸發條件）

<trigger keywords, user intent phrases, file extensions, or conditions>

## 關鍵技術棧

<libraries, tools, frameworks, languages used>

## 重要注意事項

<caveats, limitations, gotchas, known issues>
```

---

## Edge Cases

| Scenario | Action |
|----------|--------|
| Skill deleted upstream | Notify user, ask for confirmation before removing `.claude/skills/anthropic-skill/skills/<name>/` and its category references |
| New skill has no `SKILL.md` | Log warning, skip summary generation |
| Skill changed categories | Update the relevant file under `categories/`, plus `AGENTS.md` if the public routing table changed |
| `skill-creator` changed | Regenerate its normalized summary using the same rule as every other skill |
| git push requires auth | Browser-based auth will appear; wait for it to complete |
| `anthropic-skills` not a git repo | Error out early: `git -C anthropic-skills status` must succeed |

---

## Verification

After syncing, confirm:

```powershell
# Verify top-level Anthropic router structure
Get-ChildItem -LiteralPath '.claude\skills' -Directory
Get-ChildItem -LiteralPath '.claude\skills\anthropic-skill\skills' -Directory

# Verify no uncommitted changes remain
git --no-pager status

# Verify push succeeded
git --no-pager log --oneline -3
```
