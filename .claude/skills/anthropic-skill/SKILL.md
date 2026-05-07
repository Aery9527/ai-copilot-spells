---
name: anthropic-skill
description: Use this skill when a user asks which Anthropic skill fits a task, or when the task falls into creative design, frontend engineering, AI engineering, office documents, or writing workflows covered by the local anthropic-skills catalog. Start here, route by category, then load only the relevant internal category and skill notes.
---

# Anthropic Skill Router

Route requests to the smallest sufficient category file and then to the smallest sufficient skill summary.

## Routing Rules

1. First determine the dominant task category.
2. Then read only the matching file under [`categories/`](categories/).
3. Finally, read only the needed file under [`skills/`](skills/).
4. If one category file is sufficient, stop there.
5. If the task truly spans categories, read the primary category first and add secondary categories only as needed.

## Category Selection

### Creative Design

- If the user wants code-driven generative art, flow fields, or particle systems, use `algorithmic-art`.
- If the user wants posters, artwork, or static visuals in PNG or PDF, use `canvas-design`.
- If the user wants to apply a reusable theme to an artifact, use `theme-factory`.
- If the user wants Anthropic brand colors or typography, use `brand-guidelines`.
- If the user wants an animated Slack GIF, use `slack-gif-creator`.

### Frontend Engineering

- If the user wants a design-forward web UI, component set, or landing page, use `frontend-design`.
- If the user wants a complex Claude artifact with React and shadcn/ui, use `web-artifacts-builder`.
- If the user wants Playwright-based local web app testing, use `webapp-testing`.

### AI Engineering

- If the user wants a Claude API or Anthropic SDK app, use `claude-api`.
- If the user wants to build an MCP server for LLM access, use `mcp-builder`.
- If the user wants to create, improve, or evaluate an AI skill, use `skill-creator`.

### Office Documents

- If the user wants PDF reading, merging, splitting, OCR, or creation, use `pdf`.
- If the user wants Word or `.docx` creation, editing, or reading, use `docx`.
- If the user wants PowerPoint or `.pptx` creation, editing, or reading, use `pptx`.
- If the user wants Excel or `.xlsx` creation, editing, or analysis, use `xlsx`.
- If the user wants Office-document visuals in a static design style, use `canvas-design`.
- If the user wants Office-document visuals in a generative-art style, use `algorithmic-art`.

### Writing

- If the user wants technical specs, proposals, or design docs, use `doc-coauthoring`.
- If the user wants internal communications such as 3P updates, newsletters, or incident reports, use `internal-comms`.

## Category Entry Points

- Creative design -> [creative-and-styling.md](categories/creative-and-styling.md)
- Frontend engineering -> [frontend-engineering.md](categories/frontend-engineering.md)
- AI engineering -> [ai-engineering.md](categories/ai-engineering.md)
- Office documents -> [office-documents.md](categories/office-documents.md)
- Writing -> [writing.md](categories/writing.md)

## Notes

- [`anthropic-skills-sync`](../anthropic-skills-sync/SKILL.md) is a maintenance skill and is not part of this router's second-layer task catalog.
- `skill-creator` is a normal second-layer skill in this router; it no longer has a privileged path.
- The agent MUST prefer the smallest sufficient read set. The agent MUST NOT load the whole [`skills/`](skills/) directory by default.
