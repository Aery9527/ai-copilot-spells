# Codex 工具對應表

Skills 使用 Claude Code 的工具名稱。當你在 skill 中遇到這些名稱時，請使用你的平台對應工具：

| Skill 所引用的名稱 | Codex 對應工具 |
|-------------------|----------------|
| `Task` 工具（派遣子代理） | `spawn_agent`（詳見[子代理派遣需要多代理支援](#子代理派遣需要多代理支援)） |
| 多個 `Task` 呼叫（並行） | 多次 `spawn_agent` 呼叫 |
| Task 回傳結果 | `wait_agent` |
| Task 自動完成 | `close_agent` 以釋放插槽 |
| `TodoWrite`（任務追蹤） | `update_plan` |
| `Skill` 工具（呼叫 skill） | Skills 原生載入——直接遵循指令即可 |
| `Read`、`Write`、`Edit`（檔案操作） | 使用你的原生檔案工具 |
| `Bash`（執行命令） | 使用你的原生 shell 工具 |

## 子代理派遣需要多代理支援

在你的 Codex 設定檔（`~/.codex/config.toml`）中加入以下設定：

```toml
[features]
multi_agent = true
```

這將啟用 `spawn_agent`、`wait_agent` 和 `close_agent`，供 `dispatching-parallel-agents` 和 `subagent-driven-development` 等 skills 使用。

舊版說明：`rust-v0.115.0` 之前的 Codex 版本將已派遣子代理的等待功能暴露為 `wait`。目前的 Codex 對已派遣的子代理使用 `wait_agent`。`wait` 名稱現在屬於 code-mode 的 `exec/wait`，用於透過 `cell_id` 恢復一個已讓出的 exec 儲存格；它不是已派遣子代理的結果工具。

## 環境偵測

需要建立 worktree 或結束分支的 skills，應在繼續之前使用唯讀 git 命令偵測環境：

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

- `GIT_DIR != GIT_COMMON` → 已在一個連結的 worktree 中（跳過建立步驟）
- `BRANCH` 為空 → 處於分離的 HEAD 狀態（無法從沙盒建立分支/推送/PR）

請參閱 `using-git-worktrees` 步驟 0 和 `finishing-a-development-branch` 步驟 1，了解各個 skill 如何使用這些信號。

## Codex App 收尾流程

當沙盒阻止分支/推送操作時（在外部管理的 worktree 中處於分離的 HEAD 狀態），代理提交所有工作並通知使用者使用 App 的原生控制項：

- **「建立分支」**——命名分支，然後透過 App UI 完成提交/推送/PR
- **「移交給本地」**——將工作轉移到使用者的本地 checkout

代理仍可執行測試、暫存檔案，並輸出建議的分支名稱、提交訊息和 PR 描述，供使用者複製使用。
