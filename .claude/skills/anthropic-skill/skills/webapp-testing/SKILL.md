---
name: webapp-testing
description: Toolkit for interacting with and testing local web applications using Playwright. Supports verifying frontend functionality, debugging UI behavior, capturing browser screenshots, and viewing browser logs.
source: anthropic-skills/skills/webapp-testing/SKILL.md
---

## 概述

使用原生 Python Playwright 腳本測試本地 Web 應用，提供伺服器生命周期管理腳本和「偵察後行動」的測試模式。

## 決策樹

```
使用者任務
├─ 靜態 HTML？
│   ├─ 直接讀 HTML 找選擇器
│   └─ 寫 Playwright 腳本
│
└─ 動態 Web App？
    ├─ 伺服器未運行？
    │   └─ python scripts/with_server.py --help
    │       然後用 helper 啟動伺服器
    │
    └─ 伺服器已運行？
        └─ 偵察後行動：
           1. 導航 + 等待 networkidle
           2. 截圖或檢查 DOM
           3. 從渲染狀態找選擇器
           4. 用找到的選擇器執行操作
```

## 伺服器管理腳本

```bash
# 查看用法
python scripts/with_server.py --help

# 單一伺服器
python scripts/with_server.py --server "npm run dev" --port 5173 -- python automation.py

# 多伺服器（後端 + 前端）
python scripts/with_server.py \
  --server "cd backend && python server.py" --port 3000 \
  --server "cd frontend && npm run dev" --port 5173 \
  -- python automation.py
```

## Playwright 腳本模板

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)  # 永遠用 headless=True
    page = browser.new_page()
    page.goto('http://localhost:5173')
    page.wait_for_load_state('networkidle')  # 關鍵：等 JS 執行完
    
    # 偵察
    page.screenshot(path='/tmp/inspect.png', full_page=True)
    content = page.content()
    
    # 操作（用發現的選擇器）
    page.click('text=Login')
    page.fill('#email', 'user@example.com')
    
    browser.close()
```

## 解決什麼問題

前端功能驗證需要真實的瀏覽器環境——不能只看 HTML 源碼。此 skill 提供 Playwright 自動化測試，可以截圖、捕獲 console logs、驗證互動行為。

## 何時使用（觸發條件）

- 「測試 web app」/ 「UI 自動化」
- 「截圖」/ 「驗證功能」
- 「前端測試」/ 「Playwright」
- 需要驗證 React/Vue/其他動態應用的行為

## 範例腳本

| 腳本 | 功能 |
|------|------|
| `examples/element_discovery.py` | 發現頁面上的按鈕、鏈接、輸入框 |
| `examples/static_html_automation.py` | 用 `file://` URL 操作本地 HTML |
| `examples/console_logging.py` | 捕獲 console logs |

## 最佳實踐

- 使用描述性選擇器：`text=`、`role=`、CSS 選擇器、ID
- 適當等待：`page.wait_for_selector()` 或 `page.wait_for_timeout()`
- **不要**在動態應用上跳過 `networkidle` 等待
- 腳本內不需要管理伺服器（`with_server.py` 負責）

## 關鍵工具

- **with_server.py**：多伺服器生命周期管理（必讀 `--help`）
- **Playwright Python**：同步 API（`sync_playwright()`）
- **Chromium**：預設瀏覽器（`headless=True`）
