# comment

- struct 明確實作某個介面時, 在 struct 宣告上方寫 `var _ InterfaceName = (*StructName)(nil)` 明確標記該 struct 實作了某個介面
- 使用 `any` 而非 `interface{}` 來表示任意類型

# test

- 撰寫 test 時請使用 `github.com/stretchr/testify/assert` 進行驗證

# error

- 在此專案內回傳錯誤時使用 `xxx` 裡的 `xxx` 介面
- 新建 error 使用 `xxx` 或 `xxx` 等方法
- 包裝其他回傳 error 時使用 `xxx` 或 `xxx` 方法

# log

- 一律使用 `xxx` 裡的 `xxx.Debug()`, `xxx.Info()`, `xxx.Warn()`, `xxx.Error()` 等系列方法進行 log
- 除了 `_test` 使用 `testing.T` 紀錄 log之外, 專案程式功能都必須使用 `xxx` 進行 log, 嚴禁在使用 `fmt` 方法進行 log
- `xxx` 可以算是一層 `slog` 的封裝, 不過 args 部分可以直接使用 key-value pair 的方式傳入
- 若有 `error` 需要寫 log, 則使用 `xxx.ErrorWith(err, msg, arg...)` 方法
