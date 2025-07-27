## test

- 撰寫 test 時請使用 `github.com/stretchr/testify/assert` 進行驗證

## error

- 在此專案內回傳錯誤時使用 `nimoplay.local/game-go-common/pkg/gerror` 裡的 `gerror.Error` 介面
- 新建 error 使用 `gerror.New()` 或 `gerror.Newf()` 等方法
- 包裝其他回傳 error 時使用 `gerror.Wrap()` 或 `gerror.Wrapf()` 方法

## log

- 一律使用 `nimoplay.local/game-go-common/pkg/glog` 裡的 `glog.Debug()`, `glog.Info()`, `glog.Warn()`, `glog.Error()` 等系列方法進行 log
- 除了 `_test` 使用 `testing.T` 紀錄 log之外, 專案程式功能都必須使用 `glog` 進行 log, 嚴禁在使用 `fmt` 方法進行 log
- `glog` 可以算是一層 `slog` 的封裝, 不過 args 部分可以直接使用 key-value pair 的方式傳入
- 若有 `error` 需要寫 log, 則使用使用 `glog.ErrorWith()` 方法

---

## project
