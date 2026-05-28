---
name: canvas-design
description: Create beautiful visual art in .png and .pdf documents using design philosophy. You should use this skill when the user asks to create a poster, piece of art, design, or other static piece. Create original visual designs, never copying existing artists' work to avoid copyright violations.
---

## 概述

將使用者需求轉化為設計哲學宣言，再用 Python 在畫布上創作高工藝標準的靜態視覺作品，輸出為 PDF 或 PNG。

## 能做什麼

- 創作海報、藝術品、設計作品等靜態視覺。
- 撰寫 4 到 6 段的設計哲學宣言。
- 在畫布上以 Python 實現視覺哲學。
- 同時輸出 `.md` 哲學文件與 `.pdf` 或 `.png` 作品。
- 支援多頁輸出，例如咖啡桌書風格作品。

## 設計特色

- 90% 視覺，10% 文字。
- 必須搜尋 [`skill-source/anthropic-skills/skills/canvas-design/canvas-fonts/`](../../../../../skill-source/anthropic-skills/skills/canvas-design/canvas-fonts/) 並選擇合適字體。
- 作品必須看起來像經過長時間精修，而不是快速拼裝。
- 必須從原始請求提取概念 DNA，並把它隱含在設計裡。
- 支援第二次精修循環。

## 關鍵技術棧

- Python 繪圖工具，例如 reportlab、PIL 或 Pillow、matplotlib。
- [`skill-source/anthropic-skills/skills/canvas-design/canvas-fonts/`](../../../../../skill-source/anthropic-skills/skills/canvas-design/canvas-fonts/) 字體資源目錄。

## 與 `algorithmic-art` 的差異

- `canvas-design` 產生靜態 PDF 或 PNG，偏海報與印刷。
- `algorithmic-art` 產生互動 HTML artifact，偏數位生成藝術。
- `canvas-design` 主要媒介是 Python 繪圖。
- `algorithmic-art` 主要媒介是 p5.js JavaScript。

## 重要注意事項

- 嚴禁複製現有藝術家的作品。
- 所有元素必須留在畫布邊界內，不可超出或重疊失控。
- 第一版完成後必須進行第二次精修循環。
- 文字必須極少，但字體選擇仍是設計的一部分。
