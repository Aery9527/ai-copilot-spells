---
name: internal-comms
description: A set of resources to help me write all kinds of internal communications, using the formats that my company likes to use. Claude should use this skill whenever asked to write some sort of internal communications (status reports, leadership updates, 3P updates, company newsletters, FAQs, incident reports, project updates, etc.).
source: anthropic-skills/skills/internal-comms/SKILL.md
---

## 概述

根據公司特定的格式規範撰寫各種內部溝通文件，透過讀取對應範例模板確保格式、語氣一致。

## 能做什麼

- 撰寫 **3P Updates**（Progress/Plans/Problems 進度更新）
- 撰寫**公司電子報**（company newsletters）
- 撰寫 **FAQ 回答**
- 撰寫**狀態報告**（status reports）
- 撰寫**領導層更新**（leadership updates）
- 撰寫**專案更新**（project updates）
- 撰寫**事故報告**（incident reports）

## 工作流程

```
1. 識別溝通類型
2. 從 examples/ 目錄讀取對應指南文件
3. 按照該文件的格式、語氣、內容要求撰寫
```

### 指南文件對應

| 溝通類型 | 讀取文件 |
|---------|---------|
| 3P 進度更新 | `examples/3p-updates.md` |
| 公司電子報 | `examples/company-newsletter.md` |
| FAQ 回答 | `examples/faq-answers.md` |
| 其他類型 | `examples/general-comms.md` |

## 解決什麼問題

不同公司有不同的溝通風格和格式偏好。此 skill 確保所有內部溝通都遵循公司既定的格式標準，維持一致性，不需要每次重新解釋格式要求。

## 何時使用（觸發條件）

- 「寫 3P update」/ 「3P 更新」
- 「公司電子報」/ 「newsletter」
- 「狀態報告」/ 「status report」
- 「領導層更新」/ 「leadership update」
- 「事故報告」/ 「incident report」
- 任何內部溝通撰寫請求

## 關鍵詞

3P updates、company newsletter、company comms、weekly update、FAQs、common questions、updates、internal comms

## 重要注意事項

- 如果溝通類型不符合現有指南，需要澄清或尋求更多情境
- 不同溝通類型有不同的格式規範——必須讀取對應文件
- 此 skill 包含的是格式框架，具體內容需要使用者提供
