# Writing

## Purpose

Use this file to route writing-related requests inside the Anthropic skill catalog.

## Trigger Conditions

- The task involves technical specs, proposals, design docs, or internal communications.

## Skill Mapping

- If the user wants technical specs, proposals, or design docs, read [doc-coauthoring](../skills/doc-coauthoring/SKILL.md).
- If the user wants internal communications such as newsletters, 3P updates, FAQs, or incident reports, read [internal-comms](../skills/internal-comms/SKILL.md).

## Decision Logic

- If the document is a technical artifact for planning, design, or engineering alignment, choose `doc-coauthoring`.
- If the document is intended for internal organizational communication, choose `internal-comms`.
