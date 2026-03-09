---
name: canvas-design
description: Create beautiful visual art in .png and .pdf documents using design philosophy. You should use this skill when the user asks to create a poster, piece of art, design, or other static piece. Create original visual designs, never copying existing artists' work to avoid copyright violations.
source: anthropic-skills/skills/canvas-design/SKILL.md
---

## 概述

將使用者需求轉化為「設計哲學」宣言，再用 Python 在畫布上創作博物館級靜態視覺作品，輸出為 PDF 或 PNG。強調視覺優先、文字極少的藝術創作。

## 能做什麼

- 創作海報、藝術品、設計作品（靜態視覺）
- 撰寫「設計哲學」宣言（4-6 段）命名藝術運動
- 在畫布上以 Python 實現視覺哲學
- 輸出 `.md`（哲學文件）+ `.pdf` 或 `.png`（作品）
- 支援多頁（咖啡桌書風格）

## 設計特色

- **90% 視覺，10% 文字**：資訊透過空間、形式、色彩傳遞
- **精通字體**：搜尋 `./canvas-fonts` 目錄，使用適合的字體
- **高工藝標準**：作品要看起來像花了無數小時精心製作
- **隱藏概念 DNA**：從原始請求提取微妙的概念主題，編織進設計中
- 支援反覆細化（第二次精修循環）

## 解決什麼問題

使用者需要高品質靜態視覺設計但沒有設計工具或技能。此 skill 透過「哲學→代碼→藝術」的流程，產生博物館或雜誌等級的作品，而非普通的 AI 生成圖片。

## 何時使用（觸發條件）

- 「幫我做海報」/ 「設計一張圖」
- 「藝術品」/ 「視覺設計」/ 「插圖」
- 任何需要靜態美術創作的請求
- 需要 PNG/PDF 視覺輸出的場合

## 關鍵技術棧

- **Python**：畫布繪製（reportlab、PIL/Pillow、matplotlib 等）
- **./canvas-fonts**：字體資源目錄
- 輸出：`.md`（哲學）+ `.pdf` 或 `.png`（作品）

## 與 algorithmic-art 的差異

| | canvas-design | algorithmic-art |
|---|---|---|
| 輸出 | 靜態 PDF/PNG | 互動 HTML artifact |
| 媒介 | Python 繪圖 | p5.js JavaScript |
| 互動性 | 無 | 有（seed 導航、參數） |
| 用途 | 海報、印刷 | 數位生成藝術 |

## 重要注意事項

- 禁止複製現有藝術家的作品（版權問題）
- 所有元素必須在畫布邊界內，不可超出或重疊
- 第一版完成後必須進行第二次精修循環
- 文字極少但字體選擇是設計的一部分，必須設計導向
