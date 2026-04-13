---
name: image-to-html
description: >-
  將 PNG、JPG、screenshot、poster、banner、landing page mockup 等單張視覺稿轉成
  高擬真 HTML/CSS，並在需要 pixel-perfect 對齊、使用原圖局部裁切資產、或 debug
  「HTML 跟原圖哪裡怪怪的」時使用。只要使用者提到「把圖片轉成 html」「照圖刻版」
  「用原圖 crop 資產」「pixel perfect 對齊」「跟原稿差在哪」「幫我修到像原圖」，
  就應優先使用此 skill，並搭配內建 Python 工具做尺寸檢查、精準裁切與視覺 diff。
---

# Image to HTML

## 快速導覽

- [適用情境](#適用情境)
- [工作原則](#工作原則)
- [操作流程](#操作流程)
- [Python 工具](#python-工具)
- [常見失真與排錯](#常見失真與排錯)
- [輸出格式](#輸出格式)
- [參考資料](#參考資料)
- [範例 Prompt](#範例-prompt)

## 適用情境

這個 skill 專門處理「**把一張視覺稿還原成 HTML/CSS**」的工作，包含但不限於：

- 海報、宣傳圖、課程單頁、活動 banner、社群卡片、landing page hero、產品介紹截圖
- 需要把畫面中的**文字變成真正 HTML 文字**
- 需要把畫面中的**簡單幾何、色塊、框線、陰影**改寫成 CSS
- 需要把畫面中的**複雜插畫、照片、封面、裝飾物**從原圖局部裁切後嵌回版面
- 已經有 HTML，但使用者說「看起來怪怪的」「跟原圖不一樣」「幫我找哪裡歪掉」

若任務核心是 OCR、整頁 PDF 抽文字、或純圖片壓縮，這個 skill 不是首選。

[返回開頭](#快速導覽)

## 工作原則

1. **先還原結構，再追像素。** 先把區塊、層級、文字、配色與主要尺寸打對，之後再用 diff 收斂。
2. **文字盡量保留為文字。** 除非使用者明講可以整張截圖嵌入，否則標題、段落、條列、按鈕文案都應寫成 HTML 文字。
3. **能用 CSS 畫的，不要先裁圖。** 純色塊、邊框、圓角、陰影、箭頭、簡單 icon 優先用 CSS。
4. **真的複雜才裁圖，而且只裁最小必要資產。** 不要把整欄、整個 hero、整個 panel 當資產塞回去，避免出現「海報裡再嵌一張海報」。
5. **預設先做精準 static 版。** 若使用者沒要求 responsive，先把寬高、間距、字級、裁切做準，再考慮流式重構。
6. **驗證時只比同尺寸畫面。** 視覺 diff 必須拿與原圖同尺寸的 screenshot，比 `fullPage` 長圖沒有意義。
7. **看到怪異結果先找 root cause。** 例如雙重色條、裁切邊界怪、比例錯，不要直接亂調 offset。

[返回開頭](#快速導覽)

## 操作流程

1. **釐清邊界與輸出**
   - 取得原圖路徑、目標 HTML 路徑
   - 確認要 static 還是 responsive
   - 確認哪些元素必須是文字、哪些可以沿用原圖局部裁切
2. **先量測原圖**
   - 使用 [scripts/image_info.py](scripts/image_info.py) 讀出寬高與 mode
   - 若沒有額外要求，HTML 初版先對齊原圖尺寸
3. **拆解畫面**
   - 分出文字、可 CSS 化元素、必須裁切的複雜資產
   - 若某個資產只是 panel 裡的一小塊內容，只裁那塊，不裁整個 panel
4. **實作 HTML/CSS**
   - 先建立外層 grid / flex 結構
   - 再補 headline、feature list、spacing、顏色、陰影
5. **必要時裁切原圖資產**
   - 使用 [scripts/crop_image.py](scripts/crop_image.py)
   - 裁切結果應是獨立 asset，而不是把整張設計圖當 `background-position` 偏移來源
6. **做同尺寸預覽**
   - 預覽頁面時，viewport 設為與原圖完全一致
   - screenshot 時不要用 `fullPage`
7. **做視覺 diff**
   - 使用 [scripts/visual_diff.py](scripts/visual_diff.py) 比對原圖與 render
   - 先看 size 是否一致，再看 `mean_diff_ratio`、`changed_pixels`、`diff_bbox`
8. **根據 diff 修 root cause**
   - `diff_bbox` 若集中在版頭，先檢查是否重複畫了 bar / heading
   - 若差異集中在單一資產，優先重查 crop box 與 object-fit / background-size
   - 若整片都歪，先回頭查整體寬高、padding、gap、字級，而不是盲調局部
9. **收尾**
   - 交付 HTML 與必要資產
   - 若有做 diff，保留 diff / overlay 方便後續回歸

[返回開頭](#快速導覽)

## Python 工具

### 相依

- Python 3
- Pillow

若執行時看到 `ModuleNotFoundError: No module named 'PIL'`，先安裝：

```bash
pip install Pillow
```

### 工具清單

1. [scripts/image_info.py](scripts/image_info.py)
   - 讀出圖片尺寸與 mode
   - 範例：
     ```bash
     python scripts/image_info.py --image poster.png --json
     ```
2. [scripts/crop_image.py](scripts/crop_image.py)
   - 依 `xyxy` 或 `xywh` 精準裁切資產
   - 範例：
     ```bash
     python scripts/crop_image.py --source poster.png --output cover-orange.png --box 31,34,436,351 --json
     ```
3. [scripts/visual_diff.py](scripts/visual_diff.py)
   - 比對原圖與 render，輸出 `mean_diff_ratio`、`changed_pixels`、`diff_bbox`
   - 可額外輸出 raw diff 圖與 overlay 圖
   - 範例：
     ```bash
     python scripts/visual_diff.py --expected poster.png --actual render.png --diff-out diff.png --overlay-out overlay.png --json
     ```

[返回開頭](#快速導覽)

## 常見失真與排錯

1. **雙重色條 / 雙重標題**
   - 原因通常不是 CSS 顏色錯，而是把含版頭的整欄截圖又塞回 HTML 版頭區。
   - 修法：只裁真正的封面或插畫資產，把 bar/headline 繼續留在 HTML。
2. **三欄等分裁切看起來邊界怪**
   - 不要假設資產剛好等分整張圖；多數設計都有內縮留白與欄位 padding。
   - 修法：量實際 box，再裁最小必要區塊。
3. **畫面高度對不起來**
   - 最常見是拿 `fullPage` screenshot 跟原圖比。
   - 修法：viewport 高度與原圖一致，且 screenshot 只截 viewport。
4. **整體很像但還是「怪」**
   - 先檢查字級、line-height、padding、gap、box-shadow，不要第一時間怪圖片。
5. **局部資產比例不對**
   - 先查 `<img>` 的寬高、`object-fit`、容器高度，再查 crop box。

更完整的排錯節奏與決策準則，參考 [references/pixel-alignment-playbook.md](references/pixel-alignment-playbook.md)。

[返回開頭](#快速導覽)

## 輸出格式

預設交付物：

- 主要 HTML 檔
- 必要的局部裁切資產（若有）
- 簡短說明哪些元素保留為文字、哪些元素沿用原圖裁切

若任務包含對齊驗證，額外交付：

- screenshot 與原圖同尺寸的比較結果
- `visual_diff.py` 產生的指標摘要
- diff 圖或 overlay 圖（若有助於後續迭代）

[返回開頭](#快速導覽)

## 參考資料

- [references/pixel-alignment-playbook.md](references/pixel-alignment-playbook.md)
- [evals/evals.json](evals/evals.json)

[返回開頭](#快速導覽)

## 範例 Prompt

1. `這張 PNG 幫我轉成 html，桌面版先做 1:1，高度寬度都跟原圖一樣，文字要可選取。`
2. `現在排版差不多了，但三個複雜插畫可以直接用原圖裁切嗎？請不要把整欄當背景圖。`
3. `我懷疑現在的 html 跟原稿差在 header 和圖塊裁切，請用 Python 視覺 diff 告訴我哪裡怪。`

[返回開頭](#快速導覽)
