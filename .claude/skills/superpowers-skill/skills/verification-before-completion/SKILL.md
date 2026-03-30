---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always
source: superpowers/skills/verification-before-completion/SKILL.md
---

## 概述

在宣告任何工作完成、測試通過或 bug 修復之前，強制執行驗證指令並確認完整輸出的流程 skill。核心原則：證據先於宣稱。

## 能做什麼

- Gate Function：識別「什麼指令能證明這個宣稱」→ 執行完整指令 → 讀完整輸出 → 依據證據宣稱
- 防止基於「上次看到通過」或「應該會通過」的虛假宣稱
- 在 commit / push / PR 前強制驗證

## 解決什麼問題

「我以為好了」型的不負責任宣稱；代理人說成功但實際上沒有；只看部分輸出就宣告通過。

## 何時使用（觸發條件）

- 即將說「完成了」「測試通過了」「bug 修了」之前
- 即將執行 git commit 或 git push 之前
- 即將建立 PR 之前
- 即將表達滿意（"Done!"、"Perfect!" 等）之前

## 關鍵技術棧

任何驗證工具：pytest、cargo test、go test ./...、npm test、eslint、tsc 等。

## 重要注意事項

- **Iron Law**：`NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE`。
- 必須在**當前這條 message** 中執行驗證指令才算驗證；上一條 message 的結果不算。
- 「應該通過」、「似乎好了」、「probably」是紅旗，必須停下驗證。
- 只看部分輸出（不看 exit code、不數 failure 數量）不算驗證。
- 信任代理人回報「成功」不算驗證；必須看 VCS diff 或指令輸出。
