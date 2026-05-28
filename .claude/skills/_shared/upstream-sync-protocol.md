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
- `LOCAL_ROUTER_PATH` — 本地 router 目錄。
  - Anthropic 範例：`.claude/skills/anthropic-skill/`
  - superpowers 範例：`.claude/skills/superpowers-skill/`
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

### Step 5 — Regenerate Changed Skill Summaries

對 `CHANGED_SKILLS` 中的每個 skill，依序執行：

1. 讀取 `{{SUBMODULE_PATH}}/skills/<name>/SKILL.md`。
2. 依照下方的摘要格式，重新生成 `{{LOCAL_ROUTER_PATH}}/skills/<name>/SKILL.md`。
3. 如果 `<name>` 屬於 `NEW_SKILLS`，必須先建立 `{{LOCAL_ROUTER_PATH}}/skills/<name>/`。

### Step 6 — Update Router And Category Files When Needed

如果 `NEW_SKILLS` 非空，或 skill 需要移動 category，必須同步更新：

1. `{{LOCAL_ROUTER_PATH}}/SKILL.md`
2. `{{LOCAL_ROUTER_PATH}}/categories/*.md`
3. [`AGENTS.md`](../../../AGENTS.md)，如果任務導向路由受到影響

### Step 7 — Commit

執行：

```bash
git add -A
git commit -m "sync: update {{LIBRARY_NAME}} skill summaries

Synced from {{LIBRARY_NAME}} @ $NEW_HEAD
Updated skills: <CHANGED_SKILLS 以逗號分隔>

Co-Authored-By: {{CO_AUTHOR}}"
```

## Summary Format For Generated `SKILL.md`

生成 `{{LOCAL_ROUTER_PATH}}/skills/<name>/SKILL.md` 時，必須使用以下結構：

```markdown
---
name: <skill-name>
description: <原文 description，來自上游 SKILL.md frontmatter，保持英文>
source: {{SUBMODULE_PATH}}/skills/<name>/SKILL.md
---

## 概述

<1-2 句繁體中文，說明這個 skill 做什麼>

## 能做什麼

<條列，具體說明支援的操作；保持精確，不要泛化>

## 解決什麼問題

<這個 skill 存在的原因；它解決什麼具體痛點>

## 何時使用（觸發條件）

<觸發關鍵字、使用者意圖短語、觸發情境；複製上游的 "When to Use" 精華>

## 關鍵技術棧

<使用的工具、框架、語言；若無特定技術棧，描述搭配使用的其他 skill>

## 重要注意事項

<限制、已知問題、陷阱、Iron Law（若有）>
```

## Edge Cases

- 如果 skill 在上游被刪除，必須通知使用者；只有在確認後才能移除本地摘要與 category 引用，嚴禁自動刪除。
- 如果新 skill 沒有 `SKILL.md`，必須記錄警告並跳過，嚴禁建立空摘要。
- 如果 skill 跨 category 異動，必須更新 [`categories/`](../) 對應檔；如果影響 [`AGENTS.md`](../../../AGENTS.md) 的任務路由，也要同步更新。
- 如果 `git push` 需要認證，必須等待 browser auth 完成後再繼續。
- 如果 submodule 未初始化，Step 1 會失敗；必須提示 `git submodule update --init`。
- 如果 `origin/main` 不存在，必須確認上游 default branch 名稱，例如 `master`，再調整 fetch 指令。

## Verification

Sync 完成後執行：

```bash
ls {{LOCAL_ROUTER_PATH}}/skills/
git status
git log --oneline -3
```

驗證重點：

- `{{LOCAL_ROUTER_PATH}}/skills/` 結構完整。
- 沒有未提交異動。
- 最新 commit 符合同步預期。
