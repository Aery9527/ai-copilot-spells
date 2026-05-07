# AGENTS_zhTW.md — Skill 組合查表

本文件用途：快速找到當前任務對應的 skill 組合。Skill 細節請沿連結進入；此檔只保留第一層 routing。

## 任務路由

### 開發流程

- 如果使用者要完整開發新功能，必須使用 `brainstorming` -> `writing-plans` -> `test-driven-development` -> `subagent-driven-development` -> `requesting-code-review`。
- 如果使用者要 debug 一個 bug，必須使用 `systematic-debugging`。
- 如果使用者要宣告完成，或在 commit / PR 前做驗證，必須使用 `verification-before-completion`。
- 如果使用者要在新 session 執行計畫，必須使用 `executing-plans`。
- 如果使用者要在當前 session 以 subagent 逐 task 執行計畫，必須使用 `subagent-driven-development`。
- 如果使用者要並行處理多個獨立子任務，必須使用 `dispatching-parallel-agents`。
- 如果使用者要在開工前隔離 workspace，必須使用 `using-git-worktrees`。

### Review 與收尾

- 如果使用者要先技術評估 code review 意見再決定是否實作，必須使用 `receiving-code-review`。
- 如果使用者要在功能完成後要求 review，必須使用 `requesting-code-review`。
- 如果使用者要在所有任務完成後選擇收尾方式，必須使用 `finishing-a-development-branch`。

### 創意、前端與文件

- 如果使用者要建 Web UI 或 landing page，必須使用 `brainstorming` -> `frontend-design`。
- 如果使用者要建複雜 Claude artifact（React + shadcn），必須使用 `web-artifacts-builder`。
- 如果使用者要測試本地 Web 應用（Playwright），必須使用 `webapp-testing`。
- 如果使用者要生成海報或靜態視覺（PNG / PDF），必須使用 `canvas-design`。
- 如果使用者要生成算法藝術，例如流場、粒子或幾何，必須使用 `algorithmic-art`。
- 如果使用者要為 artifact 套主題，必須使用 `theme-factory`。
- 如果使用者要套用 Anthropic 品牌色彩，必須使用 `brand-guidelines`。
- 如果使用者要做 Slack 動態 GIF，必須使用 `slack-gif-creator`。

### AI 工程、文件操作與寫作

- 如果使用者要建 Claude API 應用或 Anthropic SDK 整合，必須使用 `brainstorming` -> `claude-api`。
- 如果使用者要建 MCP server，必須使用 `brainstorming` -> `mcp-builder`。
- 如果使用者要操作 PDF，必須使用 `pdf`。
- 如果使用者要操作 Word 文件，必須使用 `docx`。
- 如果使用者要操作 Excel，必須使用 `xlsx`。
- 如果使用者要操作 PowerPoint，必須使用 `pptx`。
- 如果使用者要撰寫技術規格或設計文件，必須使用 `doc-coauthoring`。
- 如果使用者要撰寫內部溝通，例如 3P 更新或事故報告，必須使用 `internal-comms`。

### Skill 維護

- 如果使用者要建立或改善 AI skill，必須使用 `brainstorming` -> `writing-skills`。
- 如果使用者要維護本 repo 客製 skills 的治理規則，必須使用 `skills-governance`。
- 如果使用者要同步 Anthropic skills 上游，必須使用 `anthropic-skills-sync`。
- 如果使用者要同步 superpowers 上游，必須使用 `superpowers-skills-sync`。
- 如果使用者要同步 CLI 文件（Claude Code / Copilot），必須使用 `cli-doc-sync`。
- 如果使用者要一次同步所有上游變更（Dependabot PR 觸發），必須使用 `sync-all`。

## Repository 守則

### AGENTS 雙語同步規則

- `AGENTS.md` 是英文主版。
- `AGENTS_zhTW.md` 是繁體中文對照版。
- 只要任一檔案有新增、刪除、重新命名或語意變更，兩個語言版本都必須在同一個 change slice 內同步更新。
- Agent 嚴禁先改其中一版、之後再補另一版。

### `scripts/` 文件同步規則

- 當新增、移除、重新命名或明顯改動 [`scripts/`](scripts/) 目錄下的腳本時，必須在同一個 slice 同步更新 [`scripts/README.md`](scripts/README.md)。
- [`scripts/README.md`](scripts/README.md) 是 [`scripts/`](scripts/) 的唯一總索引；新增腳本必須至少補上用途、參數、行為、風險或副作用，以及最小使用範例。
- 若 [`README.md`](README.md) 已列出腳本入口或摘要，agent 必須檢查是否也需要同步更新。

## 第一層 Router 入口

- 如果任務屬於創意設計、前端工程、AI 工程、Office 文件或技術寫作，讀 [anthropic-skill](.claude/skills/anthropic-skill/SKILL.md)。
- 如果任務屬於開發流程、Code Review、並行協作、Git 工作流或維運，讀 [superpowers-skill](.claude/skills/superpowers-skill/SKILL.md)。
- Agent 必須只進入需要的 router；嚴禁預設一次展開全部 router。

## Skill Locations

- [`anthropic-skills/`](anthropic-skills/) — Anthropic 上游 — 原始 skill 定義；不要直接修改。
- [`superpowers/`](superpowers/) — superpowers 上游 — 原始 workflow skill 定義；不要直接修改。
- [`.claude/skills/anthropic-skill/`](.claude/skills/anthropic-skill/) — 本地 router — Anthropic skills 第一層分類入口。
- [`.claude/skills/superpowers-skill/`](.claude/skills/superpowers-skill/) — 本地 router — superpowers skills 第一層分類入口。
- [`.claude/skills/_shared/`](.claude/skills/_shared/) — 共用協議 — 包含 [`upstream-sync-protocol.md`](.claude/skills/_shared/upstream-sync-protocol.md)，供各 sync skill 引用。
- [`.claude/skills/anthropic-skills-sync/`](.claude/skills/anthropic-skills-sync/) — 維運 skill — 同步 Anthropic skills 上游。
- [`.claude/skills/superpowers-skills-sync/`](.claude/skills/superpowers-skills-sync/) — 維運 skill — 同步 superpowers 上游。
- [`.claude/skills/cli-doc-sync/`](.claude/skills/cli-doc-sync/) — 維運 skill — 同步 Claude Code 與 GitHub Copilot 的 CLI 文件。
- [`.claude/skills/sync-all/`](.claude/skills/sync-all/) — 本地自製 skill — 統一 orchestrator：偵測 Dependabot PR 並 invoke 各 sync skill。
- [`.agents/skills/`](.agents/skills/) — 本地 project-specific custom skills — 專案內部治理與 repo 客製 workflow，例如 [`skills-governance`](.agents/skills/skills-governance/SKILL.md)。
- [`scripts/`](scripts/) — 本地維護腳本 — repo 維護與自動化腳本；文件索引在 [`scripts/README.md`](scripts/README.md)。
