---
name: web-artifacts-builder
description: Suite of tools for creating elaborate, multi-component claude.ai HTML artifacts using modern frontend web technologies (React, Tailwind CSS, shadcn/ui). Use for complex artifacts requiring state management, routing, or shadcn/ui components - not for simple single-file HTML/JSX artifacts.
---

## 概述

為 Claude.ai 建構複雜的多組件 HTML artifact，使用 React、TypeScript、Tailwind CSS 與 shadcn/ui，最後打包成單一自包含 HTML 文件。

## 技術棧

- React 18 + TypeScript（透過 Vite）
- Tailwind CSS 3.4.1
- shadcn/ui
- Radix UI
- Parcel
- 路徑別名 `@/`

## 四步工作流程

```bash
bash skill-source/anthropic-skills/skills/web-artifacts-builder/scripts/init-artifact.sh <project-name>
cd <project-name>

# 開發 artifact

bash ../skill-source/anthropic-skills/skills/web-artifacts-builder/scripts/bundle-artifact.sh
# -> 生成 bundle.html
```

- 初始化專案後，在本地開發 artifact。
- 打包後產出 `bundle.html` 作為最終交付物。
- 如有需要，再補做測試。

## 何時使用此 skill vs `frontend-design`

- `web-artifacts-builder` 適合多組件、需要狀態管理或路由的複雜 artifact。
- `web-artifacts-builder` 已內建 shadcn/ui 與完整 React 工具鏈。
- `frontend-design` 更適合單個組件、單頁面或設計導向 UI。

## 設計原則

- 嚴禁過度居中佈局。
- 嚴禁紫色漸層。
- 嚴禁統一圓角。
- 嚴禁使用 Inter 字體。

## 元件參考

- [shadcn/ui components](https://ui.shadcn.com/docs/components)

## 重要注意事項

- 需要 Node 18+。
- `bundle.html` 是最終交付物，必須保持完全自包含。
- 打包後建議用瀏覽器或 Playwright 驗證視覺與互動。
- 如果只是簡單單文件 HTML 或 JSX artifact，嚴禁誤用此 skill；應改用 `frontend-design`。
