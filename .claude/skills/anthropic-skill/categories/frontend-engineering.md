# Frontend Engineering

## Purpose

Use this file to route frontend-engineering requests inside the Anthropic skill catalog.

## Trigger Conditions

- The task involves web UI design, React artifacts, or Playwright-based local web testing.

## Skill Mapping

- If the user wants a design-forward web page, component, or landing page, read [frontend-design](../skills/frontend-design/SKILL.md).
- If the user wants a complex React and shadcn/ui artifact, read [web-artifacts-builder](../skills/web-artifacts-builder/SKILL.md).
- If the user wants Playwright testing or browser-driven validation for a local web app, read [webapp-testing](../skills/webapp-testing/SKILL.md).

## Decision Logic

- If the request is primarily about visual design and implementation style, choose `frontend-design`.
- If the request requires state management, routing, or multi-component artifact structure, choose `web-artifacts-builder`.
- If the request is about validation, browser automation, screenshots, or UI behavior debugging, choose `webapp-testing`.
