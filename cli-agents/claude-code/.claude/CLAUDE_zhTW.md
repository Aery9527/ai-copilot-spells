# AGENT 守則

- 完成任務停下回報給使用者時，一律先判定該次任務修改內容是否影響範圍大，若偏大的影響範圍在回報之後，必須詢問使用者是否要 call reviewer 進行對抗式審查。
- 對抗式審查 reviewer 優先採用 `openai-codex` 的 `codex` 進行，若無法使用才 fallback 使用自己的 subagent `opus high` 進行。

# Git 使用原則

- 基本上不使用 worktree 執行任務，除非是 subagent 併發處理多項任務，才允許在專案 root `.worktree` 底下使用 worktree；但 subagent 處理完就要直接併回
  source branch 並關閉
