# Upstream Auto-Sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在現有 repo 加入 Dependabot submodule 偵測 + 本地 `sync-all` skill，讓使用者執行單一指令即可完成所有上游 sync 工作。

**Architecture:** Dependabot 監控 `.gitmodules` 並在上游有新 commit 時自動開 PR（branch: `dependabot/submodules/<name>`）。使用者透過 email 得知更新後，invoke `sync-all` skill，它掃描 `.claude/skills/*/SKILL.md` frontmatter 動態建立 submodule → sync skill 映射表，依序 invoke 對應 sync skill，最後關閉 Dependabot PR。

**Tech Stack:** GitHub Dependabot（gitsubmodules）、gh CLI、YAML frontmatter、Markdown skill files

---

## File Structure

| 操作 | 路徑 | 說明 |
|------|------|------|
| Create | `.github/dependabot.yml` | 啟用 Dependabot submodule 監控 |
| Create | `.claude/skills/sync-all/SKILL.md` | 新統一 orchestrator skill |
| Modify | `.claude/skills/anthropic-skills-sync/SKILL.md` | 加 `submodule-path` frontmatter |
| Modify | `.claude/skills/superpowers-skills-sync/SKILL.md` | 加 `submodule-path` frontmatter |
| Modify | `AGENTS.md` | 加 sync-all 至 Skill 維護表與 Skill Locations 表 |

---

## Task 1: Add `submodule-path` frontmatter to existing sync skills

`sync-all` 的 runtime auto-discovery 依賴此欄位，需先完成。

**Files:**
- Modify: `.claude/skills/anthropic-skills-sync/SKILL.md:1-4`
- Modify: `.claude/skills/superpowers-skills-sync/SKILL.md:1-4`

- [ ] **Step 1: 修改 `anthropic-skills-sync/SKILL.md` frontmatter**

  將 `.claude/skills/anthropic-skills-sync/SKILL.md` 的 frontmatter 從：
  ```yaml
  ---
  name: anthropic-skills-sync
  description: Use this skill when the user asks to sync...
  ---
  ```
  改為：
  ```yaml
  ---
  name: anthropic-skills-sync
  submodule-path: anthropic-skills
  description: Use this skill when the user asks to sync...
  ---
  ```

- [ ] **Step 2: 修改 `superpowers-skills-sync/SKILL.md` frontmatter**

  將 `.claude/skills/superpowers-skills-sync/SKILL.md` 的 frontmatter 從：
  ```yaml
  ---
  name: superpowers-skills-sync
  description: Use this skill when the user asks to sync...
  ---
  ```
  改為：
  ```yaml
  ---
  name: superpowers-skills-sync
  submodule-path: superpowers
  description: Use this skill when the user asks to sync...
  ---
  ```

- [ ] **Step 3: 驗證 frontmatter 欄位存在**

  Run:
  ```powershell
  Select-String -Path ".claude\skills\anthropic-skills-sync\SKILL.md" -Pattern "submodule-path: anthropic-skills"
  Select-String -Path ".claude\skills\superpowers-skills-sync\SKILL.md" -Pattern "submodule-path: superpowers"
  ```
  Expected: 各輸出一行匹配結果，無空輸出。

- [ ] **Step 4: Commit**

  ```bash
  git add .claude/skills/anthropic-skills-sync/SKILL.md .claude/skills/superpowers-skills-sync/SKILL.md
  git commit -m "feat: add submodule-path frontmatter to sync skills for auto-discovery

  Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
  ```

---

## Task 2: Create `.github/dependabot.yml`

**Files:**
- Create: `.github/dependabot.yml`

- [ ] **Step 1: 建立 `.github/` 目錄並建立 `dependabot.yml`**

  建立 `.github/dependabot.yml`，內容如下：
  ```yaml
  version: 2
  updates:
    - package-ecosystem: "gitsubmodules"
      directory: "/"
      schedule:
        interval: "daily"
  ```

- [ ] **Step 2: 驗證 YAML 語法合法**

  Run:
  ```powershell
  python -c "import yaml; yaml.safe_load(open('.github/dependabot.yml').read()); print('YAML valid')"
  ```
  Expected: `YAML valid`

- [ ] **Step 3: Commit**

  ```bash
  git add .github/dependabot.yml
  git commit -m "ci: enable Dependabot for git submodule updates

  Single entry covers all submodules. New submodules are auto-included.

  Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
  ```

---

## Task 3: Create `sync-all` skill

**Files:**
- Create: `.claude/skills/sync-all/SKILL.md`

- [ ] **Step 1: 建立 `.claude/skills/sync-all/` 目錄與 `SKILL.md`**

  建立 `.claude/skills/sync-all/SKILL.md`，內容如下：

  ````markdown
  ---
  name: sync-all
  description: Use when Dependabot has opened PRs for submodule updates and you want to sync all pending upstream skill libraries in one step. Reads open Dependabot PRs, auto-discovers corresponding sync skills via SKILL.md frontmatter, runs them in sequence, then closes the PRs. Triggers on: "sync all", "update all skills", "process Dependabot PRs", "run sync-all".
  ---

  # Sync-All

  統一入口 skill，自動發現所有待 sync 的 submodule 並依序 orchestrate 對應的 sync skill。

  ## 前置條件

  確認 `gh` CLI 已登入：

  ```bash
  gh auth status
  ```

  若輸出包含 `You are not logged into any GitHub hosts`，提示使用者執行：

  ```bash
  gh auth login
  ```

  停止並等待使用者重試。

  ## Step 1 — 列出 open Dependabot PRs

  ```bash
  gh pr list \
    --author "app/dependabot" \
    --state open \
    --json number,headRefName,title \
    --jq '.[] | select(.headRefName | startswith("dependabot/submodules/"))'
  ```

  - 若結果為空 → 告知使用者「✅ 無待處理的上游更新」並停止，不報錯
  - 若有結果 → 繼續，記錄每個 PR 的 `number` 與 `headRefName`

  ## Step 2 — 解析 submodule 名稱

  從 `headRefName` 中移除前綴 `dependabot/submodules/` 得到 submodule path：

  ```
  dependabot/submodules/anthropic-skills  →  anthropic-skills
  dependabot/submodules/superpowers       →  superpowers
  ```

  ## Step 3 — Auto-discover sync skills（runtime）

  掃描 `.claude/skills/*/SKILL.md`，讀取每個檔案開頭的 YAML frontmatter（`---` 區塊）。
  找出含有 `submodule-path` 欄位的 skill，建立動態映射表：

  ```
  submodule-path 值    →  skill 目錄名稱
  "anthropic-skills"   →  "anthropic-skills-sync"
  "superpowers"        →  "superpowers-skills-sync"
  ```

  ## Step 4 — 比對並準備執行清單

  對 Step 2 的每個 submodule：
  - 若在映射表中找到對應 skill → 加入執行清單（記錄 skill name 與 PR number）
  - 若找不到 → 印警告 `⚠️ 找不到 <submodule-name> 的對應 sync skill，跳過` 並繼續

  若執行清單為空 → 告知使用者「⚠️ 所有 PR 都找不到對應 sync skill，請手動檢查」並停止。

  ## Step 5 — 依序 invoke sync skill

  對執行清單中每個項目，使用 Skill tool invoke 對應的 sync skill。
  每個 sync skill 負責：pull submodule → AI 生成繁中摘要 → commit → push to main。
  等待每個 sync skill 完成後再進行下一個。

  ## Step 6 — 關閉 Dependabot PR

  每個成功 sync 的 submodule，關閉對應 PR：

  ```bash
  gh pr close <PR_NUMBER> \
    --comment "Synced via sync-all skill. Submodule updated and skill summaries regenerated."
  ```

  若 `gh pr close` 失敗（PR 已關閉或已被 merge）：
  - 印出 `ℹ️ PR #<N> 已關閉，跳過`
  - 繼續處理其他 PR，不視為錯誤

  ## 完成

  印出摘要：

  ```
  ✅ sync-all 完成
     已同步：<skill-name1>, <skill-name2>
     已關閉 PR：#<N1>, #<N2>
  ```
  ````

- [ ] **Step 2: 驗證 frontmatter 存在且結構正確**

  Run:
  ```powershell
  Select-String -Path ".claude\skills\sync-all\SKILL.md" -Pattern "^name: sync-all"
  Select-String -Path ".claude\skills\sync-all\SKILL.md" -Pattern "^description:"
  ```
  Expected: 各輸出一行匹配結果。

- [ ] **Step 3: 驗證 6 個步驟都在檔案中**

  Run:
  ```powershell
  Select-String -Path ".claude\skills\sync-all\SKILL.md" -Pattern "## Step [1-6]"
  ```
  Expected: 輸出 6 行，分別對應 Step 1 ~ Step 6。

- [ ] **Step 4: Commit**

  ```bash
  git add .claude/skills/sync-all/SKILL.md
  git commit -m "feat: add sync-all skill for unified upstream sync orchestration

  Reads open Dependabot PRs, auto-discovers sync skills via SKILL.md
  frontmatter (submodule-path field), invokes them in sequence, then
  closes the corresponding PRs.

  Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
  ```

---

## Task 4: Update `AGENTS.md`

**Files:**
- Modify: `AGENTS.md`

- [ ] **Step 1: 在 Skill 維護表中加入 `sync-all` 列**

  在 `AGENTS.md` 的「🛠 Skill 維護」表格中，在現有三行之後加入：

  ```markdown
  | 一鍵同步所有上游變更（Dependabot PR 觸發） | `sync-all` |
  ```

  修改後的表格應為：
  ```markdown
  | 我想要... | 使用 Skills |
  |----------|------------|
  | 創建或改善 AI Skill | `brainstorming` → `writing-skills` |
  | 同步 Anthropic skills 上游 | `anthropic-skills-sync` |
  | 同步 superpowers 上游 | `superpowers-skills-sync` |
  | 同步 CLI 文件（Claude Code / Copilot） | `cli-doc-sync` |
  | 一鍵同步所有上游變更（Dependabot PR 觸發） | `sync-all` |
  ```

- [ ] **Step 2: 在 Skill Locations 表中加入 `sync-all` 列**

  在 `AGENTS.md` 的「Skill Locations」表格中，緊接 `cli-doc-sync` 列之後加入：

  ```markdown
  | `.claude/skills/sync-all/` | 本地自製 | 統一 orchestrator：偵測 Dependabot PR → invoke 各 sync skill |
  ```

- [ ] **Step 3: 驗證兩處都已加入**

  Run:
  ```powershell
  Select-String -Path "AGENTS.md" -Pattern "sync-all"
  ```
  Expected: 輸出至少 2 行匹配結果（表格行 + Locations 行）。

- [ ] **Step 4: Commit**

  ```bash
  git add AGENTS.md
  git commit -m "docs: register sync-all skill in AGENTS.md

  Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
  ```

---

## 驗收確認

完成所有 Task 後，依序確認：

- [ ] `git log --oneline -5` 顯示 4 個新 commit（Task 1~4 各一）
- [ ] `.github/dependabot.yml` 存在且 YAML 合法
- [ ] `Select-String -Path ".claude\skills\*\SKILL.md" -Pattern "submodule-path:"` 輸出 2 行（anthropic-skills-sync、superpowers-skills-sync）
- [ ] `.claude/skills/sync-all/SKILL.md` 存在，且包含 6 個 Step section
- [ ] `Select-String -Path "AGENTS.md" -Pattern "sync-all"` 輸出 ≥ 2 行
