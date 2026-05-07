---
name: brainstorming
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation."
---

## 概述

在動手寫任何功能、組件或修改行為之前，強制進行需求探索與設計討論的流程 skill。透過一問一答的方式協助釐清使用者意圖、約束條件與成功標準，最終產出設計文件並取得確認後才允許進入實作。

## 能做什麼

- 問題驅動的需求收斂（每次一個問題，偏好選擇題）
- 提出 2-3 種設計方案並分析 trade-off
- 設計文件撰寫到 `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` 並 commit
- Spec 自我審查（佔位符掃描、內部一致性、範疇檢查）
- 視覺 companion 輔助（mockups、diagram，需使用者同意）
- 確認 spec 後移交 `writing-plans` skill

## 關鍵技術棧

純提示工程；強制搭配 `writing-plans`（brainstorming 的終態是呼叫 writing-plans）。

## 重要注意事項

- **HARD-GATE**：未完成設計並取得使用者確認，不得呼叫任何實作 skill（frontend-design、mcp-builder 等）。
- 「這太簡單不需要設計」是最常見的陷阱；所有任務都走這個流程，設計可以很短。
- 若需求描述多個獨立子系統，先拆解為子專案再個別 brainstorm。
- 終態固定是呼叫 `writing-plans`，不得直接跳到其他實作 skill。
