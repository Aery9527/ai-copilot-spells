# GitHub Copilot CLI

---

## CLI 參數總覽

| cmd                                                | example                                    | descript                          | scope / risk | notes                   |
|----------------------------------------------------|--------------------------------------------|-----------------------------------| ------------ | ----------------------- |
| `copilot`                                          | `copilot`                                  | 啟動互動式對話模式（預設通用 agent）             | 低            | 適合探索、討論、理解問題            |
| `-p`, `--prompt`                                   | `copilot -p "Summarize this repo"`         | 單次執行 prompt, 不進互動模式               | 中            | 只接受 **string**, 不可直接指定檔案 |
| `-p (Get-Content FILE)` | `copilot -p (Get-Content prompt.txt)` | 同上                                | 中            |  引用 file 內容當作 prompt|
| `--agent`                                          | `copilot --agent=refactor-agent`           | 指定使用特定 agent（角色/行為模型）             | 低            | 建議用於重構、修 bug 等明確任務      |
| `--allow-all-tools`                                | `copilot --allow-all-tools`                | 允許使用所有 tools（shell/write/git/MCP） | **高**        | 生產環境極不建議                |
| `--allow-tool`                                     | `copilot --allow-tool write`               | 僅允許指定 tool                        | 低            | 建議搭配 `--agent` 使用       |
| `--deny-tool`                                      | `copilot --deny-tool 'shell(rm)'`          | 明確禁止特定 tool                       | 低            | 優先權最高, 可當 safety guard   |
| `--resume`                                         | `copilot --resume`                         | 從清單選擇既有 session 繼續                | 低            | 適合長任務                   |
| `--continue`                                       | `copilot --continue`                       | 快速續接最近一次 session                  | 低            | 不顯示清單                   |
| `copilot agents`                                   | `copilot agents`                           | 列出本機可用 agent                      | 低            | Preview 階段, 清單可能變動       |
| `copilot help`                                     | `copilot help permissions`                 | 查詢 CLI 指令與子指令說明                   | 低            | 以本機版本為準                 |

- prompt 應視為 **程式碼** / **規格文件**, 工程化後 copilot 行為才可預期
- 多檔案組合 prompt, 應拆分結構

```text
copilot/
├─ agents/        # 行為與規則
│  └─ refactor.rules.md
├─ context/       # 專案背景 / 限制
│  └─ payment.context.md
├─ tasks/         # 單一任務描述
│  └─ refactor_payment.task.md
└─ run.sh
```

---

## 補充說明（重要行為規則）

* Copilot **不會在正常模式下自動切換 agent**, 除非你明確指定 `--agent`
* Prompt 過長可能被自動摘要或忽略後段, 建議結構化（Rules / Context / Task）
* `--allow-all-tools` 屬高風險參數, 實務上應搭配 `--deny-tool` 使用
* Agent 的核心價值在於 **鎖定行為風格與 scope**, 不是讓 Copilot 變聰明
* 若任務已明確（重構 / 修 bug / 補測試）, 應優先使用 `--agent`
* Prompt 與 agent 設定可視為「可版控的工程資產」, 適合納入 repo 管理

---

## 如何使用

- 安裝與更新 `npm install -g @github/copilot@latest`
