---
name: anthropic-skills-sync
description: Use this skill when the user asks to sync, update, refresh, or check for updates to the anthropic-skills library. Triggers when user says "sync skills", "update skills", "check for upstream changes", "pull latest skills from Anthropic", "refresh skill summaries", or any variation of wanting to keep local skills in sync with the upstream Anthropic repository.
---

# Anthropic Skills Sync

Synchronizes local `.claude/skills/` summaries with the upstream `anthropic-skills/` repo (`https://github.com/anthropics/skills.git`).

## Repository Layout

```
ai-copilot-spells/           ← project root (main git repo)
├── anthropic-skills/        ← upstream clone (its own .git, tracks origin/main)
│   └── skills/
│       └── <name>/          ← one directory per skill
│           └── SKILL.md     ← upstream skill definition
└── .claude/skills/
    ├── <name>/              ← one directory per skill
    │   └── SKILL.md         ← concise summary (Traditional Chinese, our own format)
    └── skill-creator/       ← SPECIAL: contains all upstream files, not just a summary
        ├── SKILL.md         ← real functional skill (DO NOT overwrite with summary)
        ├── SUMMARY.md       ← our custom summary (PRESERVE this)
        ├── agents/
        ├── scripts/
        └── ...
```

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

#### 4a. All skills EXCEPT `skill-creator`

1. Read `anthropic-skills/skills/<name>/SKILL.md` (upstream source of truth)
2. Regenerate `.claude/skills/<name>/SKILL.md` using the **Summary Format** below
3. If this is a NEW skill (in `NEW_SKILLS`): `mkdir .claude/skills/<name>/` first

#### 4b. `skill-creator` (special full-sync)

Copy ALL files from upstream into the installed skill directory, **preserving `SUMMARY.md`**:

```powershell
# Windows (from project root)
robocopy "anthropic-skills\skills\skill-creator" ".claude\skills\skill-creator" /E /XF SUMMARY.md

# Cross-platform alternative (PowerShell)
$src = "anthropic-skills/skills/skill-creator"
$dst = ".claude/skills/skill-creator"
Get-ChildItem -Path $src -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring((Resolve-Path $src).Path.Length + 1)
    if ($rel -ne "SUMMARY.md") {
        $target = Join-Path $dst $rel
        $targetDir = Split-Path $target -Parent
        if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
        Copy-Item $_.FullName -Destination $target -Force
    }
}
```

### Step 5 — Update AGENT.md for new skills

If `NEW_SKILLS` is non-empty:
- Read `AGENT.md` at project root
- Add each new skill to the appropriate category section and lookup table
- Use the upstream SKILL.md description to determine which category it belongs to

### Step 6 — Commit and push

```powershell
# From project root
$newHead = git -C anthropic-skills rev-parse --short HEAD
$skillList = ($changedSkills -join ", ")
git add -A
git commit -m "sync: update skill summaries from anthropic-skills upstream

Synced from anthropic-skills @ $newHead
Updated skills: $skillList

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
git push
```

---

## Summary Format for SKILL.md

Use this exact structure when creating or regenerating `.claude/skills/<name>/SKILL.md`:

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
| Skill deleted upstream | Notify user, ask for confirmation before removing `.claude/skills/<name>/` |
| `skill-creator` changed | Full file sync (Step 4b), NOT just regenerating SKILL.md |
| New skill has no SKILL.md | Log warning, skip summary generation, still copy files |
| git push requires auth | Browser-based auth will appear; wait for it to complete |
| anthropic-skills not a git repo | Error out early: `git -C anthropic-skills status` must succeed |

---

## Verification

After syncing, confirm:

```powershell
# Verify no uncommitted changes remain
git --no-pager status

# Verify push succeeded
git --no-pager log --oneline -3
```
