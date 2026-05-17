---
name: executing-plans
description: 當你有一份已撰寫好的實作計畫，需要在獨立的工作階段中搭配審查檢查點來執行時使用
---

# 執行計畫

## 概述

載入計畫、批判性審查、執行所有任務、完成後回報。

**開始時宣告：**「我正在使用 executing-plans skill 來實作此計畫。」

**注意：** 請告知你的人類夥伴，Superpowers 搭配 subagent 支援時效果顯著更好。若在具備 subagent 支援的平台（例如 Claude Code 或 Codex）上執行，工作品質將大幅提升。若 subagent 可用，請改用 superpowers:subagent-driven-development 而非本 skill。

## 流程

### 第一步：載入並審查計畫
1. 讀取計畫檔案
2. 批判性審查——找出對計畫的任何疑問或顧慮
3. 若有顧慮：在開始前與人類夥伴提出討論
4. 若無顧慮：建立 TodoWrite 並繼續執行

### 第二步：執行任務

針對每個任務：
1. 標記為 in_progress
2. 嚴格依照每個步驟執行（計畫已拆分為小步驟）
3. 依規格執行驗證
4. 標記為 completed

### 第三步：完成開發

所有任務完成並驗證後：
- 宣告：「我正在使用 finishing-a-development-branch skill 來完成這項工作。」
- **必要子 skill：** 使用 superpowers:finishing-a-development-branch
- 依照該 skill 驗證測試、呈現選項、執行選擇

## 何時停下來尋求協助

**立即停止執行的情況：**
- 遇到阻塞（缺少相依套件、測試失敗、指示不明確）
- 計畫有關鍵缺口導致無法開始
- 看不懂某項指示
- 驗證反覆失敗

**請求澄清，而非自行猜測。**

## 何時回頭重新審視先前步驟

**回到審查（第一步）的情況：**
- 夥伴根據你的回饋更新了計畫
- 根本方法需要重新思考

**不要強行通過阻塞**——停下來並尋求協助。

## 注意事項
- 先批判性地審查計畫
- 嚴格遵循計畫步驟
- 不要跳過驗證
- 計畫指示使用 skill 時務必參照
- 遇到阻塞時停下，不要猜測
- 未經使用者明確同意，絕不在 main/master 分支上開始實作

## 整合

**必要的工作流程 skill：**
- **superpowers:using-git-worktrees** - 確保隔離的工作空間（建立新的或驗證現有的）
- **superpowers:writing-plans** - 建立本 skill 所執行的計畫
- **superpowers:finishing-a-development-branch** - 所有任務完成後結束開發
