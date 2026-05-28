---
name: webapp-testing
description: Toolkit for interacting with and testing local web applications using Playwright. Supports verifying frontend functionality, debugging UI behavior, capturing browser screenshots, and viewing browser logs.
---

## 概述

使用原生 Python Playwright 腳本測試本地 Web 應用，提供伺服器生命周期管理腳本與偵察後行動的測試模式。

## 決策流程

- 如果是靜態 HTML：
  - 先直接讀 HTML 找選擇器。
  - 再決定是否需要 Playwright 腳本。
- 如果是動態 Web App：
  - 如果伺服器未運行，先看 [scripts/with_server.py](../../../../../skill-source/anthropic-skills/skills/webapp-testing/scripts/with_server.py)，再用 helper 啟動伺服器。
  - 如果伺服器已運行，先偵察，再操作：
    1. 導航並等待 `networkidle`
    2. 截圖或檢查 DOM
    3. 從渲染狀態找選擇器
    4. 用找到的選擇器執行操作

## 伺服器管理腳本

```bash
python skill-source/anthropic-skills/skills/webapp-testing/scripts/with_server.py --help
python skill-source/anthropic-skills/skills/webapp-testing/scripts/with_server.py --server "npm run dev" --port 5173 -- python automation.py
python skill-source/anthropic-skills/skills/webapp-testing/scripts/with_server.py \
  --server "cd backend && python server.py" --port 3000 \
  --server "cd frontend && npm run dev" --port 5173 \
  -- python automation.py
```

## Playwright 腳本模板

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto('http://localhost:5173')
    page.wait_for_load_state('networkidle')
    page.screenshot(path='/tmp/inspect.png', full_page=True)
    content = page.content()
    page.click('text=Login')
    page.fill('#email', 'user@example.com')
    browser.close()
```

## 範例腳本

- [skill-source/anthropic-skills/skills/webapp-testing/examples/element_discovery.py](../../../../../skill-source/anthropic-skills/skills/webapp-testing/examples/element_discovery.py) — 發現按鈕、連結與輸入框。
- [skill-source/anthropic-skills/skills/webapp-testing/examples/static_html_automation.py](../../../../../skill-source/anthropic-skills/skills/webapp-testing/examples/static_html_automation.py) — 用 `file://` URL 操作本地 HTML。
- [skill-source/anthropic-skills/skills/webapp-testing/examples/console_logging.py](../../../../../skill-source/anthropic-skills/skills/webapp-testing/examples/console_logging.py) — 捕獲 console logs。

## 最佳實踐

- 使用描述性選擇器，例如 `text=`、`role=`、CSS 選擇器與 ID。
- 適當等待，例如 `page.wait_for_selector()`。
- 對動態應用嚴禁跳過 `networkidle` 等待。
- 伺服器生命周期交給 [scripts/with_server.py](../../../../../skill-source/anthropic-skills/skills/webapp-testing/scripts/with_server.py)，腳本本身不要重複管理。
