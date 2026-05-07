---
name: slack-gif-creator
description: Knowledge and utilities for creating animated GIFs optimized for Slack. Provides constraints, validation tools, and animation concepts. Use when users request animated GIFs for Slack like "make me a GIF of X doing Y for Slack."
---

## 概述

為 Slack 創作符合平台限制的動態 GIF，提供完整工具鏈，包括幀組裝器、驗證器、緩動函數與常見動畫概念。

## Slack 規格限制

- Emoji GIF：
  - 尺寸：`128x128`
  - FPS：`10-30`
  - 顏色數：`48-128`
  - 時長：小於 3 秒
- Message GIF：
  - 尺寸：`480x480`
  - FPS：`10-30`
  - 顏色數：`48-128`
  - 時長：沒有硬限制

## 核心工作流程

```python
from core.gif_builder import GIFBuilder
from PIL import Image, ImageDraw

builder = GIFBuilder(width=128, height=128, fps=10)

for i in range(12):
    frame = Image.new('RGB', (128, 128), (240, 248, 255))
    draw = ImageDraw.Draw(frame)
    builder.add_frame(frame)

builder.save('output.gif', num_colors=48, optimize_for_emoji=True)
```

## 可用工具模組

- `core.gif_builder` — 組裝幀與優化輸出。
- `core.validators` — 驗證是否符合 Slack 要求。
- `core.easing` — 提供多種緩動函數。
- `core.frame_composer` — 提供漸層背景、圖形與文字輔助函數。

## 動畫概念庫

- 抖動或震動：用 `math.sin()` 偏移搭配隨機變化。
- 脈動或心跳：用 `math.sin(t * freq * 2π)` 控制縮放。
- 彈跳：用 `interpolate()` 搭配 `bounce_out` easing。
- 旋轉或搖晃：用 `image.rotate()` 或 sine 角度。
- 淡入或淡出：調整 RGBA alpha 通道。
- 滑入：用 `interpolate()` 搭配 `ease_out` 位移。
- 爆炸或粒子：用隨機角度與速度的粒子系統。

## 繪圖品質指南

- 線條寬度始終用 `width=2+`，避免細線粗糙。
- 用漸層背景與分層形狀增加視覺深度。
- 用幾何圖形組合做出更有趣的形狀。
- 保持足夠色彩對比。
- 鼓勵組合多種動畫效果。

## 優化策略

1. 先降低 FPS。
2. 再減少顏色數。
3. 再縮小尺寸。
4. 再移除重複幀。
5. 最後開啟 emoji 最佳化模式。

## 依賴套件

```bash
pip install pillow imageio numpy
```
