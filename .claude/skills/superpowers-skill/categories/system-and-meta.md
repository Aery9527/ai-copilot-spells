# System & Meta

## 快速導覽

- [何時讀這份](#何時讀這份)
- [問題 → Skill](#問題--skill)
- [Skill 細節入口](#skill-細節入口)
- [注意事項](#注意事項)

## 何時讀這份

當需求涉及建立「先查 skill 再動手」的使用習慣、或創建 / 修改 / 驗證 AI skill 本身時，先讀這份分類檔。

[返回開頭](#快速導覽)

## 問題 → Skill

| 情境 | 建議 Skill |
|------|------------|
| 對話開始，需要建立查 skill 的使用紀律 | [using-superpowers](../skills/using-superpowers/SKILL.md) |
| 創建新 skill、修改現有 skill、部署前驗證 | [writing-skills](../skills/writing-skills/SKILL.md) |

[返回開頭](#快速導覽)

## Skill 細節入口

- [using-superpowers](../skills/using-superpowers/SKILL.md) — 「1% 機率就呼叫 skill」紀律、紅旗清單、skill 優先順序
- [writing-skills](../skills/writing-skills/SKILL.md) — TDD 應用於文件、壓力測試情境、RED-GREEN-REFACTOR for skills

[返回開頭](#快速導覽)

## 注意事項

- `using-superpowers`：subagent 可跳過（SUBAGENT-STOP 標記）；使用者指令永遠優先於 superpowers skills。
- `writing-skills`：必須先在沒有 skill 的情況下看到 agent 失敗（RED）才算真正驗證了 skill 有效。
- `writing-skills` 有前置需求：必須先理解 `test-driven-development` 才能使用。

[返回開頭](#快速導覽)
