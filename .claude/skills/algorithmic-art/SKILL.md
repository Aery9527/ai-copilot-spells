---
name: algorithmic-art
description: Creating algorithmic art using p5.js with seeded randomness and interactive parameter exploration. Use this when users request creating art using code, generative art, algorithmic art, flow fields, or particle systems. Create original algorithmic art rather than copying existing artists' work to avoid copyright violations.
source: anthropic-skills/skills/algorithmic-art/SKILL.md
---

## 概述

將使用者的抽象輸入轉化為「演算法哲學」，再以 p5.js 實作成可互動的生成藝術 HTML artifact。每次執行（不同 seed）會產生獨特但風格一致的視覺輸出。

## 能做什麼

- 根據使用者輸入設計「演算法哲學」（4-6 段文字宣言）
- 用 p5.js 實作流場、粒子系統、噪聲場、遞歸結構等生成算法
- 輸出自包含 HTML artifact（包含 seed 導航、參數控制面板）
- 支援 seed 導航（上一個/下一個/隨機/跳轉）產生 100+ 種變體
- 使用 Anthropic 品牌的 UI 框架（Poppins/Lora 字體、淺色主題）

## 解決什麼問題

傳統靜態圖像設計工具無法創建「活的算法」—— 每次運行都能產生獨特但美麗的輸出。此 skill 解決了：
- 需要程序化/生成式藝術但不懂 p5.js 的使用者
- 想探索同一算法不同隨機種子變體的需求
- 希望藝術作品有可重現性（固定 seed = 固定輸出）的需求

## 何時使用（觸發條件）

- 「幫我做生成藝術」/ 「algorithmic art」
- 「流場」/ 「粒子系統」/ 「procedural art」
- 「用代碼創作藝術」
- 「generative art」/ 「p5.js」相關請求

## 關鍵技術棧

- **p5.js** (from CDN, 1.7.0)：畫布、粒子、噪聲函數
- **Seeded randomness**：`randomSeed()` + `noiseSeed()` 確保可重現性
- **templates/viewer.html**：必須作為 HTML artifact 的起點（含固定 UI 結構）
- 輸出格式：`.md`（哲學文件）+ `.html`（互動 artifact）

## 工作流程

```
1. 解讀使用者意圖
2. 撰寫「演算法哲學」(.md)
3. 推導概念核心（subtle reference）
4. 讀取 templates/viewer.html 作為起點
5. 實作 p5.js 算法（替換 variable 部分）
6. 輸出自包含 HTML artifact
```

## 重要注意事項

- **模板優先**：必須讀取 `templates/viewer.html`，不可從零開始寫 HTML
- **保持固定 UI**：seed 控制、Actions 按鈕、Anthropic 樣式不可修改
- **只替換 variable 部分**：p5.js 算法、參數定義、Parameter 控制項
- 禁止複製現有藝術家的風格（版權問題），需創作原創作品
- 90% 算法生成，10% 固定參數
