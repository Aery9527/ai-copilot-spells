---
name: doc-coauthoring
description: Guide users through a structured workflow for co-authoring documentation. Use when user wants to write documentation, proposals, technical specs, decision docs, or similar structured content. This workflow helps users efficiently transfer context, refine content through iteration, and verify the doc works for readers. Trigger when user mentions writing docs, creating proposals, drafting specs, or similar documentation tasks.
source: anthropic-skills/skills/doc-coauthoring/SKILL.md
---

## 概述

三階段結構化文件共同創作工作流程，幫助使用者高效產出高品質文件。核心洞見：讓「fresh Claude」（無上下文）測試文件，確保文件對真實讀者有效。

## 三個階段

### Stage 1：Context Gathering（情境蒐集）
- 確認文件類型、目標受眾、期望影響、模板
- 鼓勵使用者「info dump」所有相關情境
- 提出 5-10 個澄清問題填補知識空缺
- 支援整合 Slack/Teams/Google Drive 等工具拉取情境

### Stage 2：Refinement & Structure（精練與結構）
逐節建構文件：
1. 提問（每節 5-10 個問題）
2. 腦力激盪（5-20 個選項）
3. 使用者篩選（保留/刪除/合併）
4. 缺口檢查
5. 起草（用 `str_replace` 精外科手術式編輯）
6. 迭代精練

完成 80%+ 節時：全文審查一致性、冗余、「廢話」

### Stage 3：Reader Testing（讀者測試）
- 生成 5-10 個讀者可能搜尋的問題
- 用 sub-agent（fresh Claude，無上下文）逐一回答
- 找出盲點：模糊點、錯誤假設、矛盾
- 若有問題回到 Stage 2 修正

## 能做什麼

- 撰寫技術規格（PRD、設計文件、RFC、決策文件）
- 共同撰寫提案、備忘錄、報告
- 確保文件對後續讀者（包括用 Claude 閱讀文件的人）有效
- 支援 GitHub、Confluence、Google Docs 等平台的文件

## 解決什麼問題

文件作者常有「知識詛咒」——他們知道太多了，導致文件對不了解情境的讀者來說不夠清晰。此 skill 透過結構化流程和讀者測試解決這個問題。

## 何時使用（觸發條件）

- 「幫我寫文件」/ 「起草提案」/ 「寫規格書」
- 「PRD」/ 「設計文件」/ 「決策文件」/ 「RFC」
- 任何需要產出結構化書面內容的任務

## 關鍵原則

- 使用 `str_replace` 精確編輯，**絕不重印整個文件**
- 如有 artifacts 工具則使用 `create_file`，否則建立本地 .md 檔
- 不催促跳過階段——品質優於速度
- 使用者可選擇跳過流程改為「自由形式」寫作

## 重要注意事項

- 若沒有 sub-agent 存在（如 claude.ai 網頁），手動指引使用者開新對話測試
- 文件完成前讓使用者做最終自審——他們是文件的主人
