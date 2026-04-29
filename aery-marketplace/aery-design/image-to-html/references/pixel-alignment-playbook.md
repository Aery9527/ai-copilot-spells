# Pixel Alignment Playbook

## 快速導覽

- [目標](#目標)
- [基準建立](#基準建立)
- [資產裁切策略](#資產裁切策略)
- [視覺比對流程](#視覺比對流程)
- [如何解讀 diff 結果](#如何解讀-diff-結果)
- [驗收建議](#驗收建議)

## 目標

這份參考文件補充 [SKILL.md](../SKILL.md) 的實戰細節，重點是讓「圖片轉 HTML」不是停在大概像，而是能快速收斂到有依據的高擬真版本。

[返回開頭](#快速導覽)

## 基準建立

1. 先用 [scripts/image_info.py](../scripts/image_info.py) 量原圖尺寸。
2. HTML 初版若沒有 responsive 要求，直接以原圖寬高當基準。
3. 預覽與 screenshot 必須共用同一組尺寸。
4. 如果比較圖的高寬不同，先修尺寸，不要先看 diff。

建議指令：

```bash
python scripts/image_info.py --image source.png --json
```

[返回開頭](#快速導覽)

## 資產裁切策略

裁切前先問兩個問題：

1. 這塊內容是不是複雜到不值得手刻？
2. 這塊內容是不是可以獨立存在，而不是把父容器一起截進來？

### 應裁切

- 書封、照片、人物插畫、複雜裝飾、手寫字樣、噪聲紋理

### 不應裁切

- 標題 bar
- headline 文字
- feature list
- 單純色塊、圓角、箭頭、邊框
- 整個欄位容器

### 裁切守則

- 優先裁最小必要 box
- 保留資產自身邊界，不把周邊大塊留白一起切進去
- 同一區塊若只有其中一張圖複雜，不要因為省事把整塊都變成圖片

建議指令：

```bash
python scripts/crop_image.py --source source.png --output asset.png --box 120,40,381,350 --json
```

[返回開頭](#快速導覽)

## 視覺比對流程

1. 啟動本地預覽
2. 設定與原圖完全一致的 viewport
3. 擷取 viewport screenshot
4. 用 [scripts/visual_diff.py](../scripts/visual_diff.py) 比對
5. 先看尺寸，再看 `diff_bbox`
6. 只修造成差異的 root cause

建議指令：

```bash
python scripts/visual_diff.py ^
  --expected source.png ^
  --actual render.png ^
  --diff-out diff.png ^
  --overlay-out overlay.png ^
  --json
```

[返回開頭](#快速導覽)

## 如何解讀 diff 結果

### `changed_pixels`

- 反映有差異的像素數量
- 適合看「改動範圍」是不是縮小

### `mean_diff_ratio`

- 反映整體差異強度
- 用來看每次調整後是否朝正確方向收斂

### `diff_bbox`

- 最重要，因為它直接告訴你差異聚集在哪
- 若 bbox 很窄，通常是某條 bar、邊框、字級或單一圖片位置問題
- 若 bbox 幾乎包住全畫面，通常是整體尺寸、間距、字體或大面積背景錯

[返回開頭](#快速導覽)

## 驗收建議

1. 先確認：
   - HTML 文字是可選取的
   - 複雜資產不是用整欄截圖偽裝
   - screenshot 尺寸與原圖一致
2. 再確認：
   - `mean_diff_ratio` 比初版明顯下降
   - `diff_bbox` 不再落在明顯錯誤區塊
3. 最後人工看：
   - 沒有雙重 bar / 雙重標題
   - 沒有奇怪白縫、邊界、比例壓縮
   - 重複元素在三欄中的視覺權重一致

[返回開頭](#快速導覽)
