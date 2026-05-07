# System And Meta

## Purpose

Use this file to route system-discipline and skill-engineering requests inside the superpowers catalog.

## Trigger Conditions

- The task begins and the agent must establish the discipline of checking skills first.
- The task involves creating, editing, or validating a skill.

## Skill Mapping

- If the task is about establishing the skill-first operating habit at the start of a conversation, read [using-superpowers](../skills/using-superpowers/SKILL.md).
- If the task is about creating, modifying, or validating a skill, read [writing-skills](../skills/writing-skills/SKILL.md).

## Decision Logic

- If the main need is runtime discipline at conversation start, choose `using-superpowers`.
- If the main need is skill authoring or maintenance, choose `writing-skills`.
