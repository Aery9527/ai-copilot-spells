# Development Process

## 快速導覽

- [何時讀這份](#何時讀這份)
- [問題 → Skill](#問題--skill)
- [Skill 細節入口](#skill-細節入口)
- [注意事項](#注意事項)

## 何時讀這份

當需求涉及開始新功能前的設計探索、把 spec 轉成計畫、TDD 實作紀律、除錯流程、或完成前的強制驗證時，先讀這份分類檔。

[返回開頭](#快速導覽)

## 問題 → Skill

| 情境 | 建議 Skill |
|------|------------|
| 開始任何功能/組件/修改前，需要釐清需求與設計 | [brainstorming](../skills/brainstorming/SKILL.md) |
| 有確認好的 spec，需要逐步實作計畫 | [writing-plans](../skills/writing-plans/SKILL.md) |
| 有計畫文件，在新 session 按步執行 | [executing-plans](../skills/executing-plans/SKILL.md) |
| 實作任何功能或 bug fix，強制先寫失敗測試 | [test-driven-development](../skills/test-driven-development/SKILL.md) |
| 遇到 bug、測試失敗、非預期行為 | [systematic-debugging](../skills/systematic-debugging/SKILL.md) |
| 準備宣告完成、commit 或 PR 前 | [verification-before-completion](../skills/verification-before-completion/SKILL.md) |

[返回開頭](#快速導覽)

## Skill 細節入口

- [brainstorming](../skills/brainstorming/SKILL.md) — 需求探索、設計對話、spec 產出
- [writing-plans](../skills/writing-plans/SKILL.md) — TDD 任務分解、完整程式碼、無佔位符計畫
- [executing-plans](../skills/executing-plans/SKILL.md) — 按計畫逐步執行、checkpoint review
- [test-driven-development](../skills/test-driven-development/SKILL.md) — 紅-綠-重構循環、Iron Law
- [systematic-debugging](../skills/systematic-debugging/SKILL.md) — 四階段除錯、根因優先
- [verification-before-completion](../skills/verification-before-completion/SKILL.md) — 證據先於宣稱、Gate Function

[返回開頭](#快速導覽)

## 注意事項

- `brainstorming` 有 HARD-GATE：設計未確認前不得呼叫任何實作 skill。
- `test-driven-development` 有 Iron Law：無失敗測試不得寫產品程式碼；先寫的程式碼必須刪掉重來。
- `systematic-debugging` 有 Iron Law：未完成根因調查不得提出修復。
- `verification-before-completion` 有 Iron Law：在當前 message 內執行驗證指令才算驗證。
- 典型完整流程：brainstorming → writing-plans → test-driven-development → subagent-driven-development → verification-before-completion。

[返回開頭](#快速導覽)
