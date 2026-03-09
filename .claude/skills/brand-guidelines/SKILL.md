---
name: brand-guidelines
description: Applies Anthropic's official brand colors and typography to any sort of artifact that may benefit from having Anthropic's look-and-feel. Use it when brand colors or style guidelines, visual formatting, or company design standards apply.
source: anthropic-skills/skills/brand-guidelines/SKILL.md
---

## 概述

提供 Anthropic 官方品牌的顏色代碼與字體規範，用於對任何 artifact 套用一致的品牌視覺識別。

## 能做什麼

- 提供精確的 Anthropic 品牌色彩（含 RGB/Hex 值）
- 指定標題/正文的字體規範
- 對 PPTX、HTML、PDF 等 artifact 套用品牌樣式
- 智慧字體退回（無 Poppins/Lora 時自動退回 Arial/Georgia）

## Anthropic 品牌規格

### 顏色

| 名稱 | Hex | 用途 |
|------|-----|------|
| Dark | `#141413` | 主要文字、深色背景 |
| Light | `#faf9f5` | 淺色背景、深色上的文字 |
| Mid Gray | `#b0aea5` | 次要元素 |
| Light Gray | `#e8e6dc` | 細微背景 |
| Orange（主強調）| `#d97757` | 主要強調色 |
| Blue（次強調）| `#6a9bcc` | 次要強調色 |
| Green（三強調）| `#788c5d` | 第三強調色 |

### 字體

- **標題（24pt+）**：Poppins（退回 Arial）
- **正文**：Lora（退回 Georgia）

## 解決什麼問題

在產生 artifact 時確保視覺一致性，讓所有輸出都符合 Anthropic 的品牌識別，避免各 artifact 使用不同風格造成品牌碎片化。

## 何時使用（觸發條件）

- 任何提到 Anthropic 品牌、公司樣式的請求
- 需要品牌色彩代碼時
- 對 PPTX/HTML/PDF 套用公司視覺標準
- 其他 skills（如 algorithmic-art、canvas-design）需要 Anthropic UI 樣式時

## 重要注意事項

- 字體需預先安裝於環境中以獲得最佳效果
- 非文字形狀使用強調色（橘/藍/綠循環）
- 此 skill 不執行設計創作，只提供規格參考
