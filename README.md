# ai-copilot-spells

記錄我使用 AI 輔助開發時的常用設定、指令參考等。

---

## AI 工具涵蓋範圍

| 工具 | 目錄 | 說明 |
|------|------|------|
| **Claude Code** | [`claude-code/cli.md`](claude-code/cli.md) | CLI 參數、slash commands、快捷鍵 |
| **GitHub Copilot** | [`github-copilot/cli.md`](github-copilot/cli.md) | CLI 參數、slash commands、custom instructions |
| **Gemini** | [`gemini/cli.md`](gemini/cli.md) | CLI 參數、GEMINI.md 設定、語言別 instructions |

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
| **mongo** | MongoDB 查詢、aggregation pipeline、Go driver、JS shell 型別陷阱 |
| **windows-script** | `.bat`/`.cmd`/`.ps1` 語法陷阱、errorlevel、delayed expansion、PowerShell 錯誤處理 |
| **write-md** | Markdown 文件撰寫，含 Mermaid 圖表使用決策規則 |

### Skills Link 設定

Skills link 腳本的詳細說明、執行方式與模式差異，請見 [`scripts/README.md`](scripts/README.md)。

---

## 其他設定

### AutoHotkey 快捷鍵（Windows）

[`hot_key.md`](tool/claude_desktop_hot_key.md) — 用 AutoHotkey v2 設定 `Alt + 空白鍵` 叫出 / 最小化 Claude Desktop。

---

## 目錄結構

```
ai-copilot-spells/
├── claude-code/          # Claude Code CLI 參考
├── github-copilot/       # GitHub Copilot CLI + custom instructions
│   └── .github/          # instructions 擺放位置（直接複製到目標專案）
├── gemini/               # Gemini CLI + GEMINI.md 設定
├── anthropic-skills/     # Anthropic 上游 skills（勿直接修改）
├── .claude/skills/       # anthropic-skills 精華摘要（AI 使用）
├── .agents/skills/       # 個人自製 skills
├── AGENTS.md             # Skills 導覽索引
├── hot_key.md            # AutoHotkey 快捷鍵設定
└── scripts/
    ├── link-agent-skills.sh   # Skills link 腳本（bash）
    └── link-agent-skills.ps1  # Skills link 腳本（PowerShell）
```
