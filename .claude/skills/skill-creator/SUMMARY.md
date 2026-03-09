---
name: skill-creator
description: Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, edit, or optimize an existing skill, run evals to test a skill, benchmark skill performance with variance analysis, or optimize a skill's description for better triggering accuracy.
source: anthropic-skills/skills/skill-creator/SKILL.md
note: This is a SUMMARY file. The full functional skill is in SKILL.md (already installed here in .claude/skills/skill-creator/).
---

## 概述

幫助使用者設計、迭代和評估 AI Skill 的元工具（meta-skill）。透過「創建草稿 → 測試 → 量化評估 → 重寫 → 重複」的循環，優化 skill 的行為和觸發精準度。

## Skill 創建流程

```
1. 捕捉意圖（Capture Intent）
   ├─ 現有對話是否包含可以捕捉的工作流？
   └─ 提問：技能做什麼？何時觸發？期望輸出格式？需要測試案例嗎？

2. 訪談與研究（Interview）
   └─ 邊緣案例、輸入/輸出格式、成功標準、相依套件

3. 撰寫 SKILL.md（含 YAML frontmatter）
   ├─ name、description（觸發機制）
   └─ 技能主體（指令、工作流程、範例）

4. 創建測試案例
   └─ 客觀可驗證 → 量化 evals
       主觀輸出 → 不一定需要 evals

5. 執行測試（background agents）

6. 查看結果
   ├─ eval-viewer/generate_review.py → 視覺化報告
   └─ 量化指標

7. 根據反饋重寫 SKILL.md

8. 重複直到滿意

9. 擴大測試集規模

10. 運行描述優化器（improve_description.py）
    └─ 優化觸發精準度
```

## Skill 解剖

```
skill-name/
├── SKILL.md（必要）
│   ├── YAML frontmatter（name、description 必填）
│   └── Markdown 指令
└── 附帶資源（可選）
    ├── templates/   # 模板
    ├── examples/    # 範例輸出
    ├── scripts/     # 輔助腳本
    └── reference/   # 參考文件
```

## Description 設計原則

- Description 是主要觸發機制（含**何時用**和**做什麼**）
- Claude 傾向**不夠觸發**（under-trigger）→ description 要積極推銷
- 範例：「當使用者提到 dashboard、數據視覺化、內部指標時，務必使用此 skill」

## 腳本工具

| 腳本 | 功能 |
|------|------|
| `scripts/run_eval.py` | 執行評估 |
| `scripts/run_loop.py` | 多輪評估循環 |
| `scripts/generate_report.py` | 生成評估報告 |
| `eval-viewer/generate_review.py` | 視覺化評估結果 |
| `scripts/improve_description.py` | 優化 skill description |
| `scripts/quick_validate.py` | 快速驗證 |

## 解決什麼問題

建立高品質 AI Skill 需要系統化方法。此 skill 提供完整的 skill 工程方法論，從意圖捕捉到量化評估的完整循環。

## 何時使用（觸發條件）

- 「幫我建一個 skill」/ 「創建技能」
- 「改善/優化現有 skill」
- 「評估 skill 效果」/ 「跑 eval」
- 「優化 skill 的觸發描述」
