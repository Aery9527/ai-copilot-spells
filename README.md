# ai-research

> AI 工具研究 × Skills 知識庫：彙整 Claude Code、GitHub Copilot 等 AI 工具的使用方式，並沉澱為可重複使用的 Skills。

```mermaid
flowchart LR
    U(["👤 使用者"])

    subgraph nav ["導覽層"]
        A["📋 AGENTS.md\n任務 → Skill 組合"]
        B["📖 README.md\n快速定位"]
    end

    subgraph routers ["Skill Router 層 (.claude/skills/)"]
        direction TB
        R1["🎨 創意・前端・文件・AI 工程\n(anthropic-skill)"]
        R2["⚡ 開發流程・Review・並行・維運\n(superpowers-skill)"]
        R3["… 未來更多 …"]
    end

    subgraph upstream ["上游來源層 (N 個 submodule)"]
        S["📦 anthropic-skills\n📦 superpowers\n📦 …"]
        P["🔄 _shared/upstream-sync-protocol"]
    end

    U --> nav --> routers
    S -->|"sync"| routers
    P -.->|"協議"| S
```

**你現在想做什麼？** → 看 [AGENTS.md](AGENTS.md) 找 skill 組合，一秒定位。

---

## 快速導覽

- [Skills 系統](#skills-系統)
- [AI 工具文件](#ai-工具文件)
- [個人自製 Skills](#個人自製-skills)
- [目錄結構](#目錄結構)

---

## Skills 系統

本 repo 維護三個層次的 skills：

| 目錄 | 來源 | 用途 |
|------|------|------|
| `anthropic-skills/` | [Anthropic 上游](https://github.com/anthropics/skills) | 創意設計、前端工程、AI 工程、Office 文件、技術寫作 |
| `superpowers/` | [superpowers 上游](https://github.com/obra/superpowers) | 開發流程、Code Review、並行協作、Git 工作流、維運 |
| `.agents/skills/` | 個人自製 | 工作踩坑與實戰決策邏輯 |

### Skill Routers（第一層入口）

| Router | 涵蓋範疇 |
|--------|---------|
| [`.claude/skills/anthropic-skill/`](.claude/skills/anthropic-skill/SKILL.md) | 創意設計・前端工程・AI 工程・Office 文件・技術寫作 |
| [`.claude/skills/superpowers-skill/`](.claude/skills/superpowers-skill/SKILL.md) | 開發流程・Code Review・並行協作・Git 工作流・維運 |

### 共用基礎設施

[`.claude/skills/_shared/upstream-sync-protocol.md`](.claude/skills/_shared/upstream-sync-protocol.md) — 各 upstream sync skill 共用的通用 sync 流程協議。新增第三、四個 submodule 時，sync skill 只需引用這份文件 + 填入庫設定。

### Plugin 安裝

```bash
# Anthropic skills（需先加 marketplace）
/plugin marketplace add anthropics/skills
/plugin install example-skills@anthropic-agent-skills
/plugin install document-skills@anthropic-agent-skills

# superpowers skills — 官方 marketplace（推薦）
/plugin install superpowers@claude-plugins-official

# superpowers skills — 或透過 obra's marketplace
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

詳細安裝說明見 [AGENTS.md](AGENTS.md#plugin-安裝)。

---

## AI 工具文件

| 工具 | 文件 | 說明 |
|------|------|------|
| **Claude Code** | [`claude-code/cc-cli.md`](claude-code/cc-cli.md) | CLI 參數、slash commands、快捷鍵 |
| **GitHub Copilot** | [`github-copilot/gc-cli.md`](github-copilot/gc-cli.md) | CLI 參數、slash commands、custom instructions |

其他工具操作文件索引：[`tool/README.md`](tool/README.md)

---

## 個人自製 Skills

[`.agents/skills/`](.agents/skills/) 內收的是工作實際踩坑後沉澱的本地 skills：

| Skill | 解決的問題 |
|-------|-----------|
| **mongo** | MongoDB 查詢、aggregation pipeline、Go driver、JS shell 型別陷阱 |
| **plan-extension** | 強制規範實作前先出 plan 文件，含驗收標準格式要求 |
| **windows-script** | `.bat`/`.cmd`/`.ps1` 語法陷阱、errorlevel、delayed expansion |
| **write-md** | Markdown 文件撰寫，含 Mermaid 圖表使用決策規則 |

---

## 目錄結構

```
ai-research/
├── anthropic-skills/         # Anthropic 上游 skills submodule
├── superpowers/              # superpowers 上游 skills submodule
├── claude-code/              # Claude Code CLI 參考
│   └── .claude/CLAUDE.md     # 子目錄級別 project instructions（進入此目錄時自動載入）
├── github-copilot/           # GitHub Copilot CLI + custom instructions
│   └── .copilot/             # copilot-instructions.md 擺放位置
├── other/                    # 其他語言 / 框架指引
│   └── java-guidelines.md
├── .claude/skills/           # Claude Code project skills
│   ├── _shared/              # 共用協議（upstream-sync-protocol）
│   ├── anthropic-skill/      # Anthropic router（categories + skills）
│   ├── anthropic-skills-sync/ # Anthropic sync 維運 skill
│   ├── superpowers-skill/    # Superpowers router（categories + skills）
│   ├── superpowers-skills-sync/ # Superpowers sync 維運 skill
│   └── cli-doc-sync/         # CLI 文件同步工具
├── .agents/skills/           # 個人自製 skills
│   ├── mongo/
│   ├── plan-extension/
│   ├── windows-script/
│   └── write-md/
├── AGENTS.md                 # Skill 組合查表（任務導向）
├── CLAUDE.md                 # Claude Code project instructions
├── tool/                     # 工具操作文件
│   ├── README.md
│   ├── claude_desktop_ahk.md
│   ├── ps_func.md
│   └── wsl-claude-code-env-setup.md
└── docs/
    └── superpowers/
        ├── specs/            # 設計文件
        └── plans/            # 實作計畫
```
