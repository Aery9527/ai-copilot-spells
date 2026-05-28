# Upstream Skills Library Sync Protocol

供所有 upstream skill library 的 sync skill 共用。引用方在自己的 `SKILL.md` 填入庫設定後，按照本文件的流程執行。本文件不是 Claude Code skill；它沒有 frontmatter，也不直接出現在 skill 清單。

## Purpose

提供所有 upstream skill library 共用的同步流程，讓每個 sync skill 只需要填入庫設定，不需要重複維護流程本體。

## Caller-Provided Variables

- `LIBRARY_NAME` — 庫的識別名稱。
  - Anthropic 範例：`anthropic-skills`
  - superpowers 範例：`superpowers`
- `SUBMODULE_PATH` — git submodule 相對路徑。
  - Anthropic 範例：`skill-source/anthropic-skills/`
  - superpowers 範例：`skill-source/superpowers/`
- `CATALOG_PATH` — 本地 catalog 文件。
  - Anthropic 範例：`docs/skills/anthropic-skills-catalog.md`
  - superpowers 範例：`docs/skills/superpowers-skills-catalog.md`
- `SKILL_SOURCE_PATTERN` — skill 來源路徑模式。
  - 兩者皆為 `skills/<name>/SKILL.md`
- `CO_AUTHOR` — commit 的 `Co-Authored-By` 值。
  - 目前兩者皆使用 `Claude Sonnet 4.6 <noreply@anthropic.com>`

## Sync Workflow

### Step 1 — Confirm Submodule Status

執行：

```bash
git -C {{SUBMODULE_PATH}} status
```

如果失敗，必須停止並通知使用者先初始化 submodule：

```bash
git submodule update --init {{SUBMODULE_PATH}}
```

### Step 2 — Check Upstream Updates

執行：

```bash
git -C {{SUBMODULE_PATH}} fetch origin
git -C {{SUBMODULE_PATH}} log HEAD..origin/main --oneline
```

- 如果輸出為空，表示沒有更新；必須告知使用者並停止。
- 如果輸出有 commits，繼續 Step 3。

### Step 3 — Identify Changed Skills

執行：

```bash
git -C {{SUBMODULE_PATH}} diff HEAD..origin/main --name-only
git -C {{SUBMODULE_PATH}} diff HEAD..origin/main --name-only --diff-filter=A
```

必須從 `skills/<name>/...` 模式解析出：

- `CHANGED_SKILLS` — 所有有異動的 skill 目錄。
- `NEW_SKILLS` — 全新新增的 skill；它是 `CHANGED_SKILLS` 的子集。

### Step 4 — Pull Updates

執行：

```bash
git -C {{SUBMODULE_PATH}} pull origin main
NEW_HEAD=$(git -C {{SUBMODULE_PATH}} rev-parse --short HEAD)
```

`NEW_HEAD` 供後續 commit message 使用。

### Step 5 — Update Catalog Notes

對 `CHANGED_SKILLS` 中的每個 skill，依序執行：

1. 讀取 `{{SUBMODULE_PATH}}/skills/<name>/SKILL.md`。
2. 檢查 `{{CATALOG_PATH}}` 是否已列出該 skill。
3. 如果 `<name>` 屬於 `NEW_SKILLS`，必須把它加入 `{{CATALOG_PATH}}` 的正確分類，並連回上游 `SKILL.md`。
4. 如果既有 skill 的用途或分類改變，必須更新 `{{CATALOG_PATH}}` 的一句話說明或分類位置。

### Step 6 — Update Routing Documents When Needed

如果 `NEW_SKILLS` 非空，或 skill 需要移動 category，必須同步更新：

1. `{{CATALOG_PATH}}`
2. [`AGENTS.md`](../../../AGENTS.md)，如果任務導向路由受到影響
3. [`AGENTS_zhTW.md`](../../../AGENTS_zhTW.md)，如果 [`AGENTS.md`](../../../AGENTS.md) 有語意變更
4. [`README.md`](../../../README.md)，如果公開導覽或目錄結構受到影響

### Step 7 — Commit

執行：

```bash
git add -A
git commit -m "sync: update {{LIBRARY_NAME}} skill catalog

Synced from {{LIBRARY_NAME}} @ $NEW_HEAD
Updated catalog entries: <CHANGED_SKILLS 以逗號分隔>

Co-Authored-By: {{CO_AUTHOR}}"
```

## Catalog Entry Format

`{{CATALOG_PATH}}` 必須維持 human-reader Markdown 結構。每個 skill entry 必須使用一行 bullet，格式如下：

```markdown
- [<skill-name>](../../{{SUBMODULE_PATH}}/skills/<name>/SKILL.md) — <一句話說明該 skill 何時使用；保持具體，不要泛化>
```

## Edge Cases

- 如果 skill 在上游被刪除，必須通知使用者；只有在確認後才能移除 catalog entry，嚴禁自動刪除。
- 如果新 skill 沒有 `SKILL.md`，必須記錄警告並跳過，嚴禁建立空 catalog entry。
- 如果 skill 跨 category 異動，必須更新 `{{CATALOG_PATH}}` 的分類；如果影響 [`AGENTS.md`](../../../AGENTS.md) 的任務路由，也要同步更新。
- 如果 `git push` 需要認證，必須等待 browser auth 完成後再繼續。
- 如果 submodule 未初始化，Step 1 會失敗；必須提示 `git submodule update --init`。
- 如果 `origin/main` 不存在，必須確認上游 default branch 名稱，例如 `master`，再調整 fetch 指令。

## Verification

Sync 完成後執行：

```powershell
Test-Path {{CATALOG_PATH}}
git status
git log --oneline -3
```

驗證重點：

- `{{CATALOG_PATH}}` 存在，且每個新增或異動 skill 都有正確連結。
- 沒有未提交異動。
- 最新 commit 符合同步預期。
