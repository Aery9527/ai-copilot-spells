---
name: requesting-code-review
description: 當完成任務、實作重大功能，或在合併前驗證成果是否符合需求時使用
---

# 請求程式碼審查

派遣程式碼審查員子代理，在問題蔓延前及早發現。審查員取得精心準備的評估上下文，而非你的會話歷程。如此可讓審查員聚焦於工作成果，而非你的思考過程，同時保留你自己的上下文以繼續工作。

**核心原則：** 早審查，常審查。

## 何時請求審查

**必要情況：**
- 子代理驅動開發中，每個任務完成後
- 完成重大功能後
- 合併到 main 之前

**選擇性但有價值：**
- 遇到瓶頸時（取得全新視角）
- 重構前（建立基準檢查）
- 修復複雜 bug 後

## 如何請求

**1. 取得 git SHA：**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # 或 origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. 派遣程式碼審查員子代理：**

使用 Task tool，類型為 `general-purpose`，填入 `code-reviewer.md` 中的範本

**佔位符：**
- `{DESCRIPTION}` — 所建構內容的簡短摘要
- `{PLAN_OR_REQUIREMENTS}` — 應達成的目標
- `{BASE_SHA}` — 起始提交
- `{HEAD_SHA}` — 結束提交

**3. 根據回饋採取行動：**
- Critical 問題立即修復
- Important 問題在繼續前修復
- Minor 問題記錄供後續處理
- 若審查員有誤，附上理由回推

## 範例

```
[剛完成任務二：新增驗證函式]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch code reviewer subagent]
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
  PLAN_OR_REQUIREMENTS: Task 2 from docs/superpowers/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## 與工作流程整合

**子代理驅動開發（Subagent-Driven Development）：**
- 每個任務完成後進行審查
- 在問題累積前及早發現
- 修復後再進行下一個任務

**執行計畫（Executing Plans）：**
- 每個任務完成後或在自然的檢查點進行審查
- 取得回饋、套用，然後繼續

**臨時開發（Ad-Hoc Development）：**
- 合併前審查
- 遇到瓶頸時審查

## 警示訊號

**絕不：**
- 以「這很簡單」為由跳過審查
- 忽略 Critical 問題
- 帶著未修復的 Important 問題繼續前進
- 對有效的技術回饋強行辯駁

**若審查員有誤：**
- 附上技術理由回推
- 展示能證明其正確運作的程式碼或測試
- 請求澄清

範本位置：requesting-code-review/code-reviewer.md
