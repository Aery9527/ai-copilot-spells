# ai-copilot-spells

記錄我使用 AI 輔助開發時的常用設定、指令參考等。

---

## AI 工具涵蓋範圍

| 工具 | 目錄 | 說明 |
|------|------|------|
| **Claude Code** | [`claude-code/`](claude-code/) | CLI 參數、slash commands、快捷鍵 |
| **GitHub Copilot** | [`github-copilot/`](github-copilot/) | CLI 參數、slash commands、custom instructions |
| **Gemini** | [`gemini/`](gemini/) | CLI 參數、GEMINI.md 設定、語言別 instructions |

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

### Skills Symlink 設定

Claude Code 只載入 `.claude/skills/` 下的 skills。執行以下腳本可將 `.agents/skills/` 中的自製 skills 以 symlink 方式掛載進去：

```bash
# Linux / macOS / Git Bash
bash link-agent-skills.sh

# Windows PowerShell（需系統管理員或已開啟 Developer Mode）
./link-agent-skills.ps1
```

- 可從任意目錄執行，腳本自動定位 repo root
- 重複執行安全（已存在的 symlink 會 skip）

---

## 其他設定

### AutoHotkey 快捷鍵（Windows）

[`hot_key.md`](hot_key.md) — 用 AutoHotkey v2 設定 `Alt + 空白鍵` 叫出 / 最小化 Claude Desktop。

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
├── link-agent-skills.sh  # Skills symlink 腳本（bash）
└── link-agent-skills.ps1 # Skills symlink 腳本（PowerShell）
```
