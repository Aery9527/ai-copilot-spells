---
name: web-artifacts-builder
description: Suite of tools for creating elaborate, multi-component claude.ai HTML artifacts using modern frontend web technologies (React, Tailwind CSS, shadcn/ui). Use for complex artifacts requiring state management, routing, or shadcn/ui components - not for simple single-file HTML/JSX artifacts.
source: anthropic-skills/skills/web-artifacts-builder/SKILL.md
---

## 概述

為 Claude.ai 建構複雜的多組件 HTML artifact，使用現代前端技術棧（React + TypeScript + Tailwind CSS + shadcn/ui），最終打包成一個自包含的 HTML 文件。

## 技術棧

- **React 18** + TypeScript（透過 Vite）
- **Tailwind CSS 3.4.1**（shadcn/ui 主題系統）
- **shadcn/ui**（40+ 預裝組件）
- **Radix UI**（所有相依項目預包含）
- **Parcel**（打包工具）
- **路徑別名**：`@/` 已配置

## 四步工作流程

```bash
# Step 1: 初始化專案
bash scripts/init-artifact.sh <project-name>
cd <project-name>

# Step 2: 開發 artifact（編輯生成的文件）

# Step 3: 打包成單一 HTML
bash scripts/bundle-artifact.sh
# → 生成 bundle.html（所有 JS/CSS 內嵌）

# Step 4: 分享給使用者（作為 Claude artifact 展示）

# Step 5: 測試（可選）
```

## 何時使用此 skill vs frontend-design

| | web-artifacts-builder | frontend-design |
|---|---|---|
| 複雜度 | 多組件、需要狀態管理、路由 | 單個組件或頁面 |
| shadcn/ui | ✅ 預裝 40+ 組件 | ❌ 手寫 CSS |
| 技術棧 | React + Tailwind + shadcn | HTML/CSS/JS 或 React |
| 用途 | 複雜 Claude artifact | 設計導向 UI |

## 解決什麼問題

Claude.ai artifact 有單文件限制，但複雜應用需要多組件和現代工具鏈。此 skill 提供完整的本地開發環境 + 打包流程，讓複雜 React 應用可以作為單一 HTML artifact 分享。

## 何時使用（觸發條件）

- 需要 shadcn/ui 組件的 Claude artifact
- 複雜的多組件應用（儀表板、表單、表格等）
- 需要 React 狀態管理或路由的 artifact
- 「用 React 做個 artifact」/ 「shadcn/ui 介面」

## 設計原則（防 AI 爛設計）

**嚴禁**：
- 過度居中佈局
- 紫色漸層
- 統一圓角
- Inter 字體

## shadcn/ui 組件參考

https://ui.shadcn.com/docs/components

## 重要注意事項

- 需要 Node 18+（init 腳本自動偵測並鎖定正確 Vite 版本）
- `bundle.html` 是最終交付物（完全自包含，無外部依賴）
- 視覺測試建議在打包後用瀏覽器或 Playwright 驗證
- 不適用於簡單的單文件 HTML/JSX artifact（用 `frontend-design` 即可）
