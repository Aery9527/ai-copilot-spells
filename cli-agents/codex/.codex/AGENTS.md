# AGENT Rules

- **MUST** prefer `misty-claude`'s `claude` for the adversarial-review reviewer; fall back to its own subagent `sol high` only when it is unavailable.

# Git Usage Principles

- Do not use worktrees by default. The only exception is when a subagent handles multiple tasks concurrently, in which case worktrees are allowed only
  under the project root `.worktree`; once the subagent finishes, merge the result back to the source branch and close the worktree immediately.
