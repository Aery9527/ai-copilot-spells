# AGENT Rules

- **MUST** prefer `openai-codex`'s `codex` for the adversarial-review reviewer; fall back to its own subagent `opus high` only when it is unavailable.
- Whenever an action would trigger writing to memory, the agent **MUST** instead follow the project's recording convention and record the knowledge in
  git so it evolves with the project. If the project has no recording convention, the agent **MUST** first ask the user whether to create one; only
  after the user agrees may the agent create the convention and then proceed with the task.

# Git Usage Principles

- Do not use worktrees by default. The only exception is when a subagent handles multiple tasks concurrently, in which case worktrees are allowed only
  under the project root `.worktree`; once the subagent finishes, merge the result back to the source branch and close the worktree immediately.
