---
name: receiving-code-review
description: Use when receiving code review feedback, before implementing suggestions, especially if feedback seems unclear or technically questionable - requires technical rigor and verification, not performative agreement or blind implementation
source: superpowers/skills/receiving-code-review/SKILL.md
---

## 概述

收到 code review 意見時，先進行技術性評估再決定是否實作的流程 skill。核心原則：技術嚴謹先於情感表演；驗證先於實作；有根據的異議優於盲目服從。

## 能做什麼

- 六步回應模式：READ → UNDERSTAND → VERIFY → EVALUATE → RESPOND → IMPLEMENT
- 以自己的話重述需求（確認理解正確）
- 在 codebase 中驗證 review 意見的前提是否成立
- 技術上有理由時，有根據地推回

## 解決什麼問題

「好的你說得對！」型的盲目服從；在未驗證的情況下實作技術上不正確的 review 意見；表演性同意浪費雙方時間。

## 何時使用（觸發條件）

- 收到任何 PR review 意見時
- Review 意見不清楚或技術上有疑慮時
- 看到「你應該改成 X」「這裡有問題」類描述時

## 關鍵技術棧

git diff、程式碼搜尋工具（grep/ripgrep）、測試工具。

## 重要注意事項

- **絕不說**「你說得對！」「太棒了！」「我馬上改」（未驗證前）。
- NEVER 直接說「Let me implement that now」（驗證前）。
- 一次只實作一個 review 意見；每個都要單獨測試。
- 有技術根據時，應提出異議而非默默接受。
