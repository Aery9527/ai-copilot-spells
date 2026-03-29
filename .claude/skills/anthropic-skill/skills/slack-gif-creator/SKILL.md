---
name: slack-gif-creator
description: Knowledge and utilities for creating animated GIFs optimized for Slack. Provides constraints, validation tools, and animation concepts. Use when users request animated GIFs for Slack like "make me a GIF of X doing Y for Slack."
source: anthropic-skills/skills/slack-gif-creator/SKILL.md
---

## 概述

為 Slack 創作符合平台限制的動態 GIF，提供完整工具鏈：幀組裝器（GIFBuilder）、驗證器、緩動函數、常見動畫概念。使用 Python PIL/Pillow 從零繪製。

## Slack 規格限制

| 類型 | 尺寸 | FPS | 顏色數 | 時長 |
|------|------|-----|--------|------|
| Emoji GIF | 128×128 | 10-30 | 48-128 | < 3 秒 |
| Message GIF | 480×480 | 10-30 | 48-128 | 無硬限制 |

## 核心工作流程

```python
from core.gif_builder import GIFBuilder
from PIL import Image, ImageDraw

builder = GIFBuilder(width=128, height=128, fps=10)

for i in range(12):
    frame = Image.new('RGB', (128, 128), (240, 248, 255))
    draw = ImageDraw.Draw(frame)
    # 用 PIL 繪製動畫幀...
    builder.add_frame(frame)

builder.save('output.gif', num_colors=48, optimize_for_emoji=True)
```

## 可用工具模組

| 模組 | 用途 |
|------|------|
| `core.gif_builder` | 組裝幀、優化輸出 |
| `core.validators` | 驗證是否符合 Slack 要求 |
| `core.easing` | 緩動函數（7 種：linear/ease_in/ease_out/bounce/elastic/back 等）|
| `core.frame_composer` | 便利函數（漸層背景、畫圓、畫文字、畫星形）|

## 動畫概念庫

| 動畫類型 | 實作方式 |
|---------|---------|
| 抖動/震動 | `math.sin()` 偏移 + 隨機變化 |
| 脈動/心跳 | `math.sin(t * freq * 2π)` 縮放 |
| 彈跳 | `interpolate()` + `bounce_out` easing |
| 旋轉/搖晃 | `image.rotate()` 或 sine 角度 |
| 淡入/淡出 | RGBA alpha 通道調整 |
| 滑入 | `interpolate()` + `ease_out` 位移 |
| 爆炸/粒子 | 隨機角度+速度的粒子系統 |

## 繪圖品質指南

- **線條寬度**：始終用 `width=2+`，避免細線看起來粗糙
- **視覺深度**：用漸層背景、分層形狀增加複雜度
- **有趣形狀**：組合多個幾何圖形（星形+光暈、圓形+環）
- **色彩對比**：暗輪廓配亮形狀，亮輪廓配暗形狀
- **創意組合**：彈跳+旋轉、脈動+滑動等組合動畫

## 解決什麼問題

Slack GIF 有嚴格的尺寸和文件大小限制，用一般圖像工具難以精確控制。此 skill 提供符合 Slack 規格的完整工具鏈，從動畫創作到驗證一條龍。

## 何時使用（觸發條件）

- 「做個 Slack GIF」/ 「Slack emoji 動態」
- 「動態圖」+ Slack 語境
- 「make me a GIF of X doing Y for Slack」

## 優化策略（縮小文件）

按效果排序：
1. 降低 FPS（10 而非 20）
2. 減少顏色數（`num_colors=48`）
3. 縮小尺寸（128×128 而非 480×480）
4. 移除重複幀（`remove_duplicates=True`）
5. Emoji 模式（`optimize_for_emoji=True`）

## 依賴套件

```bash
pip install pillow imageio numpy
```
