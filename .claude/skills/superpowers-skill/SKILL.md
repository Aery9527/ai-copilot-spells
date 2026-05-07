---
name: superpowers-skill
description: Use this skill when a user asks which superpowers skill fits a task, or when the task involves development workflow (brainstorming, planning, TDD, debugging), code review, parallel agent coordination, git worktree management, or skill engineering covered by the superpowers catalog. Start here, route by category, then load only the relevant category and skill notes.
---

# Superpowers Skill Router

Route requests to the smallest sufficient category file and then to the smallest sufficient skill summary.

## Routing Rules

1. First determine the dominant category.
2. Then read only the matching file under [`categories/`](categories/).
3. Finally, read only the needed file under [`skills/`](skills/).
4. If a category file is sufficient, stop there.
5. If the task spans categories, read the primary category first and add secondary categories only as needed.

## Category Selection

### Development Workflow

- If the user needs design clarification before starting a feature, component, or behavior change, use `brainstorming`.
- If the user needs to turn an approved spec into an implementation plan, use `writing-plans`.
- If the user needs to execute an approved plan in a new session, use `executing-plans`.
- If the user is writing any feature or bug fix and must start with failing tests, use `test-driven-development`.
- If the user is facing a bug, test failure, or unexpected behavior, use `systematic-debugging`.
- If the user is about to declare completion or prepare for commit or PR, use `verification-before-completion`.

### Review And Wrap-Up

- If the user needs to evaluate code review feedback before implementing it, use `receiving-code-review`.
- If the user needs a reviewer subagent after finishing a feature, use `requesting-code-review`.
- If the user needs to choose a merge or PR wrap-up path after finishing all tasks, use `finishing-a-development-branch`.

### Collaboration

- If the task splits into two or more independent subtasks, use `dispatching-parallel-agents`.
- If the user wants one subagent per planned task in the current session, use `subagent-driven-development`.
- If the user needs an isolated git worktree before feature work, use `using-git-worktrees`.

### System And Meta

- If the task begins and the agent must establish the habit of checking skills first, use `using-superpowers`.
- If the task is about creating, editing, or validating a skill, use `writing-skills`.

## Category Entry Points

- Development workflow -> [development-process.md](categories/development-process.md)
- Review and wrap-up -> [review-and-wrap-up.md](categories/review-and-wrap-up.md)
- Collaboration -> [collaboration.md](categories/collaboration.md)
- System and meta -> [system-and-meta.md](categories/system-and-meta.md)

## Notes

- Superpowers skills are invoked with the `superpowers:` prefix inside Claude Code plugin routing, for example `Skill("superpowers:brainstorming")`.
- [`superpowers-skills-sync`](../superpowers-skills-sync/SKILL.md) is a maintenance skill and is not part of this router's second-layer task catalog.
- The agent MUST prefer the smallest sufficient read set. The agent MUST NOT load the whole [`skills/`](skills/) directory by default.
