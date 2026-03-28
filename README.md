# ai-research

持續研究、整理各 AI 工具的使用方式與最佳實踐，並沉澱為可重複使用的 Skills。

---

## AI 工具涵蓋範圍

| 工具 | 目錄 | 說明 |
|------|------|------|
| **Claude Code** | [`claude-code/cc-cli.md`](claude-code/cc-cli.md) | CLI 參數、slash commands、快捷鍵 |
| **GitHub Copilot** | [`github-copilot/gc-cli.md`](github-copilot/gc-cli.md) | CLI 參數、slash commands、custom instructions |

---

## Skills 系統

Skills 是讓 AI 在特定領域表現更佳的提示工程模組。本專案維護三層 skills：

| 目錄 | 來源 | 用途 |
|------|------|------|
| `anthropic-skills/` | Anthropic 上游 repo | 原始定義，勿直接修改 |
| `.claude/skills/` | 從上游同步的精華摘要 | 供 AI 快速判斷 skill 能力邊界與組合方案 |
| `.agents/skills/` | 個人自製 skills | 工作踩坑與實戰決策邏輯沉澱 |

完整 skills 導覽與選擇決策樹見 [`AGENTS.md`](AGENTS.md)。

### 個人自製 Skills（`.agents/skills/`）

| Skill | 解決的問題 |
|-------|-----------|
| **cli-doc-sync** | CLI 參考文件與官方文件同步：Python 抓取、差異比對、缺補多刪 |
| **mongo** | MongoDB 查詢、aggregation pipeline、Go driver、JS shell 型別陷阱 |
| **plan-extension** | 強制規範實作前先出 plan 文件，含驗收標準格式要求 |
| **windows-script** | `.bat`/`.cmd`/`.ps1` 語法陷阱、errorlevel、delayed expansion、PowerShell 錯誤處理 |
| **write-md** | Markdown 文件撰寫，含 Mermaid 圖表使用決策規則 |

### Skills Link 設定

Skills link 腳本的詳細說明、執行方式與模式差異，請見 [`scripts/README.md`](scripts/README.md)。

---

## 其他設定

[`tool/README.md`](tool/README.md) — Windows / WSL / PowerShell / Claude Desktop 等工具型操作文件索引。

### AutoHotkey 快捷鍵（Windows）

[`tool/claude_desktop_hot_key.md`](tool/claude_desktop_hot_key.md) — 用 AutoHotkey v2 設定 `Alt + 空白鍵` 叫出 / 最小化 Claude Desktop。

---

## 目錄結構

```
ai-research/
├── claude-code/          # Claude Code CLI 參考
├── github-copilot/       # GitHub Copilot CLI + custom instructions
│   └── .github/          # instructions 擺放位置（直接複製到目標專案）
├── anthropic-skills/     # Anthropic 上游 skills（勿直接修改）
├── .claude/skills/       # anthropic-skills 精華摘要（AI 使用）
├── .agents/skills/       # 個人自製 skills
│   ├── cli-doc-sync/     # CLI 文件同步工具（fetch_docs.py）
│   ├── mongo/
│   ├── plan-extension/
│   ├── windows-script/
│   └── write-md/
├── AGENTS.md             # Skills 導覽索引
├── tool/                 # 工具型操作文件與設定筆記
│   ├── README.md
│   ├── claude_desktop_hot_key.md
│   ├── ps_func.md
│   └── wsl-claude-code-env-setup.md
└── scripts/
    ├── README.md
    ├── link-agent-skills.sh
    └── link-agent-skills.ps1
```
