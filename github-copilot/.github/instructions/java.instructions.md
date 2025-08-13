# common

- 遵守社群習慣的撰寫風格

# test

- 撰寫 test 時請使用 `org.assertj.core.api.Assertions` 套件進行測試驗證
- 盡量使用 `org.mockito.Mockito` 套件進行 mock 測試撰寫, 若是 spring 環境則使用 `@MockBean` 系列

# log

- 一律使用 `org.slf4j.Logger`, 禁止使用 `system.out.println` 等輸出
