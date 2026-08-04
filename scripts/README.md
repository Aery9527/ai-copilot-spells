# Scripts

> 這裡集中管理 `ai-research` 內的維護腳本文件。之後若新增 `.ps1`、`.cmd`、`.py` 或其他自動化工具，請一律先在這份文件補上索引與使用說明。

```mermaid
flowchart LR
    A["新增或修改腳本"] --> B["更新 scripts/README.md 索引"]
    B --> C["確認用途、參數、風險、範例"]
    C --> D["再執行或分享腳本"]
```

---

## Quick Navigation

- [用途與維護原則](#用途與維護原則)
- [腳本索引](#腳本索引)
- [腳本詳述](#腳本詳述)
  - [Link Agent Skills](#link-agent-skills)
  - [Install All](#install-all)
  - [`remove-local-git-user.ps1`](#remove-local-git-userps1)
- [新增腳本時建議補充的欄位](#新增腳本時建議補充的欄位)

[Back to top](#quick-navigation)

---

## 用途與維護原則

`scripts/` 用來放：

- repo 維護輔助工具
- 重複性清理或修正腳本
- 需要在本機或多個 repo/worktree 上批次執行的自動化操作

為了避免腳本散落但沒有文件，這份 `README.md` 應該同時扮演兩個角色：

1. **索引入口**：快速知道目前有哪些腳本。
2. **操作文件**：知道每支腳本會改什麼、怎麼跑、有哪些風險。

[Back to top](#quick-navigation)

---

## 腳本索引

| 腳本 | 類型 | 用途 | 是否修改檔案 | 備註 |
|------|------|------|--------------|------|
| [`link-agent-skills.ps1`](./link-agent-skills.ps1) | PowerShell | 互動式建立或移除 `.agents/skills` 到 `.claude/skills` 的 Windows junction | 會，建立/移除 `.agents/skills` 並更新 [`.gitignore`](../.gitignore) | Mode 1 會先移除既有 `.agents/skills`；適合 Windows |
| [`link-agent-skills.sh`](./link-agent-skills.sh) | Bash | 互動式建立或移除 `.agents/skills` 到 `.claude/skills` 的 Unix symlink | 會，建立/移除 `.agents/skills` 並更新 [`.gitignore`](../.gitignore) | Mode 1 會先移除既有 `.agents/skills`；適合 macOS / Linux / Git Bash |
| [`install-all.ps1`](./install-all.ps1) | PowerShell | 互動式選單，依選擇呼叫 [`install-cc.ps1`](../cli-agents/claude-code/install-cc.ps1)、[`install-cx.ps1`](../cli-agents/codex/install-cx.ps1)、[`tool/PowerShell/install.ps1`](../tool/PowerShell/install.ps1) | 不直接修改檔案，但會觸發被呼叫腳本對使用者家目錄的修改 | 任一項失敗即中斷，不繼續安裝其餘項目；檔案含中文字，需要 UTF-8 BOM 才能被 PowerShell 5.1 正確解析 |
| [`install-all.sh`](./install-all.sh) | Bash | `install-all.ps1` 的 macOS/Linux 對應版本，只呼叫 [`install-cc.sh`](../cli-agents/claude-code/install-cc.sh) 與 [`install-cx.sh`](../cli-agents/codex/install-cx.sh) | 不直接修改檔案，但會觸發被呼叫腳本對使用者家目錄的修改 | 選項 3（PowerShell 腳本）在這個版本僅顯示略過訊息，不執行任何動作；任一項失敗即中斷 |
| [`remove-local-git-user.ps1`](./remove-local-git-user.ps1) | PowerShell | 遞迴掃描指定路徑下的 Git repository / worktree，移除 local git config 中的 `[user]` section | 會，直接覆寫 Git config | 不建立 backup；遇到異常 config 會跳過 |

[Back to top](#quick-navigation)

---

## 腳本詳述

### Link Agent Skills

#### 目的

[`link-agent-skills.ps1`](./link-agent-skills.ps1) 與 [`link-agent-skills.sh`](./link-agent-skills.sh) 用來把 repo 內的 [`.claude/skills/`](../.claude/skills/) 暴露成 `.agents/skills`，方便需要 native `.agents/skills` discovery 的工具讀到同一批 project skills。

兩個版本功能相同：

- PowerShell 版使用 Windows junction。
- Bash 版使用 symbolic link。

#### 參數

兩支腳本都沒有命令列參數，執行後以互動式選單選擇模式。

| 選項 | 行為 |
|------|------|
| `0` | 取消，不做任何修改 |
| `1` | 將整個 `.agents/skills` 連到 `.claude/skills` |
| `2` | 在 `.agents/skills` 下逐一建立每個 skill 的 link |
| `3` | 移除已建立的 link，並清理對應 [`.gitignore`](../.gitignore) 條目 |

#### 它實際在做什麼

1. 以腳本所在位置推算 repo 根目錄。
2. 將 [`.claude/skills/`](../.claude/skills/) 視為真實來源目錄。
3. 依選單模式建立 `.agents/skills` 到 [`.claude/skills/`](../.claude/skills/) 的單一 link，或逐一建立每個 skill 子目錄的 link。
4. 將 `.agents/skills` 或 `.agents/skills/<skill-name>` 加入 [`.gitignore`](../.gitignore)，避免 link 被提交。
5. 取消連結時，移除已建立的 link 與對應 [`.gitignore`](../.gitignore) 條目。

#### 風險與限制

- **Mode 1 會先移除既有 `.agents/skills`。** 如果該路徑不是本工具建立的 link，執行前應先確認沒有重要內容。
- 兩支腳本都會修改 [`.gitignore`](../.gitignore)，新增或移除 `.agents/skills` 相關條目。
- PowerShell 版依賴 Windows junction；Bash 版依賴 symlink。
- Mode 1 需要 `.agents` 父目錄存在；若不存在，請先建立 `.agents`，或改用 Mode 2 讓腳本建立 `.agents/skills` 目錄。
- 如果 [`.claude/skills/`](../.claude/skills/) 不存在，腳本會停止並提示錯誤。

#### 範例

Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\link-agent-skills.ps1
```

Bash：

```bash
bash ./scripts/link-agent-skills.sh
```

#### 預期輸出

```text
==========================================
   Agent Skills Linker
==========================================

  [0] 取消
  [1] 將整個 .agents/skills 連結至 .claude/skills
  [2] 逐一將 .claude/skills 底下的每個 skill 連結至 .agents/skills
  [3] 取消連結

[OK] 完成
```

---

### Install All

#### 目的

[`install-all.ps1`](./install-all.ps1) 與 [`install-all.sh`](./install-all.sh) 是一鍵安裝的選單入口，讓使用者不用分別記住並手動執行 [`install-cc.ps1`/`.sh`](../cli-agents/claude-code/)、[`install-cx.ps1`/`.sh`](../cli-agents/codex/)、[`tool/PowerShell/install.ps1`](../tool/PowerShell/install.ps1) 這幾支各自獨立的安裝腳本。

兩個版本功能相同，差異在於平台限制：

- PowerShell 版三個選項都能執行。
- Bash 版只有選項 1、2 真的會執行；選項 3（PowerShell 腳本）在 macOS/Linux 上不適用，選到時只會印出略過訊息，不做任何動作。

#### 參數

兩支腳本都沒有命令列參數，執行後以互動輸入決定要安裝哪些項目。

| 輸入 | 行為 |
|------|------|
| 留空 或 `0` | 全部安裝（依固定順序 1 → 2 → 3） |
| `1` | 只安裝 Claude Code CLI（呼叫 [`install-cc.ps1`/`.sh`](../cli-agents/claude-code/)） |
| `2` | 只安裝 Codex CLI（呼叫 [`install-cx.ps1`/`.sh`](../cli-agents/codex/)） |
| `3` | 只安裝 PowerShell 腳本（呼叫 [`tool/PowerShell/install.ps1`](../tool/PowerShell/install.ps1)；Bash 版僅顯示略過訊息） |
| 逗號分隔多選，例如 `1,3` | 安裝多項，執行順序固定為 1 → 2 → 3，與輸入順序無關 |
| 無效編號（例如 `5`、`abc`） | 顯示錯誤並以非零狀態結束，不執行任何項目 |

#### 它實際在做什麼

1. 顯示選單與說明文字。
2. 讀取使用者輸入，解析成一組要安裝的項目（預設全選）。
3. 依固定順序 1 → 2 → 3 呼叫對應的子腳本。
4. 每個子腳本執行後都會檢查其結束代碼；只要有一項失敗，立即停止，不繼續安裝其餘項目。

#### 風險與限制

- **任一項失敗就中斷**，不會嘗試繼續安裝清單中的其餘項目；這是刻意設計（子腳本彼此仍是各自獨立、有系統層級副作用的安裝流程，中斷後可以修好問題再單獨重跑失敗的那一項）。
- 子腳本本身的風險（呼叫 winget/Homebrew 安裝或更新 Node.js、`npm install -g` 安裝 CLI 等）請參考 [`cc-cli.md`](../cli-agents/claude-code/cc-cli.md)、[`cx-cli.md`](../cli-agents/codex/cx-cli.md) 與 `README.md` 的「一鍵安裝腳本」章節。
- `install-all.ps1` 含有中文選單文字，檔案必須保留 UTF-8 BOM 才能被 Windows PowerShell 5.1 正確解析；`install-all.sh` 則相反，開頭不可以有 BOM（會破壞 `#!/usr/bin/env bash` shebang 辨識）。

#### 範例

Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-all.ps1
```

Bash：

```bash
bash ./scripts/install-all.sh
```

#### 預期輸出

```text
==========================================
   Install All
==========================================

  [1] Claude Code CLI (install-cc)
  [2] Codex CLI (install-cx)
  [3] PowerShell 腳本 (install.ps1)

  [0] 全部安裝（預設）

==========================================
請輸入要安裝的項目編號，可用逗號分隔多選（例如 1,3；留空或輸入 0 = 全部安裝）:

=== [1] Claude Code CLI (install-cc) ===
...

=== [2] Codex CLI (install-cx) ===
...

=== [3] PowerShell 腳本 (install.ps1) ===
...

[OK] 全部完成
```

若中途有項目失敗，會改為顯示 `[X] ERROR: ... 失敗 (exit N)` 並直接以非零狀態結束，不會出現 `[OK] 全部完成`。

---

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

[Back to top](#quick-navigation)

