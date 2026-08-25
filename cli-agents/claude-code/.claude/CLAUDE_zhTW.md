# 基本守則

- 完成任務停下回報給使用者時, 一律先判定該次任務修改內容是否影響範圍大, 若偏大的影響範圍在回報之後, 必須詢問使用者是否要 call reviewer 進行對抗式審查.
- 對抗式審查 reviewer 優先採用 `openai-codex` 的 `codex` 進行, 若無法使用才 fallback 使用自己的 subagent `opus high` 進行.
