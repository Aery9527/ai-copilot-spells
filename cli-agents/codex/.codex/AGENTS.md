# Core Rules

- When stopping to report a completed task to the user, **MUST** first assess whether the changes have a large impact scope; if so, **MUST** ask the user after the report whether to call a reviewer for adversarial review.
- **MUST** prefer `aery-claude-code`'s `claude-code` for the adversarial-review reviewer; fall back to its own subagent `terra xhigh` only when it is unavailable.
