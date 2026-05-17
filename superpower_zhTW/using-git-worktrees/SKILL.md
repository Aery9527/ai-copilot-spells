---
name: using-git-worktrees
description: 在開始需要隔離當前工作區的功能開發時，或在執行實作計畫之前使用——透過原生工具或 git worktree 備用方案確保存在隔離的工作區
---

# 使用 Git Worktrees

## 概觀

確保工作在隔離的工作區中進行。優先使用平台的原生 worktree 工具。只有在沒有原生工具可用時，才退而使用手動 git worktrees。

**核心原則：** 首先偵測現有的隔離狀態，再使用原生工具，最後才退回 git。永遠不要對抗 harness。

**開始時宣告：**「我正在使用 using-git-worktrees skill 來建立隔離的工作區。」

## 步驟 0：偵測現有隔離狀態

**在建立任何東西之前，先確認你是否已經在隔離的工作區中。**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**Submodule 防護：** `GIT_DIR != GIT_COMMON` 在 git submodule 內部同樣成立。在得出「已在 worktree 中」的結論之前，請確認你不是在 submodule 中：

```bash
# 若此命令回傳路徑，表示你在 submodule 中，而非 worktree——視為一般 repo 處理
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**若 `GIT_DIR != GIT_COMMON`（且非 submodule）：** 你已在 linked worktree 中。跳至步驟 3（專案設定）。不要再建立另一個 worktree。

回報目前分支狀態：
- 在某個分支上：「已在 `<path>` 的隔離工作區中，分支為 `<name>`。」
- Detached HEAD：「已在 `<path>` 的隔離工作區中（detached HEAD，由外部管理）。需在完成時建立分支。」

**若 `GIT_DIR == GIT_COMMON`（或在 submodule 中）：** 你在一般的 repo checkout 中。

使用者是否已在指示中說明其 worktree 偏好？若無，在建立 worktree 前需徵得同意：

> 「您是否希望我建立隔離的 worktree？這能保護您目前的分支不受變更影響。」

若使用者已宣告偏好，直接採用而不再詢問。若使用者拒絕同意，就地工作並跳至步驟 3。

## 步驟 1：建立隔離工作區

**你有兩種機制，依序嘗試。**

### 1a. 原生 Worktree 工具（優先）

使用者已要求建立隔離工作區（步驟 0 同意）。你是否已有建立 worktree 的方式？這可能是名為 `EnterWorktree`、`WorktreeCreate` 的工具，或 `/worktree` command，或 `--worktree` flag。若有，使用它並跳至步驟 3。

原生工具會自動處理目錄放置、分支建立和清理。當你擁有原生工具時使用 `git worktree add`，會產生 harness 無法看見或管理的幽靈狀態。

只有在沒有原生 worktree 工具可用時，才繼續進行步驟 1b。

### 1b. Git Worktree 備用方案

**僅在步驟 1a 不適用時使用**——即沒有原生 worktree 工具可用。使用 git 手動建立 worktree。

#### 目錄選擇

依照以下優先順序進行。使用者的明確偏好永遠優先於觀察到的檔案系統狀態。

1. **檢查指示中是否有宣告的 worktree 目錄偏好。** 若使用者已指定，直接使用而不再詢問。

2. **檢查是否有既有的專案本地 worktree 目錄：**
   ```bash
   ls -d .worktrees 2>/dev/null     # 優先（隱藏）
   ls -d worktrees 2>/dev/null      # 備用
   ```
   若找到，使用它。若兩者都存在，`.worktrees` 優先。

3. **檢查是否有既有的全域目錄：**
   ```bash
   project=$(basename "$(git rev-parse --show-toplevel)")
   ls -d ~/.config/superpowers/worktrees/$project 2>/dev/null
   ```
   若找到，使用它（與舊有全域路徑的向後相容性）。

4. **若沒有其他指引可用**，預設使用專案根目錄下的 `.worktrees/`。

#### 安全驗證（僅適用於專案本地目錄）

**建立 worktree 前必須確認目錄已被忽略：**

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**若未被忽略：** 加入 .gitignore，提交該變更，然後繼續。

**為何關鍵：** 防止意外將 worktree 內容提交至 repository。

全域目錄（`~/.config/superpowers/worktrees/`）不需要驗證。

#### 建立 Worktree

```bash
project=$(basename "$(git rev-parse --show-toplevel)")

# 根據選定位置決定路徑
# 專案本地：path="$LOCATION/$BRANCH_NAME"
# 全域：path="~/.config/superpowers/worktrees/$project/$BRANCH_NAME"

git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

**沙盒備用方案：** 若 `git worktree add` 因權限錯誤（沙盒拒絕）而失敗，告知使用者沙盒阻止了 worktree 建立，將改在當前目錄工作。然後就地執行設定和基線測試。

## 步驟 3：專案設定

自動偵測並執行適當的設定：

```bash
# Node.js
if [ -f package.json ]; then npm install; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

## 步驟 4：驗證乾淨基線

執行測試以確保工作區從乾淨狀態開始：

```bash
# 使用適合專案的命令
npm test / cargo test / pytest / go test ./...
```

**若測試失敗：** 回報失敗情況，詢問是否繼續或進行調查。

**若測試通過：** 回報已就緒。

### 回報

```
Worktree ready at <full-path>
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## 快速參考

| 情況 | 行動 |
|------|------|
| 已在 linked worktree 中 | 跳過建立（步驟 0） |
| 在 submodule 中 | 視為一般 repo（步驟 0 防護） |
| 原生 worktree 工具可用 | 使用它（步驟 1a） |
| 無原生工具 | Git worktree 備用方案（步驟 1b） |
| `.worktrees/` 已存在 | 使用它（確認已忽略） |
| `worktrees/` 已存在 | 使用它（確認已忽略） |
| 兩者都存在 | 使用 `.worktrees/` |
| 兩者都不存在 | 檢查指示檔，然後預設 `.worktrees/` |
| 全域路徑已存在 | 使用它（向後相容） |
| 目錄未被忽略 | 加入 .gitignore 並提交 |
| 建立時發生權限錯誤 | 沙盒備用方案，就地工作 |
| 基線測試失敗 | 回報失敗並詢問 |
| 無 package.json/Cargo.toml | 跳過相依套件安裝 |

## 常見錯誤

### 對抗 harness

- **問題：** 平台已提供隔離時仍使用 `git worktree add`
- **修正：** 步驟 0 偵測現有隔離狀態。步驟 1a 讓原生工具接管。

### 跳過偵測

- **問題：** 在現有 worktree 內再建立巢狀 worktree
- **修正：** 在建立任何東西之前，永遠先執行步驟 0

### 跳過忽略驗證

- **問題：** Worktree 內容被追蹤，污染 git status
- **修正：** 在建立專案本地 worktree 前，永遠使用 `git check-ignore`

### 假設目錄位置

- **問題：** 造成不一致，違反專案慣例
- **修正：** 依照優先順序：現有 > 全域舊路徑 > 指示檔 > 預設值

### 在測試失敗時繼續進行

- **問題：** 無法區分新的 bug 與既有問題
- **修正：** 回報失敗，取得明確許可後再繼續

## 紅色警示

**絕對不要：**
- 當步驟 0 偵測到現有隔離時建立 worktree
- 當你擁有原生 worktree 工具（例如 `EnterWorktree`）時使用 `git worktree add`。這是最常見的錯誤——如果你有它，就使用它。
- 跳過步驟 1a 直接執行步驟 1b 的 git 命令
- 未確認已忽略就建立 worktree（專案本地）
- 跳過基線測試驗證
- 未詢問就在測試失敗時繼續

**務必：**
- 先執行步驟 0 偵測
- 優先使用原生工具而非 git 備用方案
- 遵循目錄優先順序：現有 > 全域舊路徑 > 指示檔 > 預設值
- 確認目錄已被忽略（專案本地）
- 自動偵測並執行專案設定
- 驗證乾淨的測試基線
