# Anthropic Skills Catalog

## Quick Navigation

- [Overview](#overview)
- [Catalog Flow](#catalog-flow)
- [Skill Map](#skill-map)
- [Usage Notes](#usage-notes)

## Overview

This document is the repo-level reference for answering questions about which Anthropic upstream skill fits a task. It is not an executable skill. When a task needs implementation behavior, read the upstream skill under [anthropic-skills/skills](../../anthropic-skills/skills/) or use the installed plugin/native skill for the active tool.

[Back to top](#quick-navigation)

---

## Catalog Flow

```mermaid
flowchart LR
    Q["User question"] --> C["Read this catalog"]
    C --> S["Select smallest matching skill"]
    S --> U["Read upstream SKILL.md when execution details are needed"]
    U --> T["Execute with active tool's installed skill"]
```

[Back to top](#quick-navigation)

---

## Skill Map

### Creative Design

- [algorithmic-art](../../anthropic-skills/skills/algorithmic-art/SKILL.md) — code-driven generative art, flow fields, particles, and geometry.
- [canvas-design](../../anthropic-skills/skills/canvas-design/SKILL.md) — posters, artwork, static visuals, PNG, and PDF design output.
- [theme-factory](../../anthropic-skills/skills/theme-factory/SKILL.md) — reusable visual themes for artifacts.
- [brand-guidelines](../../anthropic-skills/skills/brand-guidelines/SKILL.md) — Anthropic brand colors, typography, and visual rules.
- [slack-gif-creator](../../anthropic-skills/skills/slack-gif-creator/SKILL.md) — animated Slack GIF creation.

### Frontend Engineering

- [frontend-design](../../anthropic-skills/skills/frontend-design/SKILL.md) — design-forward web UI, pages, components, dashboards, and landing pages.
- [web-artifacts-builder](../../anthropic-skills/skills/web-artifacts-builder/SKILL.md) — complex Claude artifacts using React and shadcn/ui.
- [webapp-testing](../../anthropic-skills/skills/webapp-testing/SKILL.md) — Playwright-based testing for local web apps.

### AI Engineering

- [claude-api](../../anthropic-skills/skills/claude-api/SKILL.md) — Claude API and Anthropic SDK apps.
- [mcp-builder](../../anthropic-skills/skills/mcp-builder/SKILL.md) — MCP servers for LLM tool access.
- [skill-creator](../../anthropic-skills/skills/skill-creator/SKILL.md) — creating, improving, packaging, and evaluating AI skills.

### Office Documents

- [pdf](../../anthropic-skills/skills/pdf/SKILL.md) — PDF reading, forms, splitting, merging, OCR, and creation.
- [docx](../../anthropic-skills/skills/docx/SKILL.md) — Word document creation, editing, inspection, and validation.
- [pptx](../../anthropic-skills/skills/pptx/SKILL.md) — PowerPoint creation, editing, and validation.
- [xlsx](../../anthropic-skills/skills/xlsx/SKILL.md) — Excel creation, editing, analysis, and recalculation.

### Writing

- [doc-coauthoring](../../anthropic-skills/skills/doc-coauthoring/SKILL.md) — technical specs, proposals, and design docs.
- [internal-comms](../../anthropic-skills/skills/internal-comms/SKILL.md) — 3P updates, newsletters, incident reports, and internal announcements.

[Back to top](#quick-navigation)

---

## Usage Notes

- Use this catalog only to choose or explain a skill; do not treat it as a runtime workflow.
- For execution details, read the linked upstream [SKILL.md](../../anthropic-skills/skills/) file and only load supporting files that the upstream skill explicitly needs.
- Repo-specific sync and maintenance work belongs to [Claude project skills](../../.claude/skills/) or [project custom skills](../../.agents/skills/), not this catalog.

[Back to top](#quick-navigation)
