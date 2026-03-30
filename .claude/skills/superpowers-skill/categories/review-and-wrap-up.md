# Review & Wrap-up

## 快速導覽

- [何時讀這份](#何時讀這份)
- [問題 → Skill](#問題--skill)
- [Skill 細節入口](#skill-細節入口)
- [注意事項](#注意事項)

## 何時讀這份

當需求涉及收到 PR review 意見的處理、派遣 reviewer subagent、或開發完成後的 branch 收尾時，先讀這份分類檔。

[返回開頭](#快速導覽)

## 問題 → Skill

| 情境 | 建議 Skill |
|------|------------|
| 收到 code review 意見，不確定要不要照做 | [receiving-code-review](../skills/receiving-code-review/SKILL.md) |
| 完成功能後想讓 reviewer 檢查符不符合需求 | [requesting-code-review](../skills/requesting-code-review/SKILL.md) |
| 所有 task 完成、測試通過，要選收尾方式 | [finishing-a-development-branch](../skills/finishing-a-development-branch/SKILL.md) |

[返回開頭](#快速導覽)

## Skill 細節入口

- [receiving-code-review](../skills/receiving-code-review/SKILL.md) — 六步回應模式、技術評估、避免表演性同意
- [requesting-code-review](../skills/requesting-code-review/SKILL.md) — 精準構建 reviewer context、superpowers:code-reviewer subagent
- [finishing-a-development-branch](../skills/finishing-a-development-branch/SKILL.md) — 驗證測試、merge/PR/squash 選項

[返回開頭](#快速導覽)

## 注意事項

- `receiving-code-review`：絕不自動同意；先驗證 review 意見在 codebase 中的前提是否成立。
- `requesting-code-review`：reviewer subagent 的 context 要精確構建（git SHA + 需求描述），不繼承當前 session 歷史。
- `finishing-a-development-branch`：必須測試先通過才能進入收尾；測試失敗時停下，不繼續。

[返回開頭](#快速導覽)
