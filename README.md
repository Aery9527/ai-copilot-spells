# ai-research

持續研究、整理各 AI 工具的使用方式與最佳實踐，並沉澱為可重複使用的 Skills。

## 快速導覽

- [AI 工具涵蓋範圍](#ai-工具涵蓋範圍)
- [Skills 系統](#skills-系統)
- [個人自製 Skills](#個人自製-skills)
- [Skills Link 設定](#skills-link-設定)
- [其他設定](#其他設定)
- [AutoHotkey 快捷鍵（Windows）](#autohotkey-快捷鍵windows)
- [目錄結構](#目錄結構)

---

## AI 工具涵蓋範圍

| 工具 | 目錄 | 說明 |
|------|------|------|
| **Claude Code** | [`claude-code/cc-cli.md`](claude-code/cc-cli.md) | CLI 參數、slash commands、快捷鍵 |
| **GitHub Copilot** | [`github-copilot/gc-cli.md`](github-copilot/gc-cli.md) | CLI 參數、slash commands、custom instructions |

[返回開頭](#快速導覽)

---

## Skills 系統

Skills 是讓 AI 在特定領域表現更佳的提示工程模組。本專案維護三層 skills：

| 目錄 | 來源 | 用途 |
|------|------|------|
| `anthropic-skills/` | Anthropic 上游 repo | 原始定義，勿直接修改 |
| `.claude/skills/` | Claude Code project skills | Anthropic router 套件與少數直接掛在 project 下的本地 skills |
| `.agents/skills/` | 個人自製 skills | 其餘工作踩坑與實戰決策邏輯沉澱 |

repo 層級的 skills 導覽見 [`AGENTS.md`](AGENTS.md)。Anthropic skill 的第一層入口與「問題 → Skill」決策樹位於 [`.claude/skills/anthropic-skill/SKILL.md`](.claude/skills/anthropic-skill/SKILL.md)，第二層分類與 skill 摘要則收在其內部目錄。

### `.claude/skills/` 內的 project skills

[`.claude/skills/`](.claude/skills/) 目前除了 Anthropic router，也放置會被直接當成 Claude Code project skill 使用的本地技能：

| Skill | 解決的問題 |
|-------|-----------|
| **anthropic-skill** | Anthropic 官方 skills 的第一層 router，先分類再按需展開第二層摘要 |
| **anthropic-skills-sync** | 將本地 Anthropic router 套件與上游 `anthropic-skills/` 同步 |
| **cli-doc-sync** | CLI 參考文件與官方文件同步：Python 抓取、差異比對、缺補多刪 |

### `.agents/skills/` 內的個人自製 Skills

[`.agents/skills/`](.agents/skills/) 內收的是工作上實際踩坑後沉澱出的本地 skills：

| Skill | 解決的問題 |
|-------|-----------|
| **mongo** | MongoDB 查詢、aggregation pipeline、Go driver、JS shell 型別陷阱 |
| **plan-extension** | 強制規範實作前先出 plan 文件，含驗收標準格式要求 |
| **windows-script** | `.bat`/`.cmd`/`.ps1` 語法陷阱、errorlevel、delayed expansion、PowerShell 錯誤處理 |
| **write-md** | Markdown 文件撰寫，含 Mermaid 圖表使用決策規則 |

[返回開頭](#快速導覽)

### Skills Link 設定

這個章節講的是**可選的路徑相容設定**，不是本 repo 的必要初始化步驟。它的用途是把 [`.claude/skills/`](.claude/skills/) 當成實際來源，透過 [`scripts/link-agent-skills.ps1`](scripts/link-agent-skills.ps1) 或 [`scripts/link-agent-skills.sh`](scripts/link-agent-skills.sh) 建立 symlink / junction，讓仍然依賴 `.agents/skills/` 路徑的舊習慣、外部工具或腳本，能看到同一份 skills 內容，而不是各自維護兩份副本。

換句話說，它解決的是「**路徑相容**」問題，不是「**skills 安裝**」問題。若你平常直接看 [`.claude/skills/`](.claude/skills/) 與 [`.agents/skills/`](.agents/skills/) 內現有內容，通常**不需要**額外跑這個設定。

你可以用下面這個方式快速判斷要不要碰這段設定：

| 情境 | 建議 |
|------|------|
| 你的 prompt、工具鏈、editor bookmark 或舊專案慣例仍寫死 `.agents/skills/` | 可考慮使用 Skills Link |
| 你想讓另一條路徑直接看到 [`.claude/skills/`](.claude/skills/) 的同一份內容，避免手動複製 | 可考慮使用 Skills Link |
| 你只是閱讀這個 repo 的文件與 skills 結構 | 不需要 |
| 你已經接受 [`.claude/skills/`](.claude/skills/) 是 Anthropic skills 的主要入口 | 不需要 |
| 你的 [`.agents/skills/`](.agents/skills/) 已有想保留的實體內容 | 先讀 [`scripts/README.md`](scripts/README.md) 再決定模式 |

如果真的要執行，腳本提供三種方向：

- **Mode 1**：把整個 [`.agents/skills/`](.agents/skills/) 連到 [`.claude/skills/`](.claude/skills/)
- **Mode 2**：只對 [`.claude/skills/`](.claude/skills/) 底下每個 skill 建個別 link
- **Mode 3**：移除前面建立的 link，回到未連結狀態

執行前還要注意三件事：

- 腳本會調整 [`.agents/skills/`](.agents/skills/) 與對應的 `.gitignore` 條目
- Windows 版使用 **junction**；Bash 版使用 **symlink**
- 如果 [`.agents/skills/`](.agents/skills/) 內已有內容要保留，先確認模式差異與清理行為，避免誤改現有結構

Skills link 腳本的詳細行為、執行方式與模式差異，請見 [`scripts/README.md`](scripts/README.md)。

[返回開頭](#快速導覽)

---

## 其他設定

[`tool/README.md`](tool/README.md) — Windows / WSL / PowerShell / Claude Desktop 等工具型操作文件索引。

### AutoHotkey 快捷鍵（Windows）

[`tool/claude_desktop_hot_key.md`](tool/claude_desktop_ahk.md) — 用 AutoHotkey v2 設定 `Alt + 空白鍵` 叫出 / 最小化 Claude Desktop。

[返回開頭](#快速導覽)

---

## 目錄結構

```
ai-research/
├── claude-code/          # Claude Code CLI 參考
├── github-copilot/       # GitHub Copilot CLI + custom instructions
│   └── .github/          # instructions 擺放位置（直接複製到目標專案）
├── anthropic-skills/     # Anthropic 上游 skills（勿直接修改）
├── .claude/skills/       # Claude Code project skills
│   ├── anthropic-skill/  # Anthropic router + internal Anthropic skill notes
│   ├── anthropic-skills-sync/
│   └── cli-doc-sync/     # CLI 文件同步工具（fetch_docs.py）
├── .agents/skills/       # 其餘個人自製 skills
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

[返回開頭](#快速導覽)
