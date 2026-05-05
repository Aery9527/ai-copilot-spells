# AGENTS_zhTW.md — Skill 組合查表

本文件用途：**快速找到當前任務對應的 skill 組合**。Skill 細節請沿連結進入；此檔只保留第一層 routing。

## 快速導覽

- [任務 → Skill 組合](#任務--skill-組合)
- [Repository 守則](#repository-守則)
- [第一層 Router 入口](#第一層-router-入口)
- [Skill Locations](#skill-locations)

---

## 任務 → Skill 組合

### 開發流程

| 我想要... | 使用 Skills（依序） |
|----------|-------------------|
| 完整開發新功能 | `brainstorming` → `writing-plans` → `test-driven-development` → `subagent-driven-development` → `requesting-code-review` |
| Debug 一個 bug | `systematic-debugging` |
| 宣告完成 / commit 前 / PR 前驗證 | `verification-before-completion` |
| 在新 session 執行計畫 | `executing-plans` |
| 在當前 session 以 subagent 逐 task 執行計畫 | `subagent-driven-development` |
| 並行處理多個獨立子任務 | `dispatching-parallel-agents` |
| 開工前先隔離 workspace | `using-git-worktrees` |

### Review 與收尾

| 我想要... | 使用 Skills |
|----------|------------|
| 收到 code review 意見後，先技術評估再實作 | `receiving-code-review` |
| 功能完成後要求 review | `requesting-code-review` |
| 所有任務完成後選擇收尾方式 | `finishing-a-development-branch` |

### 創意、前端與文件

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

### AI 工程、文件操作與寫作

| 我想要... | 使用 Skills |
|----------|------------|
| 建 Claude API 應用 / Anthropic SDK 整合 | `brainstorming` → `claude-api` |
| 建 MCP server | `brainstorming` → `mcp-builder` |
| 操作 PDF | `pdf` |
| 操作 Word 文件 | `docx` |
| 操作 Excel | `xlsx` |
| 操作 PowerPoint | `pptx` |
| 撰寫技術規格 / 設計文件 | `doc-coauthoring` |
| 撰寫內部溝通（3P 更新、事故報告） | `internal-comms` |

### Skill 維護

| 我想要... | 使用 Skills |
|----------|------------|
| 建立或改善 AI skill | `brainstorming` → `writing-skills` |
| 維護本 repo 客製 skills 的治理規則 | `skills-governance` |
| 同步 Anthropic skills 上游 | `anthropic-skills-sync` |
| 同步 superpowers 上游 | `superpowers-skills-sync` |
| 同步 CLI 文件（Claude Code / Copilot） | `cli-doc-sync` |
| 一次同步所有上游變更（Dependabot PR 觸發） | `sync-all` |

---

## Repository 守則

### AGENTS 雙語同步規則

- `AGENTS.md` 為英文主版。
- `AGENTS_zhTW.md` 為繁體中文對照版。
- 只要任一檔案有新增、刪除、重新命名或語意變更，兩個語言版本都必須在同一個 change slice 內同步更新。
- 不可接受先改其中一版、之後再補另一版的做法。

### `scripts/` 文件同步規則

- 當新增、移除、重新命名或明顯改動 `scripts/` 目錄下的腳本時，**必須**在同一個 slice 同步更新 [`scripts/README.md`](scripts/README.md)。
- [`scripts/README.md`](scripts/README.md) 是 `scripts/` 的唯一總索引；新增腳本至少要補上用途、參數、行為、風險 / 副作用與最小使用範例。
- 若 root [`README.md`](README.md) 已列出腳本入口或摘要，也要檢查是否需要同步更新。

---

## 第一層 Router 入口

按需進入，不要一次展開全部：

| 涵蓋範疇 | Router |
|---------|--------|
| 創意設計、前端工程、AI 工程、Office 文件、技術寫作 | [anthropic-skill](.claude/skills/anthropic-skill/SKILL.md) |
| 開發流程、Code Review、並行協作、Git 工作流、維運 | [superpowers-skill](.claude/skills/superpowers-skill/SKILL.md) |

---

## Skill Locations

| 目錄 | 來源 | 說明 |
|------|------|------|
| `anthropic-skills/` | Anthropic 上游 | 原始 skill 定義；不要直接修改 |
| `superpowers/` | superpowers 上游 | 原始 workflow skill 定義；不要直接修改 |
| `.claude/skills/anthropic-skill/` | 本地 router | Anthropic skills 第一層分類入口 |
| `.claude/skills/superpowers-skill/` | 本地 router | superpowers skills 第一層分類入口 |
| `.claude/skills/_shared/` | 共用協議 | `upstream-sync-protocol.md` 供各 sync skill 引用 |
| `.claude/skills/anthropic-skills-sync/` | 維運 skill | 同步 Anthropic skills 上游 |
| `.claude/skills/superpowers-skills-sync/` | 維運 skill | 同步 superpowers 上游 |
| `.claude/skills/cli-doc-sync/` | 維運 skill | 同步 Claude Code 與 GitHub Copilot 的 CLI 文件 |
| `.claude/skills/sync-all/` | 本地自製 skill | 統一 orchestrator：偵測 Dependabot PR 並 invoke 各 sync skill |
| `.agents/skills/` | 本地 project-specific custom skills | 專案內部治理與 repo 客製 workflow，例如 `skills-governance` |
| `scripts/` | 本地維護腳本 | repo 維護與自動化腳本；文件索引在 [`scripts/README.md`](scripts/README.md) |
