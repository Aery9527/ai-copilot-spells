---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code
source: superpowers/skills/test-driven-development/SKILL.md
---

## 概述

強制先寫失敗的測試、觀察其失敗、再寫最小實作程式碼的開發紀律 skill。核心原則：如果沒有看到測試失敗，就不知道測試是否真的在測對的東西。

## 能做什麼

- 紅-綠-重構（Red-Green-Refactor）循環執行
- 驗證測試確實在預期原因下失敗（不是 import error 等無關錯誤）
- 寫最小化實作程式碼直到測試通過
- 確保所有既有測試繼續通過

## 解決什麼問題

「我寫了測試，但測試從來沒有失敗過」這種假安全感；在沒有測試保護下產品程式碼漏出；測試形同虛設。

## 何時使用（觸發條件）

- 任何新功能實作前
- 任何 bug fix 前
- 任何行為修改前
- 在寫任何一行實作程式碼前

## 關鍵技術棧

各語言測試框架（pytest、Jest、go test、cargo test、RSpec 等）。

## 重要注意事項

- **Iron Law**：`NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST`。
- 先寫了實作程式碼才想到要補測試？刪掉，從測試開始重寫。不能「保留作參考」。
- 「這個功能太簡單不需要測試」是理由化。
- 不得跳過「觀察測試失敗」這個步驟。
- 例外（需詢問）：一次性原型、生成程式碼、設定檔。
