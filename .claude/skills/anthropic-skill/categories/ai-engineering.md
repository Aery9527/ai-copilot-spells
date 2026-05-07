# AI Engineering

## Purpose

Use this file to route AI-engineering requests inside the Anthropic skill catalog.

## Trigger Conditions

- The task involves Claude API or Anthropic SDK usage.
- The task involves building an MCP server.
- The task involves creating, evaluating, or improving a skill.

## Skill Mapping

- If the user wants to build an application with Claude API or Anthropic SDK, read [claude-api](../skills/claude-api/SKILL.md).
- If the user wants to build an MCP server for LLM use, read [mcp-builder](../skills/mcp-builder/SKILL.md).
- If the user wants to create or improve a skill, run evals, or optimize trigger descriptions, read [skill-creator](../skills/skill-creator/SKILL.md).

## Decision Logic

- If the request explicitly mentions Claude API imports, Anthropic SDK usage, or Agent SDK patterns, choose `claude-api`.
- If the request is about exposing external services or APIs as tools for LLMs, choose `mcp-builder`.
- If the request is about skill engineering itself, choose `skill-creator`.

## Notes

- `skill-creator` is a normal second-layer skill in this architecture and does not have special sync behavior.
