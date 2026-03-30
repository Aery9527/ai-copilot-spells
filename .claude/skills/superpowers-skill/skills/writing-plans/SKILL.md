---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
source: superpowers/skills/writing-plans/SKILL.md
---

## 概述

把已確認的 spec 或需求，轉換成工程師零脈絡也能執行的逐步實作計畫。每個步驟都有精確的檔案路徑、完整程式碼與驗證指令，不留任何佔位符。

## 能做什麼

- 以 TDD 為基礎的任務分解（每步 2-5 分鐘）
- 精確到行的檔案路徑（含 `Create:` / `Modify:` / `Test:` 標記）
- 每個步驟含完整程式碼，不使用「TBD」或「實作後補」
- 測試指令含預期輸出（PASS / FAIL 訊息）
- 設計頻繁 commit 點
- 計畫儲存到 `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`

## 解決什麼問題

「我知道要做什麼，但不知道從哪裡切入」；模糊計畫導致執行時卡頓、猜測、走偏。

## 何時使用（觸發條件）

- `brainstorming` 完成並 spec 確認後
- 有需求或規格描述，準備開始多步驟任務前
- 在動任何程式碼之前

## 關鍵技術棧

Markdown 計畫文件；搭配 `subagent-driven-development`（推薦）或 `executing-plans` 執行。

## 重要注意事項

- **No Placeholders**：計畫中不得出現 TBD、TODO、「類似 Task N」、「加適當 error handling」等模糊描述。
- 每個涉及程式碼的步驟必須含完整程式碼區塊。
- Spec 覆蓋多個獨立子系統時，應先拆解為多個計畫，每個計畫獨立可驗證。
- 自我 review 後才儲存：佔位符掃描、型別一致性、spec 覆蓋率。
