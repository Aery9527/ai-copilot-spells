# Review And Wrap-Up

## Purpose

Use this file to route code-review and task-wrap-up requests inside the superpowers catalog.

## Trigger Conditions

- The task is about code review feedback.
- The task is about requesting a review.
- The task is about deciding how to finish a completed branch.

## Skill Mapping

- If the user received code review feedback and must evaluate it before implementing, read [receiving-code-review](../skills/receiving-code-review/SKILL.md).
- If the user finished a feature and wants a reviewer subagent, read [requesting-code-review](../skills/requesting-code-review/SKILL.md).
- If the user finished implementation and tests and needs to choose a wrap-up path, read [finishing-a-development-branch](../skills/finishing-a-development-branch/SKILL.md).

## Decision Logic

- If the input is feedback from someone else, choose `receiving-code-review`.
- If the input is a completed implementation that needs review, choose `requesting-code-review`.
- If the input is a completed branch that needs merge, PR, or cleanup handling, choose `finishing-a-development-branch`.
