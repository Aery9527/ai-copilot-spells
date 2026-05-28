---
name: receiving-code-review
description: 在收到程式碼審查回饋後、實作建議之前使用，尤其當回饋不清晰或技術上存疑時——要求技術嚴謹與驗證，而非表演性同意或盲目實作
---

# 接收程式碼審查

## 概覽

程式碼審查需要的是技術評估，而非情緒表演。

**核心原則：** 先驗證再實作。先發問再假設。技術正確性優先於社交舒適。

## 回應模式

```
WHEN receiving code review feedback:

1. READ: Complete feedback without reacting
2. UNDERSTAND: Restate requirement in own words (or ask)
3. VERIFY: Check against codebase reality
4. EVALUATE: Technically sound for THIS codebase?
5. RESPOND: Technical acknowledgment or reasoned pushback
6. IMPLEMENT: One item at a time, test each
```

## 禁止回應

**絕對不可以：**
- "You're absolutely right!"（明確違反 CLAUDE.md）
- "Great point!" / "Excellent feedback!"（表演性回應）
- "Let me implement that now"（驗證前就說要實作）

**替代做法：**
- 重新陳述技術需求
- 提出釐清問題
- 若對方有誤，用技術論點反駁
- 直接開始工作（行動勝於言辭）

## 處理不明確的回饋

```
IF any item is unclear:
  STOP - do not implement anything yet
  ASK for clarification on unclear items

WHY: Items may be related. Partial understanding = wrong implementation.
```

**範例：**
```
your human partner: "Fix 1-6"
You understand 1,2,3,6. Unclear on 4,5.

❌ WRONG: Implement 1,2,3,6 now, ask about 4,5 later
✅ RIGHT: "I understand items 1,2,3,6. Need clarification on 4 and 5 before proceeding."
```

## 依來源區分處理方式

### 來自你的人類夥伴
- **信任** — 理解後實作
- **仍需發問** 若範圍不清晰
- **不要表演性同意**
- **跳過廢話** 直接行動或給技術確認

### 來自外部審查者
```
BEFORE implementing:
  1. Check: Technically correct for THIS codebase?
  2. Check: Breaks existing functionality?
  3. Check: Reason for current implementation?
  4. Check: Works on all platforms/versions?
  5. Check: Does reviewer understand full context?

IF suggestion seems wrong:
  Push back with technical reasoning

IF can't easily verify:
  Say so: "I can't verify this without [X]. Should I [investigate/ask/proceed]?"

IF conflicts with your human partner's prior decisions:
  Stop and discuss with your human partner first
```

**你的人類夥伴的規則：** 「外部回饋 — 要保持懷疑，但要仔細查核」

## 「專業」功能的 YAGNI 查核

```
IF reviewer suggests "implementing properly":
  grep codebase for actual usage

  IF unused: "This endpoint isn't called. Remove it (YAGNI)?"
  IF used: Then implement properly
```

**你的人類夥伴的規則：** 「你和審查者都向我負責。如果我們不需要這個功能，就不要加。」

## 實作順序

```
FOR multi-item feedback:
  1. Clarify anything unclear FIRST
  2. Then implement in this order:
     - Blocking issues (breaks, security)
     - Simple fixes (typos, imports)
     - Complex fixes (refactoring, logic)
  3. Test each fix individually
  4. Verify no regressions
```

## 何時應該反駁

以下情況應反駁：
- 建議會破壞現有功能
- 審查者缺乏完整背景脈絡
- 違反 YAGNI（未使用的功能）
- 對這個技術棧來說技術上不正確
- 存在舊版或相容性考量
- 與你的人類夥伴的架構決策衝突

**如何反駁：**
- 使用技術論點，而非防禦態度
- 提出具體問題
- 引用可運作的測試／程式碼
- 若涉及架構問題，讓你的人類夥伴介入

**若不方便明說反駁，可發出暗號：** "Strange things are afoot at the Circle K"

## 認可正確的回饋

當回饋確實正確時：
```
✅ "Fixed. [Brief description of what changed]"
✅ "Good catch - [specific issue]. Fixed in [location]."
✅ [Just fix it and show in the code]

❌ "You're absolutely right!"
❌ "Great point!"
❌ "Thanks for catching that!"
❌ "Thanks for [anything]"
❌ ANY gratitude expression
```

**為何不說謝謝：** 行動說話。直接修好就行。程式碼本身就代表你聽到了回饋。

**若你發現自己正要寫 "Thanks"：** 刪掉它。直接說明修了什麼。

## 優雅地修正自己的反駁

若你反駁了但發現自己有誤：
```
✅ "You were right - I checked [X] and it does [Y]. Implementing now."
✅ "Verified this and you're correct. My initial understanding was wrong because [reason]. Fixing."

❌ Long apology
❌ Defending why you pushed back
❌ Over-explaining
```

陳述事實、修正，然後繼續前進。

## 常見錯誤

| 錯誤 | 修正方式 |
|------|----------|
| 表演性同意 | 陳述需求或直接行動 |
| 盲目實作 | 先對照 codebase 驗證 |
| 批次實作不測試 | 逐一實作，每項都測試 |
| 假設審查者是對的 | 查核是否會破壞東西 |
| 迴避反駁 | 技術正確性 > 舒適感 |
| 部分實作 | 先釐清所有項目 |
| 無法驗證卻繼續進行 | 說明限制，請求指引 |

## 實際範例

**表演性同意（錯誤）：**
```
Reviewer: "Remove legacy code"
❌ "You're absolutely right! Let me remove that..."
```

**技術驗證（正確）：**
```
Reviewer: "Remove legacy code"
✅ "Checking... build target is 10.15+, this API needs 13+. Need legacy for backward compat. Current impl has wrong bundle ID - fix it or drop pre-13 support?"
```

**YAGNI（正確）：**
```
Reviewer: "Implement proper metrics tracking with database, date filters, CSV export"
✅ "Grepped codebase - nothing calls this endpoint. Remove it (YAGNI)? Or is there usage I'm missing?"
```

**不明確項目（正確）：**
```
your human partner: "Fix items 1-6"
You understand 1,2,3,6. Unclear on 4,5.
✅ "Understand 1,2,3,6. Need clarification on 4 and 5 before implementing."
```

## GitHub 討論串回覆

在 GitHub 上回覆 inline 審查留言時，應在留言討論串中回覆（`gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`），而非以頂層 PR 留言的方式回覆。

## 結論

**外部回饋 = 需要評估的建議，而非命令。**

驗證。質疑。然後實作。

不要表演性同意。始終保持技術嚴謹。
