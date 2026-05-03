# ai-research

> AI 工具研究 × Skills 知識庫：彙整 Claude Code、GitHub Copilot、Codex 等 AI 工具的使用方式，並沉澱為可重複使用的 Skills。

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

首次初始化 submodule：

```powershell
git submodule update --init --recursive
```

同步上游更新：

[GitHub Dependabot](.github/dependabot.yml) 每日自動偵測上游 submodule 變更並開 PR。收到通知 email 後，`sync-all` 一個 skill 即完成全部同步：

> Dependabot 開 PR → email 通知 → invoke `sync-all` → pull + AI 摘要 + commit + push + 關閉 PR

---

## 快速導覽

- [Skills 系統](#skills-系統)
  - [.claude-plugin 檔案說明](#claude-plugin-檔案說明)
  - [anthropic-skills](#anthropic-skills)
  - [superpowers](#superpowers)
- [AI 工具文件](#ai-工具文件)
- [Agent 與 Skill 差異](#agent-與-skill-差異)
- [腳本文件](#腳本文件)
- [個人自製 Skills](#個人自製-skills)
- [目錄結構](#目錄結構)

---


## Skills 系統

本 repo 維護四個層次的 skills：

| 目錄 | 來源 | 用途 |
|------|------|------|
| `anthropic-skills/` | [Anthropic 上游](https://github.com/anthropics/skills) | 創意設計、前端工程、AI 工程、Office 文件、技術寫作 |
| `superpowers/` | [superpowers 上游](https://github.com/obra/superpowers) | 開發流程、Code Review、並行協作、Git 工作流、維運 |
| `.agents/skills/` | 本地 project-specific custom skills | 專案內部治理、客製 workflow 與只在本 repo 使用的 skills，例如 [`skills-governance`](.agents/skills/skills-governance/SKILL.md) |
| `aery-marketplace/` | 本地自製 plugin | `aery-skills`：工作踩坑實戰邏輯，可安裝的 self-contained plugin / marketplace root（[README](aery-marketplace/README.md)） |

### Skill Routers（第一層入口）

| Router | 涵蓋範疇 |
|--------|---------|
| [`.claude/skills/anthropic-skill/`](.claude/skills/anthropic-skill/SKILL.md) | 創意設計・前端工程・AI 工程・Office 文件・技術寫作 |
| [`.claude/skills/superpowers-skill/`](.claude/skills/superpowers-skill/SKILL.md) | 開發流程・Code Review・並行協作・Git 工作流・維運 |

### 共用基礎設施

[`.claude/skills/_shared/upstream-sync-protocol.md`](.claude/skills/_shared/upstream-sync-protocol.md) — 各 upstream sync skill 共用的通用 sync 流程協議。新增第三、四個 submodule 時，sync skill 只需引用這份文件 + 填入庫設定。

### .claude-plugin 檔案說明

Claude Code plugin 系統在 `.claude-plugin/` 目錄下有兩種設定檔，職責不同：

| 檔案 | 層次 | 定義的是什麼 |
|------|------|------------|
| `marketplace.json` | Marketplace 層 | 一個目錄清單：列出要發行哪些 plugins、各自來源與設定 |
| `plugin.json` | Plugin 層 | 單個 plugin 的身份：`name`, `version`, `author`, `keywords`… |

**為什麼 `superpowers/` 同時有兩個？**

`superpowers` 身兼兩種角色：它本身是一個可安裝的 plugin（需要 `plugin.json` 聲明身份），同時也透過 `marketplace.json`（名為 `superpowers-dev`）作為 marketplace 發行自己。

**為什麼 `anthropic-skills/` 只有 `marketplace.json`？**

`anthropic-skills` 純粹是一個 **marketplace**，打包了 `document-skills`、`example-skills`、`claude-api` 等多個 plugin。它的 `marketplace.json` 對每個 plugin 都設了 `"strict": false`，意思是由 marketplace 完全控制 plugin 配置，各 plugin 不需要自己的 `plugin.json`。

> `strict: false` = marketplace entry 是完整定義，plugin 內不需要自備 `plugin.json`。  
> 預設 `strict: true` = plugin 自己的 `plugin.json` 才是權威來源。

---

### anthropic-skills

**安裝方法：**

```
/plugin marketplace add anthropics/skills
/plugin install example-skills@anthropic-agent-skills
/plugin install document-skills@anthropic-agent-skills
```

以 plugin 為單位組織，目前共三個 plugin，可依需求選擇性安裝：

| Plugin | 包含 Skills | 適用場景 |
|--------|------------|---------|
| **document-skills** | `xlsx`, `docx`, `pptx`, `pdf` | 各類 Office 文件與 PDF |
| **example-skills** | `algorithmic-art`, `brand-guidelines`, `canvas-design`, `doc-coauthoring`, `frontend-design`, `internal-comms`, `mcp-builder`, `skill-creator`, `slack-gif-creator`, `theme-factory`, `web-artifacts-builder`, `webapp-testing` | 創意設計、前端工程、AI 工程、文字寫作 |
| **claude-api** | `claude-api` | Claude API / Anthropic SDK 應用 |

詳細設定見 [`anthropic-skills/.claude-plugin/marketplace.json`](anthropic-skills/.claude-plugin/marketplace.json)。

> **已知 bug**：若同一批 skills 同時由 project top-level entries 與 plugin namespace 暴露，context 與 slash command picker 仍可能重複。當前結構設計就是為了避免這個情況。相關 issue：[anthropics/claude-code#29520](https://github.com/anthropics/claude-code/issues/29520)、[anthropics/skills#189](https://github.com/anthropics/skills/issues/189)

### superpowers

**安裝方法：**

```
# 官方 marketplace（推薦）
/plugin install superpowers@claude-plugins-official

# 或透過 obra's marketplace
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

為單一 plugin，涵蓋開發流程全套 skills：

| Plugin | 包含 Skills | 適用場景 |
|--------|------------|---------|
| **superpowers** | `brainstorming`, `writing-plans`, `subagent-driven-development`, `executing-plans`, `test-driven-development`, `systematic-debugging`, `requesting-code-review`, `receiving-code-review`, `finishing-a-development-branch`, `using-git-worktrees`, `dispatching-parallel-agents`, `verification-before-completion`, `writing-skills`, `using-superpowers` | 開發流程、Code Review、並行協作、Git 工作流、維運 |

`using-superpowers` 是元技能（meta-skill），不參與任何具體工作流程，但它是所有流程的前提條件：收到任何任務前，哪怕只有 1% 機率有 skill 可用，就必須先呼叫 Skill tool 確認，再執行任何動作。

典型開發流程：

```mermaid
flowchart TD
    subgraph feature ["新功能開發"]
        direction LR
        wgw["using-git-worktrees"] --> bs["brainstorming"]
        bs --> wp["writing-plans"]
        wp --> sad["subagent-driven-development"]
        wp --> ep["executing-plans"]
        sad --> fdb["finishing-a-development-branch"]
        ep --> fdb
    end

    subgraph per_task ["每個 task 內（subagent 執行）"]
        direction LR
        tdd["test-driven-development"] --> rcr["requesting-code-review"]
    end
    sad -.->|"逐 task"| per_task

    dpa["dispatching-parallel-agents"] -.->|"獨立子任務"| sad

    subgraph fix ["Bug Fix / Review 收到"]
        direction LR
        sd["systematic-debugging"]
        rcvr["receiving-code-review"]
    end
    sd --> vbc["verification-before-completion"]
    rcvr --> vbc

    ws["writing-skills"]
```

[返回開頭](#快速導覽)

---

## AI 工具文件

| 工具 | CLI 參考 | Agent 使用指南 | 說明 |
|------|---------|----------------|------|
| **Claude Code** | [`cli-agents/claude-code/cc-cli.md`](cli-agents/claude-code/cc-cli.md) | [`docs/claude-code-agents.md`](docs/claude-code-agents.md) | CLI 參數、slash commands、快捷鍵，以及 built-in / custom agent 用法 |
| **GitHub Copilot** | [`cli-agents/github-copilot/gc-cli.md`](cli-agents/github-copilot/gc-cli.md) | [`docs/github-copilot-agents.md`](docs/github-copilot-agents.md) | CLI 參數、slash commands、custom instructions，以及 built-in / custom agent 用法 |
| **Codex CLI** | [`cli-agents/codex/cx-cli.md`](cli-agents/codex/cx-cli.md) | [`docs/codex-agents.md`](docs/codex-agents.md) | 安裝、登入、approval / sandbox、`codex exec`、subagents、`AGENTS.md`、slash commands、config，以及 TUI 快捷操作 |

其他工具操作文件索引：[`tool/README.md`](tool/README.md)

[返回開頭](#快速導覽)

---

## Agent 與 Skill 差異

這一節整理目前 repo 內對 **Claude Code** 與 **GitHub Copilot CLI** 的 agent / skill 研究結論。若要查各工具的完整建立方式與實際用法，請先看 [Claude Code Agent 使用指南](docs/claude-code-agents.md)、[GitHub Copilot CLI Agent 使用指南](docs/github-copilot-agents.md) 與 [Codex Agent 使用指南](docs/codex-agents.md)。

### 核心區分

**一句話：`agent` 是「誰來做」；`skill` 是「怎麼做」。**

| 面向 | Agent | Skill |
|------|-------|-------|
| 本質 | 專家角色 / 執行者 | SOP / 任務知識包 |
| 系統實際做的事 | 啟動一個專門 agent 或 subagent 去做 | 把 [`SKILL.md`](aery-marketplace/aery-dev/write-md/SKILL.md) 與附帶資源注入目前 agent 的 context |
| Context | 常有獨立 context，適合隔離探索、測試、review | 多半沿用目前對話 context，屬 just-in-time 指南 |
| 主要關注 | 角色、工具權限、模型、隔離、背景執行、可否委派 | 步驟、模板、範例、腳本、輸出格式 |
| 適合場景 | `security-auditor`、`code-reviewer`、`test-runner` | `write-md`、`mongo-guidelines`、release note / deploy SOP |

### 兩者如何搭配

| 層次 | 用途 |
|------|------|
| custom instructions | 所有任務都應遵守的 repo 慣例與溝通方式 |
| skill | 某一類任務才需要的知識、步驟與模板 |
| agent | 負責執行任務的角色與 runtime 邊界 |
| tool / MCP | 實際能力來源，例如讀檔、改檔、查 GitHub、操作外部服務 |

實務上比較穩的設計通常是：**把知識與流程放 skill，把角色、權限與執行邊界放 agent**。  
例如 [`.agents/skills/`](.agents/skills/skills-governance/SKILL.md) 與 [`aery-marketplace/aery-dev/`](aery-marketplace/README.md) 目前收的都是 skills，不是 agents。

### Claude Code 與 GitHub Copilot 的差異

| 項目 | Claude Code | GitHub Copilot CLI |
|------|-------------|--------------------|
| Agent 定位 | 比較像可編排的 subagent runtime | 比較像 specialist persona + tool profile |
| Skill 定位 | skills 除知識外，還能設定 `allowed-tools`、`context: fork`、`hooks` 等行為 | skills 是 task-specific instructions，可附 scripts / resources，偏 just-in-time workflow |
| Agent 與 Skill 搭配 | custom agent 可透過 `skills` 欄位預載 skills 內容 | custom agent 與 skills 都能共存，但 custom agent 主要負責角色與工具邊界 |
| Agent 裡能否再叫 Agent | 被派出去的 subagent 不能再 spawn subagent；若整個 session 以 `claude --agent` 啟動，主執行緒仍可再派 | custom agent `tools` 支援 `agent` alias，可再叫其他 custom agent，但不建議做太深巢狀 |

### Marketplace / Plugin 能不能放 Agent

可以，但精準說法是：**marketplace 是分發 plugin 的地方；真正承載 agent 的是 plugin。**

| 平台 | marketplace / plugin 能否包含 agent | 典型位置 | 補充 |
|------|-----------------------------------|----------|------|
| Claude Code | 可以 | plugin root 的 `agents/` | plugin 可包含 `skills`、`agents`、`hooks`、`MCP`、`LSP` |
| GitHub Copilot CLI | 可以 | plugin root 的 `agents/`，檔名 `*.agent.md` | plugin 可包含 `agents`、`skills`、`hooks`、`MCP` 等元件 |

不過 **agent 不像 skill 那樣容易跨 cc / gc 共用同一份定義**。兩邊都能透過 plugin / marketplace 發佈 agent，但 frontmatter、檔名格式、可用欄位與 tool naming 都不同：

1. **Claude Code plugin agents** 支援 `skills`、`memory`、`background`、`isolation` 等欄位，但 plugin-shipped agents 不支援 `hooks`、`mcpServers`、`permissionMode`。
2. **GitHub Copilot CLI plugin agents** 使用 `.agent.md` 格式，欄位與 tool aliases 也和 Claude Code 不同。
3. 如果要讓同一個 marketplace root 同時服務 cc 與 gc，**可以共用同一個 plugin root 概念，但 agent 通常仍要各自包 wrapper**；skill 才比較適合共用同一套內容。

### 這個 repo 目前怎麼看

1. [`.claude/skills/`](.claude/skills/anthropic-skill/SKILL.md)、[`.agents/skills/`](.agents/skills/skills-governance/SKILL.md)、[`aery-marketplace/aery-dev/`](aery-marketplace/README.md) 主要都屬於 **skill 生態**。
2. [Claude Code Agent 使用指南](docs/claude-code-agents.md) 與 [GitHub Copilot CLI Agent 使用指南](docs/github-copilot-agents.md) 則是整理 **agent 建立、使用與能力邊界**。
3. [`aery-marketplace/`](aery-marketplace/README.md) 目前是 **skills plugin / marketplace root**；若未來要加入 agents，cc 與 gc 都做得到，但不應假設一份 agent 定義可直接跨兩邊共用。
4. 如果你在設計新能力時猶豫該做 agent 還是 skill，先問自己一句：**我要的是專家，還是手冊？** 要專家就做 agent；要手冊就做 skill。

[返回開頭](#快速導覽)

---

## 腳本文件

Repo 維護與自動化腳本的總索引在 [`scripts/README.md`](scripts/README.md)。

目前已收錄：

- [`scripts/remove-local-git-user.ps1`](scripts/remove-local-git-user.ps1)：遞迴掃描指定路徑下的 Git repository / worktree，移除 local Git config 的 `[user]` section

之後若 `scripts/` 目錄新增腳本，也應同步補充到 [`scripts/README.md`](scripts/README.md)。

[返回開頭](#快速導覽)

---

## 個人自製 Skills

本 repo 的自製 skills 分成兩條線維護：

| 位置 | 定位 |
|------|------|
| [`.agents/skills/`](.agents/skills/skills-governance/SKILL.md) | 專案內部 custom skills；只放治理規則、維護政策與 repo 專用 workflow。首個 skill 為 [`skills-governance`](.agents/skills/skills-governance/SKILL.md)。 |
| [`aery-marketplace/aery-dev/`](aery-marketplace/README.md) | 可安裝、可共享的 reusable skills，打包為 **`aery-skills`** plugin，供 GitHub Copilot 與 Claude Code 共用。 |

[`aery-marketplace/`](./aery-marketplace/README.md) 是一個可安裝的本地 self-contained plugin / marketplace root，詳細安裝說明見 [`aery-marketplace/README.md`](aery-marketplace/README.md)。

**GitHub Copilot 安裝：**

```bash
# 本地路徑
copilot plugin install ./aery-marketplace

# 從 GitHub repo subdirectory
copilot plugin install OWNER/REPO:aery-marketplace
# 例（本 repo）
copilot plugin install Aery9527/ai-research:aery-marketplace
```

**Claude Code 安裝：**

```
/plugin marketplace add ./aery-marketplace
/plugin install aery-skills@aery-plugins
```

> **注意**：`./aery-marketplace` 採本地路徑安裝，clone 此 repo 後即可直接使用。Claude Code 目前不支援 `owner/repo:subdir` 格式的遠端 marketplace add，無法直接從遠端子目錄安裝 marketplace。

包含 Skills：

| Skill | 解決的問題 |
|-------|-----------|
| **mongo-guidelines** | MongoDB 查詢、aggregation pipeline、Go driver、JS shell 型別陷阱 |
| **windows-script** | `.bat`/`.cmd`/`.ps1` 語法陷阱、errorlevel、delayed expansion |
| **write-md** | Markdown 文件撰寫，含 frontmatter 規則、YAML 安全與 Mermaid 圖表決策 |

[返回開頭](#快速導覽)

---

## 目錄結構

```
ai-research/
├── anthropic-skills/         # Anthropic 上游 skills submodule
├── superpowers/              # superpowers 上游 skills submodule
├── cli-agents/               # 各 CLI agent 的參考文件與使用者級別設定範本
│   ├── claude-code/          # Claude Code CLI 參考
│   │   └── .claude/          # 使用者級別設定範本（複製到 ~/.claude/ 生效）
│   ├── github-copilot/       # GitHub Copilot CLI + custom instructions
│   │   └── .copilot/         # 使用者級別設定範本（複製到 ~/.copilot/ 生效）
│   └── codex/                # Codex CLI 參考
│       └── cx-cli.md
├── other/                    # 其他語言 / 框架指引
│   └── java-guidelines.md
├── scripts/                  # 維護與自動化腳本文件
│   ├── README.md
│   └── remove-local-git-user.ps1
├── .agents/skills/           # repo 專用 custom skills（skills-governance, ...）
├── .claude/skills/           # Claude Code project skills
│   ├── _shared/              # 共用協議（upstream-sync-protocol）
│   ├── anthropic-skill/      # Anthropic router（categories + skills）
│   ├── anthropic-skills-sync/ # Anthropic sync 維運 skill
│   ├── superpowers-skill/    # Superpowers router（categories + skills）
│   ├── superpowers-skills-sync/ # Superpowers sync 維運 skill
│   ├── cli-doc-sync/         # CLI 文件同步工具
│   └── sync-all/             # 統一 orchestrator：Dependabot PR → invoke 各 sync skill
├── .github/
│   └── dependabot.yml        # 每日自動偵測所有 submodule 上游變更
├── aery-marketplace/         # aery-skills plugin / local marketplace root
│   ├── plugin.json           # GitHub Copilot plugin manifest
│   ├── .claude-plugin/       # Claude Code plugin / marketplace metadata
│   ├── aery-dev/             # skill 定義目錄（mongo-guidelines, windows-script, write-md）
│   └── README.md             # 安裝與維護說明
├── AGENTS.md                 # Skill 組合查表（任務導向）
├── CLAUDE.md                 # Claude Code project instructions
├── tool/                     # 工具操作文件
│   ├── README.md
│   ├── claude_desktop_ahk.md
│   ├── ps_func.md
│   └── wsl-claude-code-env-setup.md
└── docs/
    ├── claude-code-agents.md
    ├── codex-agents.md
    ├── github-copilot-agents.md
    └── superpowers/
        ├── specs/            # 設計文件
        └── plans/            # 實作計畫
```

[返回開頭](#快速導覽)

