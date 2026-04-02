# Scripts

> 這裡集中管理 `ai-research` 內的維護腳本文件。之後若新增 `.ps1`、`.cmd`、`.py` 或其他自動化工具，請一律先在這份文件補上索引與使用說明。

---

## 快速導覽

- [用途與維護原則](#用途與維護原則)
- [腳本索引](#腳本索引)
- [腳本詳述](#腳本詳述)
  - [`remove-local-git-user.ps1`](#remove-local-git-userps1)
- [新增腳本時建議補充的欄位](#新增腳本時建議補充的欄位)

---

## 用途與維護原則

`scripts/` 用來放：

- repo 維護輔助工具
- 重複性清理或修正腳本
- 需要在本機或多個 repo/worktree 上批次執行的自動化操作

為了避免腳本散落但沒有文件，這份 `README.md` 應該同時扮演兩個角色：

1. **索引入口**：快速知道目前有哪些腳本。
2. **操作文件**：知道每支腳本會改什麼、怎麼跑、有哪些風險。

---

## 腳本索引

| 腳本 | 類型 | 用途 | 是否修改檔案 | 備註 |
|------|------|------|--------------|------|
| [`remove-local-git-user.ps1`](./remove-local-git-user.ps1) | PowerShell | 遞迴掃描指定路徑下的 Git repository / worktree，移除 local git config 中的 `[user]` section | 會，直接覆寫 Git config | 不建立 backup；遇到異常 config 會跳過 |

---

## 腳本詳述

### `remove-local-git-user.ps1`

#### 目的

批次移除指定根目錄下所有 Git repository（包含一般 repo 與使用 `gitdir:` pointer 的 worktree）之 **local** Git config 裡的 `[user]` section。

這適合用在以下情境：

- 某些 repo 曾被設定過 local `user.name` / `user.email`
- 想回到 global Git identity，避免 local config 覆蓋全域設定
- 需要一次清理多個 repo 或 worktree 的本機 Git 使用者資訊

#### 參數

| 參數 | 型別 | 預設值 | 說明 |
|------|------|--------|------|
| `$RootPath` | `string` | `.` | 掃描起點。腳本會從這個目錄往下遞迴搜尋 `.git` |

#### 它實際在做什麼

1. 將 `$RootPath` 解析成絕對路徑。
2. 以 BFS 方式遞迴掃描子目錄。
3. 對每個找到的 `.git`：
   - 如果 `.git` 是資料夾，視為一般 repo，讀取 `.git/config`
   - 如果 `.git` 是檔案，視為 worktree / gitdir pointer，解析 `gitdir: ...` 後找到真正的 `config`
4. 將重複的 config 路徑去重，避免同一份 config 被重複處理。
5. 逐一讀取 config 原始 bytes，找出 section header。
6. 若存在且只存在一個精確的 `[user]` section，則把該 section 從 header 起點一路刪到下一個 section header 之前。
7. 將更新後的 bytes 直接寫回原 config 檔。
8. 最後輸出摘要：`Updated`、`Unchanged`、`Skipped`。

#### Section 判定規則

這支腳本只會移除 **精確名稱為 `[user]`** 的 section，且比對不分大小寫。

- 會移除：`[user]`
- 不會當成可刪除目標：`[user "foo"]`、`[user.name]`、其他非標準或不同名稱 section

#### 安全性與保守行為

這支腳本偏保守，遇到不確定情況會跳過而不是硬改：

- 找不到任何 Git config：輸出提示並結束
- 找不到 `[user]` section：列為 `Unchanged`
- 同一份 config 出現多個 `[user]` section：列為 `Skipped`
- `.git` pointer 格式不合法：警告並跳過
- 找到 `.git` 但對應 `config` 不存在：警告並跳過
- 某些目錄無法存取：警告並繼續掃描其他目錄

#### 風險與限制

- **會直接覆寫原始 Git config，沒有自動 backup。**
- 腳本是以 bytes 方式移除區段，重點是保留原始檔大部分內容與換行形式，而不是重排整份 INI。
- 若 `[user]` section 前後已有空白行，刪除後可能留下原本結構中的空白，不會額外做格式化清理。
- 若 `RootPath` 本身不存在，因為腳本使用 `Resolve-Path` 並設定 `$ErrorActionPreference = 'Stop'`，會直接拋錯終止。

#### 範例

從目前目錄開始掃描：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\remove-local-git-user.ps1
```

指定某個根目錄掃描：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\remove-local-git-user.ps1 -RootPath "C:\Users\aerylin\IdeaProjects"
```

若想先自行備份再執行，可以先手動備份目標 repo 的 `.git\config` 或 worktree 對應的 `config`。

#### 預期輸出

成功執行時，會看到每份 config 的處理結果。`Write-Warning` 的前綴會跟 PowerShell 語系有關，因此可能是 `WARNING:`、`警告:` 或其他本地化字樣，例如：

```text
Updated: C:\path\to\repo\.git\config
No [user] section: C:\path\to\another\.git\config
警告: Skipped malformed config: multiple [user] sections: C:\path\to\broken\.git\config

Summary
  Updated : 1
  Unchanged: 1
  Skipped : 1
```

---

## 新增腳本時建議補充的欄位

之後 `scripts/` 若加入新工具，建議在本文件至少補這些欄位：

- **目的**：這支腳本解決什麼問題
- **參數**：必要與可選參數、預設值
- **行為**：會掃描哪些路徑、讀哪些檔、改哪些檔
- **安全性**：是否會覆寫檔案、是否有 backup、失敗時怎麼處理
- **範例**：最小可執行指令
- **預期輸出**：讓使用者知道成功/失敗長怎樣
- **限制**：已知不支援的格式或邊界條件

如果之後腳本數量變多，可以把本檔維持為總索引，再將每支腳本拆成獨立文件，例如：

- `scripts/remove-local-git-user.md`
- `scripts/some-future-script.md`

但在拆分之前，仍應保留這份 `scripts/README.md` 作為唯一入口。

