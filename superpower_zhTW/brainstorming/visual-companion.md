# 視覺伴侶指南

用於在腦力激盪期間展示模型、圖表和選項的瀏覽器視覺輔助工具。

## 何時使用

逐問決定，而非逐 session 決定。判斷標準：**使用者透過看到它是否比閱讀它更容易理解？**

**使用瀏覽器** 當內容本身是視覺性的：

- **UI 模型** — 線框圖、版面、導覽結構、元件設計
- **架構圖** — 系統元件、資料流、關係圖
- **並排視覺比較** — 比較兩種版面、兩種配色方案、兩種設計方向
- **設計細節** — 當問題關於外觀與感受、間距、視覺層級時
- **空間關係** — 狀態機、流程圖、以圖表渲染的實體關係

**使用終端機** 當內容是文字或表格性的：

- **需求與範圍問題** — 「X 是什麼意思？」、「哪些功能在範圍內？」
- **概念性 A/B/C 選擇** — 在用文字描述的方案之間選擇
- **取捨清單** — 優缺點、比較表格
- **技術決策** — API 設計、資料建模、架構方案選擇
- **澄清問題** — 任何答案是文字而非視覺偏好的情況

*關於* UI 主題的問題不會自動成為視覺問題。「你想要哪種精靈？」是概念性的——使用終端機。「哪種精靈版面感覺更好？」是視覺性的——使用瀏覽器。

## 運作原理

伺服器監看一個目錄中的 HTML 檔案，並將最新的一個提供給瀏覽器。你將 HTML 內容寫入 `screen_dir`，使用者在瀏覽器中看到它並可以點擊選項。選擇會被記錄到 `state_dir/events`，供你在下一輪讀取。

**內容片段 vs 完整文件：** 若你的 HTML 檔案以 `<!DOCTYPE` 或 `<html` 開頭，伺服器會原樣提供（僅注入輔助腳本）。否則，伺服器會自動將你的內容包裝在 frame template 中——加入標題、CSS 主題、選擇指示器，以及所有互動基礎設施。**預設撰寫內容片段。** 只有在需要完全控制頁面時才撰寫完整文件。

## 啟動 Session

```bash
# 以持久性啟動伺服器（mockup 儲存到專案）
scripts/start-server.sh --project-dir /path/to/project

# 回傳：{"type":"server-started","port":52341,"url":"http://localhost:52341",
#           "screen_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/content",
#           "state_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/state"}
```

從回應中儲存 `screen_dir` 和 `state_dir`。告訴使用者開啟 URL。

**尋找連線資訊：** 伺服器將其啟動 JSON 寫入 `$STATE_DIR/server-info`。若你在背景啟動伺服器且未擷取 stdout，讀取該檔案以取得 URL 和連接埠。使用 `--project-dir` 時，在 `<project>/.superpowers/brainstorm/` 中查看 session 目錄。

**注意：** 傳遞專案根目錄作為 `--project-dir`，以便 mockup 持久保存在 `.superpowers/brainstorm/` 中並在伺服器重啟後仍然存在。若不傳遞，檔案會進入 `/tmp` 並被清除。提醒使用者若尚未新增，將 `.superpowers/` 加入 `.gitignore`。

**依平台啟動伺服器：**

**Claude Code（macOS / Linux）：**
```bash
# 預設模式有效——腳本本身會在背景執行伺服器
scripts/start-server.sh --project-dir /path/to/project
```

**Claude Code（Windows）：**
```bash
# Windows 自動偵測並使用前景模式，這會阻擋工具呼叫。
# 在 Bash 工具呼叫上設定 run_in_background: true，讓伺服器在
# 對話輪次之間持續運行。
scripts/start-server.sh --project-dir /path/to/project
```
透過 Bash 工具呼叫時，設定 `run_in_background: true`。然後在下一輪讀取 `$STATE_DIR/server-info` 以取得 URL 和連接埠。

**Codex：**
```bash
# Codex 會回收背景行程。腳本自動偵測 CODEX_CI 並
# 切換到前景模式。正常執行即可——不需要額外旗標。
scripts/start-server.sh --project-dir /path/to/project
```

**Gemini CLI：**
```bash
# 使用 --foreground 並在 shell 工具呼叫上設定 is_background: true
# 讓行程在輪次之間持續存在
scripts/start-server.sh --project-dir /path/to/project --foreground
```

**其他環境：** 伺服器必須在對話輪次之間持續在背景運行。若你的環境會回收已分離的行程，使用 `--foreground` 並用平台的背景執行機制啟動指令。

若瀏覽器無法連線到 URL（在遠端/容器化設置中常見），請綁定非迴環主機：

```bash
scripts/start-server.sh \
  --project-dir /path/to/project \
  --host 0.0.0.0 \
  --url-host localhost
```

使用 `--url-host` 控制回傳的 URL JSON 中顯示的主機名稱。

## 循環流程

1. **確認伺服器仍在運行**，然後**將 HTML 寫入** `screen_dir` 中的新檔案：
   - 在每次寫入之前，確認 `$STATE_DIR/server-info` 存在。若不存在（或 `$STATE_DIR/server-stopped` 存在），伺服器已關閉——在繼續之前用 `start-server.sh` 重新啟動它。伺服器在閒置 30 分鐘後自動退出。
   - 使用語意化檔名：`platform.html`、`visual-style.html`、`layout.html`
   - **永遠不要重用檔名** — 每個畫面都要有新檔案
   - 使用 Write 工具——**永遠不要使用 cat/heredoc**（會把雜訊倒進終端機）
   - 伺服器自動提供最新的檔案

2. **告訴使用者預期什麼並結束你的輪次：**
   - 提醒他們 URL（每個步驟都要，不只是第一次）
   - 簡短的文字摘要說明畫面上有什麼（例如，「顯示首頁的 3 種版面選項」）
   - 請他們在終端機中回應：「看一下並告訴我你的想法。若想選擇選項，可以點擊。」

3. **在你的下一輪次** — 使用者在終端機回應後：
   - 若 `$STATE_DIR/events` 存在，讀取它——這包含使用者的瀏覽器互動（點擊、選擇），格式為 JSON 行
   - 與使用者的終端機文字合併以獲得完整圖像
   - 終端機訊息是主要回饋；`state_dir/events` 提供結構化的互動資料

4. **迭代或推進** — 若回饋改變了當前畫面，寫一個新檔案（例如，`layout-v2.html`）。只有在當前步驟經過驗證後才移至下一個問題。

5. **返回終端機時卸載** — 當下一步不需要瀏覽器時（例如，澄清問題、取捨討論），推送一個等待畫面以清除舊內容：

   ```html
   <!-- filename: waiting.html（或 waiting-2.html 等） -->
   <div style="display:flex;align-items:center;justify-content:center;min-height:60vh">
     <p class="subtitle">繼續在終端機中進行...</p>
   </div>
   ```

   這樣可以防止使用者盯著一個已解決的選擇，而對話已經繼續了。當下一個視覺問題出現時，像往常一樣推送新的內容檔案。

6. 重複直到完成。

## 撰寫內容片段

只寫進入頁面的內容。伺服器會自動將它包裝在 frame template 中（標題、主題 CSS、選擇指示器，以及所有互動基礎設施）。

**最小範例：**

```html
<h2>哪種版面更好？</h2>
<p class="subtitle">考慮可讀性和視覺層級</p>

<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>單欄</h3>
      <p>乾淨、專注的閱讀體驗</p>
    </div>
  </div>
  <div class="option" data-choice="b" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>雙欄</h3>
      <p>側邊欄導覽配主要內容</p>
    </div>
  </div>
</div>
```

就這樣。不需要 `<html>`、不需要 CSS、不需要 `<script>` 標籤。伺服器提供所有這些。

## 可用的 CSS 類別

Frame template 為你的內容提供這些 CSS 類別：

### 選項（A/B/C 選擇）

```html
<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>標題</h3>
      <p>描述</p>
    </div>
  </div>
</div>
```

**多選：** 在容器上加入 `data-multiselect`，讓使用者可以選擇多個選項。每次點擊切換該項目。指示器列顯示計數。

```html
<div class="options" data-multiselect>
  <!-- 相同的 option 標記——使用者可以選擇/取消選擇多個 -->
</div>
```

### 卡片（視覺設計）

```html
<div class="cards">
  <div class="card" data-choice="design1" onclick="toggleSelect(this)">
    <div class="card-image"><!-- mockup 內容 --></div>
    <div class="card-body">
      <h3>名稱</h3>
      <p>描述</p>
    </div>
  </div>
</div>
```

### Mockup 容器

```html
<div class="mockup">
  <div class="mockup-header">預覽：Dashboard 版面</div>
  <div class="mockup-body"><!-- 你的 mockup HTML --></div>
</div>
```

### 分割視圖（並排）

```html
<div class="split">
  <div class="mockup"><!-- 左側 --></div>
  <div class="mockup"><!-- 右側 --></div>
</div>
```

### 優缺點

```html
<div class="pros-cons">
  <div class="pros"><h4>優點</h4><ul><li>優勢</li></ul></div>
  <div class="cons"><h4>缺點</h4><ul><li>劣勢</li></ul></div>
</div>
```

### 模擬元素（線框圖構建塊）

```html
<div class="mock-nav">Logo | 首頁 | 關於 | 聯絡</div>
<div style="display: flex;">
  <div class="mock-sidebar">導覽</div>
  <div class="mock-content">主要內容區域</div>
</div>
<button class="mock-button">操作按鈕</button>
<input class="mock-input" placeholder="輸入欄位">
<div class="placeholder">佔位區域</div>
```

### 排版與區塊

- `h2` — 頁面標題
- `h3` — 區塊標題
- `.subtitle` — 標題下方的次要文字
- `.section` — 帶底部邊距的內容區塊
- `.label` — 小型大寫標籤文字

## 瀏覽器事件格式

當使用者在瀏覽器中點擊選項時，他們的互動會被記錄到 `$STATE_DIR/events`（每行一個 JSON 物件）。當你推送新畫面時，檔案會自動清除。

```jsonl
{"type":"click","choice":"a","text":"Option A - Simple Layout","timestamp":1706000101}
{"type":"click","choice":"c","text":"Option C - Complex Grid","timestamp":1706000108}
{"type":"click","choice":"b","text":"Option B - Hybrid","timestamp":1706000115}
```

完整的事件串流顯示使用者的探索路徑——他們可能在決定之前點擊多個選項。最後一個 `choice` 事件通常是最終選擇，但點擊模式可以揭示值得詢問的猶豫或偏好。

若 `$STATE_DIR/events` 不存在，使用者沒有與瀏覽器互動——只使用他們的終端機文字。

## 設計技巧

- **依問題調整精度** — 版面問題用線框圖，精細問題用精緻設計
- **在每頁說明問題** — 「哪種版面感覺更專業？」而不只是「選一個」
- **在推進之前迭代** — 若回饋改變了當前畫面，寫一個新版本
- **每個畫面最多 2-4 個選項**
- **在重要時使用真實內容** — 對於攝影作品集，使用實際圖片（Unsplash）。佔位內容會掩蓋設計問題。
- **保持 mockup 簡單** — 專注於版面和結構，而非像素完美的設計

## 檔案命名

- 使用語意化名稱：`platform.html`、`visual-style.html`、`layout.html`
- 永遠不要重用檔名——每個畫面必須是新檔案
- 迭代時：附加版本後綴，如 `layout-v2.html`、`layout-v3.html`
- 伺服器依修改時間提供最新的檔案

## 清理

```bash
scripts/stop-server.sh $SESSION_DIR
```

若 session 使用了 `--project-dir`，mockup 檔案會持久保存在 `.superpowers/brainstorm/` 中以供後續參考。只有 `/tmp` session 在停止時會被刪除。

## 參考

- Frame template（CSS 參考）：`scripts/frame-template.html`
- Helper 腳本（客戶端）：`scripts/helper.js`
