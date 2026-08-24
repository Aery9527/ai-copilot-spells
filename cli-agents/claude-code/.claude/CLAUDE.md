# Core Rules

- **MUST** use the Bash tool for all shell script execution; never invoke PowerShell directly — use Bash even on Windows.
- After completing a larger task, if the change's impact scope is judged to be large, **MUST** call a reviewer for adversarial review; if the scope cannot be judged, **MUST** ask the user whether to call a reviewer for adversarial review.
- **MUST** prefer `openai-codex`'s `codex` for the adversarial-review reviewer; fall back to `opus high` only when it is unavailable.
