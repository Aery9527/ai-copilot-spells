---
name: theme-factory
description: Toolkit for styling artifacts with a theme. These artifacts can be slides, docs, reportings, HTML landing pages, etc. There are 10 pre-set themes with colors/fonts that you can apply to any artifact that has been creating, or can generate a new theme on-the-fly.
source: anthropic-skills/skills/theme-factory/SKILL.md
---

## 概述

為任意 artifact（投影片、文件、HTML 頁面等）套用統一主題樣式。提供 10 個精選主題，每個含色彩調色盤和字體配對，也可以根據需求即時生成自訂主題。

## 使用流程

```
1. 展示 theme-showcase.pdf（讓使用者看到所有主題視覺效果）
2. 詢問選擇哪個主題
3. 等待明確確認
4. 讀取 themes/<主題名>.md 獲取詳細規格
5. 將顏色和字體套用到 artifact
```

## 10 個預設主題

| # | 主題名稱 | 風格描述 |
|---|---------|---------|
| 1 | **Ocean Depths** | 專業平靜的海洋色調 |
| 2 | **Sunset Boulevard** | 溫暖鮮豔的日落色彩 |
| 3 | **Forest Canopy** | 自然厚實的大地色調 |
| 4 | **Modern Minimalist** | 簡潔現代的灰階風格 |
| 5 | **Golden Hour** | 豐富溫暖的秋日調色 |
| 6 | **Arctic Frost** | 清涼清爽的冬日靈感 |
| 7 | **Desert Rose** | 柔和精緻的塵土色調 |
| 8 | **Tech Innovation** | 大膽現代的科技美學 |
| 9 | **Botanical Garden** | 清新有機的花園色彩 |
| 10 | **Midnight Galaxy** | 戲劇宇宙的深邃色調 |

每個主題在 `themes/` 目錄有對應文件，包含完整的 hex 色碼和字體規格。

## 自訂主題生成

若現有主題都不適用：
1. 根據使用者描述生成新主題
2. 取一個代表性名稱（如現有主題的命名風格）
3. 展示給使用者確認
4. 確認後套用

## 解決什麼問題

重新設計每個 artifact 的樣式既耗時又容易不一致。此 skill 提供即用型主題庫，讓 artifact 快速獲得專業、一致的視覺風格，不需要逐一設計配色和字體。

## 何時使用（觸發條件）

- 「套用主題」/ 「換個風格」/ 「美化這個」
- 完成 PPTX/HTML/文件後詢問樣式
- 「這個可以用哪些主題」
- 需要一致視覺識別的任何 artifact

## 與其他 Skills 的關係

- 與 **pptx** 配合：創建投影片後套用主題
- 與 **frontend-design** 配合：提供 HTML artifact 的主題方向
- 與 **canvas-design** 配合：為靜態藝術提供色彩參考
- 與 **brand-guidelines** 的差異：brand-guidelines 是 Anthropic 品牌規範，theme-factory 是通用主題工具

## 重要注意事項

- 展示 `theme-showcase.pdf` 不可修改，只是讓使用者看
- 必須等使用者明確選擇主題後才開始套用
- 主題詳細規格從 `themes/` 目錄讀取
