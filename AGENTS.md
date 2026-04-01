# AGENTS.md — Skill 組合查表

本文件的用途：**你有任務要做時，快速找到需要哪些 skill 組合**。Skill 名稱點進去才展開細節，這裡只保留第一層。

## 快速導覽

- [任務 → Skill 組合](#任務--skill-組合)
- [第一層 Router 入口](#第一層-router-入口)
- [Skill Locations](#skill-locations)

---

## 任務 → Skill 組合

### 🔄 開發流程

| 我想要... | 使用 Skills（依序） |
|----------|-------------------|
| 開發新功能（完整流程） | `brainstorming` → `writing-plans` → `test-driven-development` → `subagent-driven-development` → `requesting-code-review` |
| Debug 一個 bug | `systematic-debugging` |
| 宣告完成 / 準備 commit / PR 前 | `verification-before-completion` |
| 在新 session 執行計畫 | `executing-plans` |
| 在當前 session 執行計畫（subagent 逐 task） | `subagent-driven-development` |
| 多個獨立子任務並行 | `dispatching-parallel-agents` |
| 開始工作前需要隔離 workspace | `using-git-worktrees` |

### 👀 Review 與收尾

| 我想要... | 使用 Skills |
|----------|------------|
| 收到 code review 意見，技術評估後再實作 | `receiving-code-review` |
| 完成功能需要 review | `requesting-code-review` |
| 所有 task 完成，選擇收尾方式 | `finishing-a-development-branch` |

### 🎨 創意・前端・文件

| 我想要... | 使用 Skills |
|----------|------------|
| 建 Web UI / landing page | `brainstorming` → `frontend-design` |
| 建複雜 Claude artifact（React + shadcn） | `web-artifacts-builder` |
| 測試本地 Web 應用（Playwright） | `webapp-testing` |
| 生成海報 / 靜態視覺（PNG/PDF） | `canvas-design` |
| 生成算法藝術（流場、粒子、幾何） | `algorithmic-art` |
| 為 artifact 套主題 | `theme-factory` |
| 套用 Anthropic 品牌色彩 | `brand-guidelines` |
| 做 Slack 動態 GIF | `slack-gif-creator` |

### ⚙️ AI 工程・文件操作・寫作

| 我想要... | 使用 Skills |
|----------|------------|
| 建 Claude API 應用 / Anthropic SDK | `brainstorming` → `claude-api` |
| 建 MCP server | `brainstorming` → `mcp-builder` |
| 操作 PDF | `pdf` |
| 操作 Word 文件 | `docx` |
| 操作 Excel | `xlsx` |
| 操作 PowerPoint | `pptx` |
| 撰寫技術規格 / 設計文件 | `doc-coauthoring` |
| 撰寫內部溝通（3P 更新、事故報告） | `internal-comms` |

### 🛠 Skill 維護

| 我想要... | 使用 Skills |
|----------|------------|
| 創建或改善 AI Skill | `brainstorming` → `writing-skills` |
| 同步 Anthropic skills 上游 | `anthropic-skills-sync` |
| 同步 superpowers 上游 | `superpowers-skills-sync` |
| 同步 CLI 文件（Claude Code / Copilot） | `cli-doc-sync` |
| 一鍵同步所有上游變更（Dependabot PR 觸發） | `sync-all` |

---

## 第一層 Router 入口

按需進入，不要一次展開全部：

| 涵蓋範疇 | Router |
|---------|--------|
| 創意設計・前端工程・AI 工程・Office 文件・技術寫作 | [anthropic-skill](.claude/skills/anthropic-skill/SKILL.md) |
| 開發流程・Code Review・並行協作・Git 工作流・維運 | [superpowers-skill](.claude/skills/superpowers-skill/SKILL.md) |

---

## Skill Locations

| 目錄 | 來源 | 說明 |
|------|------|------|
| `anthropic-skills/` | Anthropic 上游 | 原始 skill 定義（勿直接修改） |
| `superpowers/` | superpowers 上游 | 原始 skill 定義（勿直接修改） |
| `.claude/skills/anthropic-skill/` | 本地 router | Anthropic skills 第一層分類入口 |
| `.claude/skills/superpowers-skill/` | 本地 router | Superpowers skills 第一層分類入口 |
| `.claude/skills/_shared/` | 共用協議 | `upstream-sync-protocol.md` 供各 sync skill 引用 |
| `.claude/skills/anthropic-skills-sync/` | 維運 skill | 同步 Anthropic skills 上游 |
| `.claude/skills/superpowers-skills-sync/` | 維運 skill | 同步 superpowers 上游 |
| `.claude/skills/cli-doc-sync/` | 維運 skill | CLI 文件同步（Claude Code、GitHub Copilot） |
| `.claude/skills/sync-all/` | 本地自製 | 統一 orchestrator：偵測 Dependabot PR → invoke 各 sync skill |
| `aery-marketplace/` | 本地 plugin root | **`aery-skills`** plugin：mongo、windows-script、write-md（可安裝的 self-contained plugin / marketplace root）|
