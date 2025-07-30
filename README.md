# ai-copilot-spells

記錄我使用 AI 輔助開發時的一些常用設定與魔法小語~

- gemini: gemini 啟動時會在當前目錄讀取 GEMINI.md, 以及家目錄的 .gemini 目錄下的 GEMINI.md
- github-copilot: .github 目錄結構即是擺放位置

---

## SPELLS

```
請瀏覽整個專案內容,
將重點整理寫進 .github/instructions/project-context.instructions.md 裡,
整理重點為輔助你之後在這個專案執行任務時, 可以快速找到相對應的功能與位置進行任務.
```

```
請根據此次修改內容,
將新增或修改的地方在 .github/instructions/project-context.instructions.md 內修正,
請保持原有的格式與風格,
且整理的重點仍為輔助你之後在這個專案執行任務時, 可以快速找到相對應的功能與位置進行任務.
```

```
在 xxx-package 裡寫一個 interface 提供以下功能:
- 根據邏輯描述, 注意各種邊界條件處理, 測試也必須涵蓋所有邊界條件
- 根據邏輯描述, 注意有可能的執行緒安全問題, 尤其是需要 double-check lock 的地方
- 根據邏輯描述,使用恰當的設計模式組織程式架構, 以便後續維護與修改
- 根據邏輯描述, 合理分配程式碼在恰當的檔案裡
- 將該功能收斂在一個 .go 裡, 檔名以簡約/代表邏輯含意為主
- 請先列出你的執行計畫給我確認, 勿直接執行任務
```
