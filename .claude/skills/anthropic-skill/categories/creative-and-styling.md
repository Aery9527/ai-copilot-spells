# Creative And Styling

## Purpose

Use this file to route creative-design and styling requests inside the Anthropic skill catalog.

## Trigger Conditions

- The task involves generative art, static design, theming, brand styling, or animated Slack GIFs.

## Skill Mapping

- If the user wants code-driven generative art, flow fields, particles, or noise-based visuals, read [algorithmic-art](../skills/algorithmic-art/SKILL.md).
- If the user wants posters, covers, or static design output, read [canvas-design](../skills/canvas-design/SKILL.md).
- If the user wants Anthropic brand colors or typography rules, read [brand-guidelines](../skills/brand-guidelines/SKILL.md).
- If the user wants to apply a complete theme to an existing artifact, read [theme-factory](../skills/theme-factory/SKILL.md).
- If the user wants a GIF or animated emoji for Slack, read [slack-gif-creator](../skills/slack-gif-creator/SKILL.md).

## Decision Logic

- If the output should be interactive or algorithmic, prefer `algorithmic-art`.
- If the output should be static and composition-driven, prefer `canvas-design`.
- If the main need is compliance with Anthropic visual identity, prefer `brand-guidelines`.
- If the main need is re-skinning an existing artifact, prefer `theme-factory`.
- If the deliverable is a Slack GIF, prefer `slack-gif-creator`.
