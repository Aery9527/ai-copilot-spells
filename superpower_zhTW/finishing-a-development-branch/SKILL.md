---
name: finishing-a-development-branch
description: 當實作完成、所有測試通過，且需要決定如何整合工作時使用——透過呈現結構化的 merge、PR 或清理選項來引導開發工作的收尾
---

# 完成開發分支

## 概覽

透過呈現清晰選項並處理所選工作流程，引導開發工作的收尾。

**核心原則：** 驗證測試 → 偵測環境 → 呈現選項 → 執行選擇 → 清理。

**開始時宣告：**「我正在使用 finishing-a-development-branch skill 來完成這項工作。」

## 流程

### 步驟一：驗證測試

**在呈現選項之前，先驗證測試是否通過：**

```bash
# Run project's test suite
npm test / cargo test / pytest / go test ./...
```

**若測試失敗：**
```
測試失敗（<N> 個失敗）。完成前必須修正：

[顯示失敗項目]

測試通過前無法繼續執行 merge/PR。
```

停止。不要繼續進行步驟二。

**若測試通過：** 繼續執行步驟二。

### 步驟二：偵測環境

**在呈現選項之前，先確認工作區狀態：**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
```

這決定要顯示哪個選單以及清理方式：

| 狀態 | 選單 | 清理 |
|------|------|------|
| `GIT_DIR == GIT_COMMON`（一般 repo） | 標準 4 個選項 | 無 worktree 需清理 |
| `GIT_DIR != GIT_COMMON`，具名分支 | 標準 4 個選項 | 依來源判斷（見步驟六） |
| `GIT_DIR != GIT_COMMON`，detached HEAD | 精簡 3 個選項（無 merge） | 無需清理（由外部管理） |

### 步驟三：確定基礎分支

```bash
# Try common base branches
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

或詢問：「這個分支從 main 分出——確認正確嗎？」

### 步驟四：呈現選項

**一般 repo 與具名分支 worktree——精確呈現以下 4 個選項：**

```
實作完成。您想要如何處理？

1. 在本地 merge 回 <base-branch>
2. Push 並建立 Pull Request
3. 保持分支現狀（稍後自行處理）
4. 捨棄此工作

請選擇選項？
```

**Detached HEAD——精確呈現以下 3 個選項：**

```
實作完成。您目前在 detached HEAD（由外部管理的工作區）。

1. Push 為新分支並建立 Pull Request
2. 保持現狀（稍後自行處理）
3. 捨棄此工作

請選擇選項？
```

**不要加入說明**——保持選項簡潔。

### 步驟五：執行選擇

#### 選項一：本地 Merge

```bash
# Get main repo root for CWD safety
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

# Merge first — verify success before removing anything
git checkout <base-branch>
git pull
git merge <feature-branch>

# Verify tests on merged result
<test command>

# Only after merge succeeds: cleanup worktree (Step 6), then delete branch
```

接著：清理 worktree（步驟六），然後刪除分支：

```bash
git branch -d <feature-branch>
```

#### 選項二：Push 並建立 PR

```bash
# Push branch
git push -u origin <feature-branch>

# Create PR
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<2-3 bullets of what changed>

## Test Plan
- [ ] <verification steps>
EOF
)"
```

**不要清理 worktree**——使用者需要保留它以便迭代 PR 回饋。

#### 選項三：保持現狀

回報：「保持分支 <name>，worktree 保留於 <path>。」

**不要清理 worktree。**

#### 選項四：捨棄

**先確認：**
```
這將永久刪除：
- 分支 <name>
- 所有 commit：<commit-list>
- 位於 <path> 的 worktree

請輸入 'discard' 確認。
```

等待完整確認字串。

若確認：
```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
```

接著：清理 worktree（步驟六），然後強制刪除分支：
```bash
git branch -D <feature-branch>
```

### 步驟六：清理工作區

**只在選項一與選項四時執行。** 選項二與選項三永遠保留 worktree。

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

**若 `GIT_DIR == GIT_COMMON`：** 一般 repo，無 worktree 需清理。完成。

**若 worktree 路徑位於 `.worktrees/`、`worktrees/` 或 `~/.config/superpowers/worktrees/` 之下：** 由 superpowers 建立的 worktree——由我們負責清理。

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
git worktree remove "$WORKTREE_PATH"
git worktree prune  # Self-healing: clean up any stale registrations
```

**否則：** 此工作區由宿主環境（harness）管理，不要移除。若您的平台提供工作區退出工具，請使用它；否則，保留工作區原狀。

## 快速參考

| 選項 | Merge | Push | 保留 Worktree | 清理分支 |
|------|-------|------|---------------|----------|
| 1. 本地 Merge | 是 | - | - | 是 |
| 2. 建立 PR | - | 是 | 是 | - |
| 3. 保持現狀 | - | - | 是 | - |
| 4. 捨棄 | - | - | - | 是（強制） |

## 常見錯誤

**跳過測試驗證**
- **問題：** merge 損壞的程式碼、建立失敗的 PR
- **修正：** 在提供選項前務必驗證測試

**開放式問題**
- **問題：**「接下來應該做什麼？」語意模糊
- **修正：** 精確呈現 4 個結構化選項（detached HEAD 則為 3 個）

**為選項二清理 worktree**
- **問題：** 移除使用者迭代 PR 所需的 worktree
- **修正：** 只在選項一和選項四時清理

**在移除 worktree 之前刪除分支**
- **問題：** worktree 仍參照該分支，導致 `git branch -d` 失敗
- **修正：** 先 merge，移除 worktree，再刪除分支

**從 worktree 內部執行 git worktree remove**
- **問題：** 當前工作目錄在要移除的 worktree 內時，命令會靜默失敗
- **修正：** 執行 `git worktree remove` 前，務必先 `cd` 到主 repo 根目錄

**清理由 harness 建立的 worktree**
- **問題：** 移除 harness 建立的 worktree 會造成幽靈狀態
- **修正：** 只清理位於 `.worktrees/`、`worktrees/` 或 `~/.config/superpowers/worktrees/` 下的 worktree

**捨棄時未確認**
- **問題：** 意外刪除工作成果
- **修正：** 要求輸入 "discard" 作為確認

## 禁止事項

**絕對不要：**
- 在測試失敗時繼續執行
- 未驗證 merge 結果的測試就執行 merge
- 未經確認就刪除工作成果
- 未經明確要求就 force-push
- 未確認 merge 成功就移除 worktree
- 清理非自己建立的 worktree（須檢查來源）
- 從 worktree 內部執行 `git worktree remove`

**務必：**
- 在提供選項前驗證測試
- 在呈現選單前偵測環境
- 精確呈現 4 個選項（detached HEAD 則為 3 個）
- 為選項四取得輸入確認
- 只在選項一與選項四時清理 worktree
- 移除 worktree 前先 `cd` 到主 repo 根目錄
- 移除後執行 `git worktree prune`
