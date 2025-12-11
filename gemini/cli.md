# Gemini CLI

- 安裝與更新 `npm install -g @google/gemini-cli@latest`
- API key
    - macOS / Linux `export GEMINI_API_KEY="你的_API_KEY"`
    - Windows `setx GEMINI_API_KEY "你的_API_KEY"`

---

## CLI 參數總覽

| cmd                          | example                                  | descript              | mode / scope       | note                            |
|------------------------------| ---------------------------------------- |-----------------------| ------------------ | ------------------------------- |
| `-p`, `--prompt`             | `gemini -p "Hello"`                      | 指定單次 prompt，執行後即結束    | non-interactive    | 只接受字串，不可直接給檔案路徑                 |
| `-p (Get-Content FILE)`      | `gemini -p (Get-Content prompt.txt)`                      | 同上                    | non-interactive    | 引用 file 內容當作 prompt |
| `-i`, `--prompt-interactive` | `gemini -i "Analyze repo"`               | 指定第一句 prompt，然後進入互動模式 | interactive        | 適合用 prompt 作為開場                |
| `-i (Get-Content FILE)` | `gemini -i "Analyze repo"`               | 同上   | interactive        | 引用 file 內容當作 prompt 作為開場                |
| `--model`, `-m`              | `gemini -m gemini-2.0-pro`               | 指定使用的 Gemini model    | session            | 僅影響本次執行                         |
| `--extensions`               | `gemini --extensions filesystem,git`     | 限制可用的內建工具能力           | capability control | 非安裝插件，而是白名單化                    |
| `--extensions none`          | `gemini --extensions none`               | 關閉所有工具能力              | capability control | 公司/資安常用                         |
| `--list-extensions`          | `gemini --list-extensions`               | 列出額外安裝的 extensions    | info               | 目前通常為空（屬預留機制）                   |
| `--sandbox`, `-s`            | `gemini --sandbox`                       | 啟用受控執行環境              | security           | 限制 filesystem / shell / network |
| `--sandbox-image`            | `gemini --sandbox-image <uri>`           | 指定 sandbox 執行 image   | security           | 用於固定 toolchain / OS             |
| `-y`, `--yolo`               | `gemini -y`                              | 自動核准所有 tool calls     | approval           | 高風險，勿在公司環境使用                    |
| `--all-files`, `-a`          | `gemini -a`                              | 遞迴加入目前目錄檔案作為 context  | context            | 可能造成 context 膨脹                 |
| `--include-directories`      | `gemini --include-directories ../lib`    | 加入額外目錄到 workspace     | context            | 最多可指定多個目錄                       |
| `--debug`, `-d`              | `gemini --debug`                         | 啟用 debug 輸出           | debug              | 會顯示啟動與內部流程                      |
| `--show-memory-usage`        | `gemini --show-memory-usage`             | 顯示記憶體使用狀況             | debug              | 用於效能觀察                          |
| `--telemetry`                | `gemini --telemetry`                     | 啟用 telemetry（觀測資料）    | observability      | 企業環境常需審核                        |
| `--telemetry-target`         | `gemini --telemetry-target local`        | 指定 telemetry 送出目標     | observability      | 可接內部系統                          |
| `--telemetry-otlp-endpoint`  | `gemini --telemetry-otlp-endpoint <url>` | 指定 OTLP endpoint      | observability      | 使用 OpenTelemetry 標準             |
| `--telemetry-log-prompts`    | `gemini --telemetry-log-prompts`         | 允許記錄 prompt 內容        | observability      | 高敏感設定                           |
| `--version`                  | `gemini --version`                       | 顯示版本                  | info               | 方便問題回報                          |
| `-h`, `--help`               | `gemini --help`                          | 顯示所有參數說明              | info               | 以實際版本為準                         |

---

## 補充說明（重要行為規則）

* Extensions 為 **內建能力的存取控制**，不是可安裝插件
* `--list-extensions` 目前為預留機制，顯示空白屬正常行為
* Sandbox 與 Extensions、YOLO 為一組安全模型，需一併考量
* Telemetry 主要用於企業治理、稽核與成本控管
* CLI 升版即同時升版內建能力，無 extension 版本地獄
