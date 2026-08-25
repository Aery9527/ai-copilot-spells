# Core Rules

- **MUST** use the Bash tool for all shell script execution; never invoke PowerShell directly — use Bash even on Windows.
- When stopping to report a completed task to the user, **MUST** first assess whether the changes have a large impact scope; if so, **MUST** ask the user after the report whether to call a reviewer for adversarial review.
- **MUST** prefer `openai-codex`'s `codex` for the adversarial-review reviewer; fall back to its own subagent `opus high` only when it is unavailable.
