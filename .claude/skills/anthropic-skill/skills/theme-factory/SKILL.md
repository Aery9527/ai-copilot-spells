---
name: theme-factory
description: Toolkit for styling artifacts with a theme. These artifacts can be slides, docs, reportings, HTML landing pages, etc. There are 10 pre-set themes with colors/fonts that you can apply to any artifact that has been creating, or can generate a new theme on-the-fly.
---

## 概述

為任意 artifact 套用統一主題樣式。提供 10 個預設主題，每個主題包含色彩調色盤與字體配對，也支援即時生成自訂主題。

## 使用流程

1. 先展示 [theme-showcase.pdf](../../../../../skill-source/anthropic-skills/skills/theme-factory/theme-showcase.pdf)，讓使用者看所有主題。
2. 詢問使用者選擇哪個主題。
3. 等待明確確認。
4. 讀取 [`skill-source/anthropic-skills/skills/theme-factory/themes/`](../../../../../skill-source/anthropic-skills/skills/theme-factory/themes/) 下對應主題文件。
5. 把顏色與字體套用到 artifact。

## 預設主題

- `Ocean Depths` — 專業平靜的海洋色調。
- `Sunset Boulevard` — 溫暖鮮豔的日落色彩。
- `Forest Canopy` — 自然厚實的大地色調。
- `Modern Minimalist` — 簡潔現代的灰階風格。
- `Golden Hour` — 豐富溫暖的秋日調色。
- `Arctic Frost` — 清涼清爽的冬日靈感。
- `Desert Rose` — 柔和精緻的塵土色調。
- `Tech Innovation` — 大膽現代的科技美學。
- `Botanical Garden` — 清新有機的花園色彩。
- `Midnight Galaxy` — 戲劇宇宙的深邃色調。

每個主題的詳細規格都在 [`skill-source/anthropic-skills/skills/theme-factory/themes/`](../../../../../skill-source/anthropic-skills/skills/theme-factory/themes/) 目錄。

## 自訂主題生成

1. 根據使用者描述生成新主題。
2. 取一個與既有主題風格一致的名稱。
3. 先展示給使用者確認。
4. 確認後再套用。

## 與其他 Skills 的關係

- 可與 `pptx` 配合，用於投影片套主題。
- 可與 `frontend-design` 配合，用於 HTML artifact 主題方向。
- 可與 `canvas-design` 配合，用於靜態藝術色彩參考。
- 與 `brand-guidelines` 不同；`brand-guidelines` 是 Anthropic 品牌規範，`theme-factory` 是通用主題工具。

## 重要注意事項

- [theme-showcase.pdf](../../../../../skill-source/anthropic-skills/skills/theme-factory/theme-showcase.pdf) 只用於展示，嚴禁修改。
- 必須等使用者明確選定主題後才開始套用。
- 主題細節必須從 [`skill-source/anthropic-skills/skills/theme-factory/themes/`](../../../../../skill-source/anthropic-skills/skills/theme-factory/themes/) 目錄讀取。
