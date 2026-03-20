# scripts

收納專案內的輔助腳本。當前主要用途是管理 `.agents/skills/` 與 `.claude/skills/` 之間的連結方式。

---

## Agent Skills Link 腳本

這兩支腳本會以 `.claude/skills/` 作為真實來源，將 `.agents/skills/` 建成對應的 symlink／junction；適合在保留 `.agents/skills/` 路徑習慣的同時，讓實際內容對齊 `.claude/skills/`。

| 腳本 | 平台 | 說明 |
|------|------|------|
| [`link-agent-skills.sh`](link-agent-skills.sh) | Linux / macOS / Git Bash | 使用 symlink 管理 `.agents/skills/` |
| [`link-agent-skills.ps1`](link-agent-skills.ps1) | Windows PowerShell | 使用 junction 管理 `.agents/skills/` |

兩支腳本都支援：

- 互動式選單
- 自動定位 repo root，可從任意目錄執行
- 同步維護 `.gitignore` 條目
- 清理已失效的 skill 連結

---

## 執行方式

### Bash

```bash
bash ./scripts/link-agent-skills.sh
```

### PowerShell

```powershell
.\scripts\link-agent-skills.ps1
```

---

## 連結模式

腳本執行時會以繁體中文互動選單詢問連結模式：

| 選項 | 說明 |
|------|------|
| **0** | 取消 |
| **1** | 將整個 `.agents/skills` 連結至 `.claude/skills`（bash 建立單一 symlink；PowerShell 建立單一 junction） |
| **2** | 逐一將 `.claude/skills` 底下每個 skill 連結至 `.agents/skills`（可重複執行：`.claude/skills` 新增的 skill 會補建連結；來源已移除時會同步清掉失效連結與 `.gitignore` 條目） |
| **3** | 取消連結（移除 `.agents/skills` 本體連結，或逐一移除指向 `.claude/skills` 的 skill 連結，並同步清理 `.gitignore`） |

---

## 模式選擇建議

- 想要 `.agents/skills/` 完全鏡像 `.claude/skills/`：選 **Mode 1**
- 想保留 `.agents/skills/` 目錄本體，只對每個 skill 建立個別連結：選 **Mode 2**
- 想回復未連結狀態並清掉腳本建立的 `.gitignore` 條目：選 **Mode 3**

---

## `.gitignore` 行為

- **Mode 1 / Mode 2**：自動將建立的 `.agents/skills` 路徑加入 `.gitignore`
- **Mode 3**：移除對應 `.gitignore` 條目
- 已存在的條目不會重複寫入

---

## 注意事項

- Bash 版本建立的是 **symlink**；PowerShell 版本建立的是 **junction**
- 若 `.agents/skills` 已存在，腳本會依模式決定重建、略過或清理
- Mode 2 遇到「已存在但不是連結」的目標時，會保留原物件並略過該 skill
- 若只是想快速了解整個專案的 skills 架構與用途，先看 root [`README.md`](../README.md) 與 [`AGENTS.md`](../AGENTS.md)

