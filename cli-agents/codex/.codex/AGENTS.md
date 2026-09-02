# AGENT Rules

- When stopping to report a completed task to the user, **MUST** first assess whether the changes have a large impact scope; if so, **MUST** ask the
  user after the report whether to call a reviewer for adversarial review.
- **MUST** prefer `misty-claude`'s `claude` for the adversarial-review reviewer; fall back to its own subagent `terra xhigh` only when it is
  unavailable.

# Git Usage Principles

- Do not use worktrees by default. The only exception is when a subagent handles multiple tasks concurrently, in which case worktrees are allowed only
  under the project root `.worktree`; once the subagent finishes, merge the result back to the source branch and close the worktree immediately.
