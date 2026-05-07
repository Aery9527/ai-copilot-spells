# Collaboration

## Purpose

Use this file to route collaboration and parallel-execution requests inside the superpowers catalog.

## Trigger Conditions

- The task naturally splits into multiple independent subtasks.
- The user wants one subagent per task.
- The user needs an isolated worktree before feature work.

## Skill Mapping

- If the user has two or more independent problems and wants them investigated in parallel, read [dispatching-parallel-agents](../skills/dispatching-parallel-agents/SKILL.md).
- If the user has a plan and wants one new subagent per task in the current session, read [subagent-driven-development](../skills/subagent-driven-development/SKILL.md).
- If the user needs a separate git worktree before starting feature work, read [using-git-worktrees](../skills/using-git-worktrees/SKILL.md).

## Decision Logic

- If the main need is parallel information gathering or parallel execution across independent tasks, choose `dispatching-parallel-agents`.
- If the main need is executing an existing plan task-by-task in the same session, choose `subagent-driven-development`.
- If the main need is workspace isolation before implementation, choose `using-git-worktrees`.
