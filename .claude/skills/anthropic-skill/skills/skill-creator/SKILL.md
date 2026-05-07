---
name: skill-creator
description: Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, edit, or optimize an existing skill, run evals to test a skill, benchmark skill performance with variance analysis, or optimize a skill's description for better triggering accuracy.
---

## 概述

幫助使用者設計、迭代與評估 AI skill，透過創建、測試、量化評估、重寫與重複的循環，優化 skill 行為與觸發精準度。

## Skill 創建流程

1. 捕捉意圖：確認 skill 要做什麼、何時觸發、輸出格式與是否需要測試案例。
2. 訪談與研究：釐清邊界案例、輸入輸出格式、成功標準與相依套件。
3. 撰寫 `SKILL.md`：包含 YAML frontmatter 與主要指令內容。
4. 建立測試案例：能量化就做 eval，偏主觀輸出則視情況決定。
5. 執行測試，可用 background agents。
6. 查看結果與報告。
7. 根據反饋重寫 `SKILL.md`。
8. 重複直到滿意。
9. 擴大測試集規模。
10. 執行 description 優化器，提升觸發精準度。

## Skill 結構

- `skill-name/SKILL.md` 是必要檔案。
- YAML frontmatter 至少要有 `name` 與 `description`。
- 可選附帶資源包括：
  - [`agents/`](../../../../../anthropic-skills/skills/skill-creator/agents/)
  - [`assets/`](../../../../../anthropic-skills/skills/skill-creator/assets/)
  - [`eval-viewer/`](../../../../../anthropic-skills/skills/skill-creator/eval-viewer/)
  - [`references/`](../../../../../anthropic-skills/skills/skill-creator/references/)
  - [`scripts/`](../../../../../anthropic-skills/skills/skill-creator/scripts/)

## Description 設計原則

- `description` 是主要觸發機制，必須同時描述何時用與做什麼。
- Claude 常見問題是 under-trigger，因此 description 必須足夠積極與具體。
- 觸發描述最好直接點名關鍵詞、使用情境與預期任務。

## 腳本工具

- [anthropic-skills/skills/skill-creator/scripts/run_eval.py](../../../../../anthropic-skills/skills/skill-creator/scripts/run_eval.py) — 執行評估。
- [anthropic-skills/skills/skill-creator/scripts/run_loop.py](../../../../../anthropic-skills/skills/skill-creator/scripts/run_loop.py) — 多輪評估循環。
- [anthropic-skills/skills/skill-creator/scripts/generate_report.py](../../../../../anthropic-skills/skills/skill-creator/scripts/generate_report.py) — 生成評估報告。
- [anthropic-skills/skills/skill-creator/eval-viewer/generate_review.py](../../../../../anthropic-skills/skills/skill-creator/eval-viewer/generate_review.py) — 視覺化評估結果。
- [anthropic-skills/skills/skill-creator/scripts/improve_description.py](../../../../../anthropic-skills/skills/skill-creator/scripts/improve_description.py) — 優化 skill description。
- [anthropic-skills/skills/skill-creator/scripts/quick_validate.py](../../../../../anthropic-skills/skills/skill-creator/scripts/quick_validate.py) — 快速驗證。
