# AGENTS.md — 專案 Skills 導覽

> 當使用者遇到 Anthropic 官方 skills 範圍內的問題時，Rion 先查閱 [`.claude/skills/anthropic-skill/SKILL.md`](.claude/skills/anthropic-skill/SKILL.md) 做第一層分類，再按需進入其內部的 [`.claude/skills/anthropic-skill/categories/`](.claude/skills/anthropic-skill/categories/) 與 `skills/<name>/SKILL.md` 獲取詳細使用說明。
>
> 這份文件只保留 repo 層級的導覽、plugin 安裝與結構說明；各 Anthropic skill 的細項能力、決策樹與「問題 → Skill」對照，已集中到 [`.claude/skills/anthropic-skill/SKILL.md`](.claude/skills/anthropic-skill/SKILL.md) 作為單一真相來源。

## 快速導覽

- [Anthropic Skills Plugins](#anthropic-skills-plugins)
- [Anthropic Skill Router](#anthropic-skill-router)
- [Project Claude Skills](#project-claude-skills)
- [Skill Locations](#skill-locations)

## Anthropic Skills Plugins

`anthropic-skills` 以 plugin 為單位組織，目前共三個 plugin，可依需求選擇性安裝：

| Plugin | 包含 Skills | 適用場景 |
|--------|------------|---------|
| **document-skills** | `xlsx`, `docx`, `pptx`, `pdf` | 各類 Office 文件與 PDF 的建立、讀取、編輯、轉換 |
| **example-skills** | `algorithmic-art`, `brand-guidelines`, `canvas-design`, `doc-coauthoring`, `frontend-design`, `internal-comms`, `mcp-builder`, `skill-creator`, `slack-gif-creator`, `theme-factory`, `web-artifacts-builder`, `webapp-testing` | 創意設計、前端工程、AI 工程、文字寫作等通用能力 |
| **claude-api** | `claude-api` | 以 Claude API / Anthropic SDK 建構 LLM 應用 |

> 詳細安裝設定見 [`anthropic-skills/.claude-plugin/marketplace.json`](anthropic-skills/.claude-plugin/marketplace.json)。

### 安裝方式

指令語法：`/plugin install <plugin-name>@<marketplace-name>`，`@` 後接的是 `marketplace.json` 頂層的 `name` 欄位（即 `anthropic-agent-skills`），非 GitHub repo 路徑。

**安裝整個 plugin（含 plugin 內所有 skills）：**

```
/plugin marketplace add anthropics/skills
/plugin install example-skills@anthropic-agent-skills
```

**只安裝單一 skill：**

`anthropic-agent-skills` 這個 marketplace 只有三個可安裝單位（`document-skills`、`example-skills`、`claude-api`），沒有以單一 skill 為單位的 plugin entry。**無法只安裝 `skill-creator`**，只能裝整包 `example-skills`。

### 已知 bug：重複載入

**已知 bug 仍然存在**：若同一批 skills 同時由 project top-level entries 與 plugin namespace 暴露，context 與 slash command picker 仍可能重複。當前結構就是為了避免本 repo 預設落入這個情況。

> 來源：[Claude Code 官方文件 — Create plugins](https://docs.anthropic.com/en/docs/claude-code/plugins)
> 相關 issue：[anthropics/claude-code#29520](https://github.com/anthropics/claude-code/issues/29520)、[anthropics/skills#189](https://github.com/anthropics/skills/issues/189)

[返回開頭](#快速導覽)

## Anthropic Skill Router

Anthropic 每個細項 skill 的摘要、能力邊界與決策樹，現在都統一收斂到 [`.claude/skills/anthropic-skill/SKILL.md`](.claude/skills/anthropic-skill/SKILL.md) 與其內部分類檔。若要判斷「現在該讀哪個 skill」，優先從這裡開始，不再以 `AGENTS.md` 維護第二份平行說明。

| 需求類型 | 先讀文件 | 說明 |
|---------|---------|------|
| Creative & Styling | [`.claude/skills/anthropic-skill/categories/creative-and-styling.md`](.claude/skills/anthropic-skill/categories/creative-and-styling.md) | 生成藝術、靜態視覺、品牌規範、主題風格、Slack GIF |
| Frontend Engineering | [`.claude/skills/anthropic-skill/categories/frontend-engineering.md`](.claude/skills/anthropic-skill/categories/frontend-engineering.md) | UI 設計、artifact builder、Web app 測試 |
| AI Engineering | [`.claude/skills/anthropic-skill/categories/ai-engineering.md`](.claude/skills/anthropic-skill/categories/ai-engineering.md) | Claude API、Anthropic SDK、MCP server、skill engineering |
| Office Documents | [`.claude/skills/anthropic-skill/categories/office-documents.md`](.claude/skills/anthropic-skill/categories/office-documents.md) | PDF、Word、PowerPoint、Excel 與文件配圖 |
| Writing | [`.claude/skills/anthropic-skill/categories/writing.md`](.claude/skills/anthropic-skill/categories/writing.md) | 技術文件與內部溝通 |

若分類檔還不足以回答，再按需進入 `skills/<name>/SKILL.md` 的第二層摘要；不要再從 `AGENTS.md` 複製一份 skill 細節，避免內容漂移。

[返回開頭](#快速導覽)

## Project Claude Skills

[`.claude/skills/`](.claude/skills/) 除了 `anthropic-skill` 這個 Anthropic router 之外，也放置少數會被直接當成 project skill 使用的本地技能：

| Skill | 路徑 | 用途 |
|------|------|------|
| `cli-doc-sync` | [`.claude/skills/cli-doc-sync/SKILL.md`](.claude/skills/cli-doc-sync/SKILL.md) | 同步 CLI 參考文件與官方文件，並用 `fetch_docs.py` 做結構化差異比對 |
| `anthropic-skills-sync` | [`.claude/skills/anthropic-skills-sync/SKILL.md`](.claude/skills/anthropic-skills-sync/SKILL.md) | 將本地 Anthropic router 套件與上游 `anthropic-skills/` 對齊 |

這兩個 skill 都是 top-level `.claude/skills/<name>/SKILL.md` 入口，不屬於 `anthropic-skill` 的第二層內容。

[返回開頭](#快速導覽)

## Skill Locations

| 目錄 | 來源 | 說明 |
|------|------|------|
| `anthropic-skills/` | Anthropic 上游 | 原始 skill 定義（上游 repo，勿直接修改） |
| `.claude/skills/` | Claude Code project skills | 包含 `anthropic-skill` router 套件，以及 `cli-doc-sync`、`anthropic-skills-sync` 等 standalone project skills |
| `.agents/skills/` | **個人自製 skills** | 其餘 repo-local skills，如 `mongo`、`plan-extension`、`windows-script`、`write-md` |
| `AGENTS.md` | 本文件 | repo 層級的 skills 索引、plugin 安裝與結構說明 |

### `.claude/` Skills 的用途

[`.claude/skills/anthropic-skill/SKILL.md`](.claude/skills/anthropic-skill/SKILL.md) 是第一層 Anthropic router；它內部的 `categories/` 先做分類與決策，接著再按需讀取 `skills/<name>/SKILL.md` 的第二層摘要。這樣能避免一開始就把所有 Anthropic skills 平鋪進第一層 context。

`cli-doc-sync` 與 `anthropic-skills-sync` 則是獨立的 top-level project skills，分別位於 [`.claude/skills/cli-doc-sync/SKILL.md`](.claude/skills/cli-doc-sync/SKILL.md) 與 [`.claude/skills/anthropic-skills-sync/SKILL.md`](.claude/skills/anthropic-skills-sync/SKILL.md)，不屬於 router 的第二層技能內容。

[返回開頭](#快速導覽)
