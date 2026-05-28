---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
source: skill-source/superpowers/skills/writing-plans/SKILL.md
---

## 概述

把已確認的 spec 或需求，轉換成工程師零脈絡也能執行的逐步實作計畫。每個步驟都有精確的檔案路徑、完整程式碼與驗證指令，不留任何佔位符。計畫完成後提供 Subagent-Driven / Inline 兩種執行方式供選擇。

## 能做什麼

- 先做 File Structure mapping（確定創建/修改哪些檔案）再拆 task，職責界線清楚
- 以 TDD 為基礎的 bite-sized task 分解（每步 2-5 分鐘）
- 每個步驟含精確檔案路徑（`Create:`/`Modify:`/`Test:`）、完整程式碼區塊與驗證指令
- 計畫 header 含強制的 sub-skill 提示（subagent-driven-development 或 executing-plans）
- 自我 review：spec 覆蓋率 + 佔位符掃描 + 型別一致性，有問題原地修復
- 計畫儲存到 `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
- 計畫完成後提供執行方式選擇（Subagent-Driven 推薦 / Inline 執行）

## 解決什麼問題

「我知道要做什麼，但不知道從哪裡切入」；模糊計畫導致執行時卡頓、猜測、走偏；subagent 讀到 TBD/TODO 導致實作不完整。

## 何時使用（觸發條件）

- `brainstorming` 完成並 spec 確認後
- 有需求或規格描述，準備開始多步驟任務前
- 在動任何程式碼之前

## 關鍵技術棧

Markdown 計畫文件；搭配 `subagent-driven-development`（推薦）或 `executing-plans` 執行；計畫 worktree 由 `using-git-worktrees` 在執行時建立。

## 重要注意事項

- **No Placeholders**：計畫中不得出現 TBD、TODO、「類似 Task N」、「加適當 error handling」等模糊描述。每個涉及程式碼的步驟必須含完整程式碼區塊。
- **File Structure 先於 task 分解**：先確定哪些檔案要創/改，才能做出有清楚邊界的 task。
- Spec 覆蓋多個獨立子系統時，先建議拆解為多個獨立可驗證的計畫。
- 在既有 codebase 中遵循現有 pattern；如需重構，把 split 納入計畫，不要靜默改變結構。
