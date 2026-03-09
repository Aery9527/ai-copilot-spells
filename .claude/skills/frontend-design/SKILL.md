---
name: frontend-design
description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications (examples include websites, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI). Generates creative, polished code and UI design that avoids generic AI aesthetics.
source: anthropic-skills/skills/frontend-design/SKILL.md
---

## 概述

創作具有強烈美學觀點的生產級前端介面，明確對抗「AI 爛設計」——那些千篇一律的紫色漸層、Inter 字體、居中佈局。每個設計都應該令人難忘且獨特。

## 能做什麼

- 建構 HTML/CSS/JS、React、Vue 等前端組件和頁面
- 設計具有強烈視覺風格的 UI（極簡主義、最大主義、復古未來風等）
- 實作動畫與微互動（CSS animations、Motion library for React）
- 創作獨特的排版組合（配對展示字體與正文字體）
- 建立氛圍感背景（漸層網格、噪點紋理、幾何圖案、深陰影）
- 設計非對稱、打破網格的佈局

## 設計指導原則

### 字體
- **禁止使用**：Arial、Inter、Roboto、system fonts
- **推薦**：有個性的展示字體搭配精緻正文字體
- 字體本身就是設計元素

### 色彩
- 使用 CSS 變數保持一致性
- 主色主導（60-70% 視覺重量）+ 1-2 支撐色 + 1 強調色
- **禁止**：紫色漸層 + 白色背景的老套組合

### 動畫
- 頁面載入時的漸層出現（`animation-delay`）
- hover 狀態要驚喜感
- 滾動觸發動畫
- CSS-only 優先，React 用 Motion library

### 空間構成
- 非對稱佈局、重疊元素、對角流向
- 打破網格的元素
- 充裕留白 **或** 精心控制的密度（二選一，徹底執行）

## 解決什麼問題

使用者希望獲得能在真實產品中使用的前端代碼，而非看起來由 AI 生成的千篇一律設計。此 skill 強迫自己做出大膽的美學選擇，創作真正令人印象深刻的 UI。

## 何時使用（觸發條件）

- 「幫我做網頁」/ 「做個 UI」/ 「建立組件」
- landing page、dashboard、React component
- 「美化」/ 「設計」任何 web 介面
- 需要 HTML/CSS 輸出的設計任務

## 關鍵原則

- **先思考，後編碼**：確定概念方向再實作
- **大膽選擇**：極端主義者（極簡 or 最大主義），不要平庸的中間路線
- **獨特性**：每個設計都應該與其他設計不同，不要收斂到相同選擇

## 重要注意事項

- 最大主義設計需要複雜代碼（大量動畫、效果）
- 極簡設計需要對間距、排版的精確控制
- 不同代的設計應使用不同字體和美學——禁止每次都用 Space Grotesk
- 生產就緒：代碼要可用，不只是美觀
