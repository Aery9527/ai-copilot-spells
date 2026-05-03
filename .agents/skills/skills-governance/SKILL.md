---
name: skills-governance
description: >-
  用於建立、修改、重新命名或移除 `.agents/skills/` 下的專案客製 skills，
  並套用本 repo 的目錄邊界、文件同步與 Conventional Commit 規則時使用。
---

# Skills Governance

## 快速導覽

- [Overview](#overview)
- [目錄邊界](#目錄邊界)
- [何時放到哪裡](#何時放到哪裡)
- [repo-local skills 維護流程](#repo-local-skills-維護流程)
- [Conventional Commit 類型選擇](#conventional-commit-類型選擇)
- [文件與 metadata 同步清單](#文件與-metadata-同步清單)
- [驗證清單](#驗證清單)
- [Rationalizations 與 Red Flags](#rationalizations-與-red-flags)

## Overview

這個 skill 專門治理本 repo 內仍然存在的 **project-specific custom skills**。  
`.agents/skills/` 只放本 repo 自己的治理規則、維護政策與客製 workflow。

凡是修改 `.agents/skills/` 的任務，都必須把所有已經變成過期資訊的文件、索引與 metadata 在同一個 change slice 內同步補齊，並在該 slice 可獨立驗證後立刻 commit，不得拖到之後與不相關修改混批。

[返回開頭](#快速導覽)

## 目錄邊界

| 路徑 | 定位 | 應放內容 |
|------|------|----------|
| `.agents/skills/` | project-specific custom skills | 只對本 repo 有效的治理規則、內部 workflow、維護政策 |
| `.claude/skills/` | project skill routers / maintenance skills | Claude Code 專案級 router、sync skill 與共用協議 |
| `anthropic-skills/` | upstream submodule | 上游 skills 原始內容；除同步任務外不直接承擔本 repo 治理規則 |
| `superpowers/` | upstream submodule | 上游 workflow skills 原始內容；除同步任務外不直接承擔本 repo 治理規則 |

- **本 repo 專用規則**，放 `.agents/skills/`。
- **Claude Code 的 router / sync / shared protocol**，放 `.claude/skills/`。
- **上游 skills 內容** 維持在 submodule；不要把本 repo 的治理規則直接塞進 upstream 目錄。

[返回開頭](#快速導覽)

## 何時放到哪裡

- 任務是在規範這個 repo 自己怎麼維護 skills、怎麼 commit、怎麼同步文件 → 放 `.agents/skills/`。
- 任務是在調整 Claude Code 專案級 router、sync 流程或 shared protocol → 放 `.claude/skills/`。
- 若一條規則離開這個 repo 就失去意義，它就應該留在 `.agents/skills/`，而不是 upstream 或其他可分發位置。

[返回開頭](#快速導覽)

## repo-local skills 維護流程

1. **先 search 影響面**：用舊名稱、舊路徑、新名稱、新路徑、主題關鍵字掃整個 repo。
2. **同一個 slice 內修完所有過期資訊**：不要只改 skill 本體，卻把 README、AGENTS、router 或其他索引留到之後。
3. **定義 commit 邊界**：一個 slice 必須是單一目的、可獨立 review、可獨立回滾的變更。
4. **slice 一完成就 commit**：若 worktree 有不相關修改，使用 selective staging 或先 stash；不要把完成的 slice 留著等待大雜燴 commit。
5. **再進下一個主題**：commit 完前，不要切去做不相關的新任務。

### Slice 判斷標準

符合以下三點，就視為一個可提交的完成 slice：

- 變更目的單一，例如「修 frontmatter parse error」或「rename skill」
- 相關文件／metadata 已同步到不再過期
- 用簡單搜尋與 diff 就能驗證沒有遺漏

[返回開頭](#快速導覽)

## Conventional Commit 類型選擇

預設格式：

```text
<type>(<scope>): <summary>
```

建議 scope：

- `agents-skills`：修改 `.agents/skills/` 內部治理 skill
- `claude-skills`：修改 `.claude/skills/` router、sync skill 或 shared protocol
- `docs`：以文件索引與說明為主的同步更新

| 修改內容 | type | 例子 |
|----------|------|------|
| 新增 skill、擴充既有 skill 能力或規則覆蓋面 | `feat` | `feat(agents-skills): add repo review checklist skill` |
| 修正錯誤規則、壞掉的 frontmatter、錯誤路徑、錯誤觸發條件 | `fix` | `fix(agents-skills): repair invalid skill frontmatter` |
| 重新命名、搬移、重組結構，但不改行為語意 | `refactor` | `refactor(agents-skills): rename governance skill sections` |
| 純文件同步、說明澄清、索引補充 | `docs` | `docs(agents-skills): define custom skill boundaries` |
| 純 metadata／維護雜項，沒有行為或文件語意變更 | `chore` | `chore(claude-skills): align router descriptions` |

若同一個 slice 同時碰到多種類型，**以最高影響層級決定 type**：

```text
feat > fix > refactor > docs > chore
```

也就是說，若一個 slice 同時改了 skill 行為與 README，同步文件不會把它降成 `docs` commit。

[返回開頭](#快速導覽)

## 文件與 metadata 同步清單

修改 `.agents/skills/` 或相關治理邊界時，至少檢查以下位置是否因本次變更而過期：

- [`README.md`](../../../README.md)
- [`AGENTS.md`](../../../AGENTS.md)
- [`CLAUDE.md`](../../../CLAUDE.md)（若專案級使用指引受影響）
- `.claude/skills/` 內的 router / sync skill（若入口或引用名稱受影響）
- [`\.gitignore`](../../../.gitignore)、[`scripts/README.md`](../../../scripts/README.md)、migration docs、舊計畫文件（若名稱／路徑變更導致它們過期）

原則不是「每次全改」，而是：**凡是被你這次修改弄成不準確的地方，都要在同一個 slice 內修完。**

[返回開頭](#快速導覽)

## 驗證清單

- 用 `rg` 搜舊名稱／舊路徑，確認沒有殘留過期引用
- 檢查 `git diff --staged`，確認 commit 只包含同一個 slice 的檔案
- 若動到 JSON metadata，先 parse 一次再 commit
- 若動到 `SKILL.md` frontmatter，確認 `name` / `description` 合法且沒有 YAML parse 風險

[返回開頭](#快速導覽)

## Rationalizations 與 Red Flags

### Rationalization Table

| 藉口 | 為什麼不成立 |
|------|--------------|
| `SKILL.md` 才是 source of truth，README / AGENTS 之後再補 | README、AGENTS、router 文件與 repo 指引都是正式 discovery surface；只要被這次變更弄到過期，就必須同步更新 |
| 先把 skill 改完，等所有雜項收尾後再一起 commit | 一個已經完整、可驗證的 slice 就應立刻 commit；拖著只會增加混批與漏改風險 |
| 我之後再決定要用 `feat`、`fix` 還是 `docs` | type 是 slice 邊界的一部分；開始 stage 前就應能說清楚這次在改哪一層 |

### Red Flags

看到以下念頭時，先停下來把 slice 收斂完：

- 「README / AGENTS 晚點再補」
- 「這次只有改 skill 本體，索引文件不用動」
- 「先做下一件事，commit 最後再說」
- 「先全部混在一起，之後再拆 commit」

**以上任一條成立，都表示你還沒完成這個 slice。先同步文件／metadata、確認類型，再 commit。**

[返回開頭](#快速導覽)
