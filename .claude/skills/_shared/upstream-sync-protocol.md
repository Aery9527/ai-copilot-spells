# Upstream Skills Library Sync Protocol

供所有 upstream skill library 的 sync skill 共用。引用方在自己的 SKILL.md 填入庫設定後，
按照本文件的流程執行。本文件非 Claude Code skill（無 frontmatter），不直接出現在 skill 清單。

---

## 變數定義

各引用方在自己的 SKILL.md 提供以下值：

| 變數 | 說明 | 範例（anthropic） | 範例（superpowers） |
|------|------|-----------------|-------------------|
| `LIBRARY_NAME` | 庫的識別名稱 | `anthropic-skills` | `superpowers` |
| `SUBMODULE_PATH` | git submodule 相對路徑 | `anthropic-skills/` | `superpowers/` |
| `LOCAL_ROUTER_PATH` | 本地 router 目錄 | `.claude/skills/anthropic-skill/` | `.claude/skills/superpowers-skill/` |
| `SKILL_SOURCE_PATTERN` | skill 來源路徑模式 | `skills/<name>/SKILL.md` | `skills/<name>/SKILL.md` |
| `CO_AUTHOR` | commit の Co-Authored-By 值 | `Claude Sonnet 4.6 <noreply@anthropic.com>` | `Claude Sonnet 4.6 <noreply@anthropic.com>` |

---

## Sync 流程

### Step 1 — 確認 submodule 狀態

```bash
git -C {{SUBMODULE_PATH}} status
```

若失敗（非 git repo）：停止，通知使用者先初始化 submodule：
```bash
git submodule update --init {{SUBMODULE_PATH}}
```

### Step 2 — 檢查上游更新

```bash
git -C {{SUBMODULE_PATH}} fetch origin
git -C {{SUBMODULE_PATH}} log HEAD..origin/main --oneline
```

- 若輸出**為空** → 無更新，告知使用者並停止。
- 若輸出**有 commits** → 繼續 Step 3。

### Step 3 — 識別異動 skill

```bash
# 所有異動的檔案
git -C {{SUBMODULE_PATH}} diff HEAD..origin/main --name-only

# 只看新增的 skill
git -C {{SUBMODULE_PATH}} diff HEAD..origin/main --name-only --diff-filter=A
```

從輸出解析 skill 名稱，模式為 `skills/<name>/...`：
- `CHANGED_SKILLS` — 有任何異動的 skill 目錄列表
- `NEW_SKILLS` — 全新新增的 skill（`CHANGED_SKILLS` 的子集）

### Step 4 — Pull 更新

```bash
git -C {{SUBMODULE_PATH}} pull origin main
```

記錄新的 HEAD hash（供 commit message 使用）：
```bash
NEW_HEAD=$(git -C {{SUBMODULE_PATH}} rev-parse --short HEAD)
```

### Step 5 — Regenerate 每個異動 skill 的摘要

對 `CHANGED_SKILLS` 中的每個 skill：

1. 讀取 `{{SUBMODULE_PATH}}/skills/<name>/SKILL.md`（上游原文）
2. 按照下方「**SKILL.md 摘要格式**」重新生成 `{{LOCAL_ROUTER_PATH}}/skills/<name>/SKILL.md`
3. 若為新 skill（在 `NEW_SKILLS` 中）：先建立 `{{LOCAL_ROUTER_PATH}}/skills/<name>/` 目錄

### Step 6 — 更新 router 與 category 文件（視情況）

若 `NEW_SKILLS` 非空，或有 skill 需要移動 category：

1. 更新 `{{LOCAL_ROUTER_PATH}}/SKILL.md`（第一層 router 查詢表）
2. 更新對應的 `{{LOCAL_ROUTER_PATH}}/categories/*.md`
3. 更新 `AGENTS.md` 的任務查詢表（若新 skill 影響任務導向路由）

### Step 7 — Commit

```bash
git add -A
git commit -m "sync: update {{LIBRARY_NAME}} skill summaries

Synced from {{LIBRARY_NAME}} @ $NEW_HEAD
Updated skills: <CHANGED_SKILLS 以逗號分隔>

Co-Authored-By: {{CO_AUTHOR}}"
```

---

## SKILL.md 摘要格式

生成 `{{LOCAL_ROUTER_PATH}}/skills/<name>/SKILL.md` 時使用此格式：

```markdown
---
name: <skill-name>
description: <原文 description，來自上游 SKILL.md frontmatter，保持英文>
source: {{SUBMODULE_PATH}}/skills/<name>/SKILL.md
---

## 概述

<1-2 句繁體中文，說明這個 skill 做什麼>

## 能做什麼

<條列或表格，具體說明支援的操作；保持精確，不要泛化>

## 解決什麼問題

<這個 skill 存在的原因；它解決什麼具體痛點>

## 何時使用（觸發條件）

<觸發關鍵字、使用者意圖短語、觸發情境；複製上游的 "When to Use" 精華>

## 關鍵技術棧

<使用的工具、框架、語言；若無特定技術棧，描述搭配使用的其他 skill>

## 重要注意事項

<限制、已知問題、陷阱、Iron Law（若有）>
```

---

## Edge Cases

| 情境 | 處理方式 |
|------|---------|
| Skill 在上游被刪除 | 通知使用者，**確認後**才移除本地摘要與 category 引用；不自動刪除 |
| 新 skill 無 SKILL.md | 記錄警告並跳過；不建立空摘要 |
| Skill 跨 category 異動 | 更新 `categories/` 對應檔；若影響 AGENTS.md 的路由表也一併更新 |
| git push 需要認證 | 等待 browser auth 完成後繼續 |
| Submodule 未初始化 | Step 1 會失敗；提示執行 `git submodule update --init` |
| `origin/main` 不存在 | 確認上游 default branch 名稱（可能為 `master`），調整 fetch 指令 |

---

## 驗證步驟

Sync 完成後執行：

```bash
# 確認 router 結構完整（每個 skill 都有對應目錄）
ls {{LOCAL_ROUTER_PATH}}/skills/

# 確認無未提交異動
git status

# 確認最新 commit
git log --oneline -3
```
