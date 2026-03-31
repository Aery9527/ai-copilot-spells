# 本地 Skills Plugin 化重構 — 測試設計

## 快速導覽

- [測試總覽](#測試總覽)
- [測試設計](#測試設計)
- [驗收標準](#驗收標準)

## 測試總覽

本文件定義將 [`.agents/skills/`](../.agents/skills) 直接重構為單一 shared plugin root 的測試設計。目標是讓四個既有 skills 改以同一份來源內容，同時服務 Claude Code 與 GitHub Copilot 的 plugin 安裝流程。

測試設計分為三個 Phase：

1. Plugin 結構與 metadata 定義。
2. 技能搬遷與 router / 文件更新。
3. 安裝與發現流程驗證。

每個 Phase 都包含 happy path、主要 error path，以及至少一個邊界或回歸保護案例。

[返回開頭](#快速導覽)

## 測試設計

### Phase 1: Plugin 結構與 metadata 建立

#### Test Case 1-1: `test_plugin_manifest_exposes_shared_skills_directory`

- **場景**：建立新的 shared plugin root 後，root manifest 正確指向共用 `skills/` 目錄。
- **前置條件**：repo 中已建立新的 plugin root 與 `skills/` 目錄骨架。
- **操作**：檢查 GitHub Copilot 的 `plugin.json` 與 Claude Code 對應 metadata 檔是否都引用同一組 skills 路徑。
- **預期結果**：兩套 metadata 都能解析到相同的四個 skills，且沒有引用舊的 `.agents/skills/<skill>` 結構。
- **分類**：happy path

#### Test Case 1-2: `test_plugin_manifest_rejects_missing_skill_entry`

- **場景**：某個 skill 目錄未被納入 manifest 時，驗證流程能及早發現。
- **前置條件**：故意讓其中一個 skill 不出現在 manifest 或 bundle 定義中。
- **操作**：執行 metadata 檢查步驟或安裝前驗證腳本。
- **預期結果**：檢查失敗並明確指出缺漏 skill 名稱，不允許默默通過。
- **分類**：error path

#### Test Case 1-3: `test_plugin_metadata_uses_single_bundle_for_all_skills`

- **場景**：使用者要求四個 skills 打成單一 plugin。
- **前置條件**：plugin metadata 初稿已建立。
- **操作**：檢查 marketplace / install metadata 的 plugin 定義數量與 skills 清單。
- **預期結果**：只存在一個主 plugin bundle，且包含 `mongo`、`plan-extension`、`windows-script`、`write-md` 四項。
- **分類**：邊界條件

### Phase 2: 技能搬遷與 repo 整合更新

#### Test Case 2-1: `test_skill_content_moved_without_frontmatter_loss`

- **場景**：搬遷 skill 目錄後，`SKILL.md` frontmatter 與內容仍完整可讀。
- **前置條件**：四個 skills 已移到新的 shared plugin `skills/` 目錄。
- **操作**：逐一比對搬遷前後的 skill 名稱、description 與正文主段落。
- **預期結果**：frontmatter 關鍵欄位與正文內容保留，僅允許必要的路徑更新。
- **分類**：happy path

#### Test Case 2-2: `test_repo_docs_no_longer_point_to_agents_skills_layout`

- **場景**：重構後仍有文件或 router 指向舊 `.agents/skills/` 路徑時，應被發現。
- **前置條件**：README、AGENTS、router、安裝說明已更新一輪。
- **操作**：搜尋 repo 中舊路徑引用，排除刻意保留的 migration 說明。
- **預期結果**：正式使用說明不再把 `.agents/skills/` 當作安裝或主要結構；若有殘留，測試失敗並列出檔案。
- **分類**：error path

#### Test Case 2-3: `test_plugin_router_docs_describe_claude_and_copilot_flows`

- **場景**：文件必須同時說清楚 Claude Code 與 GitHub Copilot 的安裝方式。
- **前置條件**：README 與相關說明文件已更新。
- **操作**：檢查文件是否各自提供 Claude Code 與 GitHub Copilot 的安裝步驟、命令範例與驗證方式。
- **預期結果**：兩條安裝路徑皆有具體步驟，且說明不混淆 marketplace 與 local / git install。
- **分類**：回歸保護

### Phase 3: 安裝與發現流程驗證

#### Test Case 3-1: `test_claude_code_can_install_plugin_from_local_or_git_source`

- **場景**：Claude Code 能透過選定的 plugin 結構完成安裝。
- **前置條件**：shared plugin root、Claude metadata 與安裝說明已完成。
- **操作**：依文件執行 local path 或 git source 安裝流程，重新載入 plugin / skills 清單。
- **預期結果**：可見單一 plugin，且四個 skills 均可被載入。
- **分類**：happy path

#### Test Case 3-2: `test_github_copilot_can_install_plugin_without_marketplace`

- **場景**：GitHub Copilot 直接以 local path 或 repo 安裝，不依賴 marketplace。
- **前置條件**：root `plugin.json` 與所需資源路徑完整。
- **操作**：依文件執行 `copilot plugin install` 的 local path 或 repo 安裝流程，再列出 plugins / skills。
- **預期結果**：安裝成功，且不需要先註冊 marketplace。
- **分類**：happy path

#### Test Case 3-3: `test_installation_failure_surfaces_missing_metadata_or_invalid_path`

- **場景**：當路徑或 metadata 損壞時，安裝失敗要能被觀測。
- **前置條件**：刻意提供錯誤 source path、缺漏 manifest，或錯誤 skills 路徑。
- **操作**：執行安裝命令並觀察 CLI 輸出。
- **預期結果**：CLI 回報具體錯誤來源，不出現成功假象或模糊錯誤。
- **分類**：error path

## 驗收標準

| # | 驗收項目 | 對應 Phase | 測試方式 | 指令 / 步驟 | 預期結果 |
|---|---------|-----------|---------|------------|---------|
| 1 | 單一 plugin bundle 含四個 skills | Phase 1 | metadata review | 檢查 `plugin.json`、Claude metadata、marketplace 定義 | 只存在一個主 plugin，skills 清單完整 |
| 2 | Skills 內容搬遷後可正常載入 | Phase 2 | file review | 比對 `SKILL.md` frontmatter 與內容 | skill 名稱、description、正文保留 |
| 3 | Repo 正式文件全面改用新結構 | Phase 2 | repo search | 以 `rg` 搜尋 `.agents\\skills` 舊引用 | 正式說明不再把舊結構當主要路徑 |
| 4 | Claude Code 安裝流程可用 | Phase 3 | manual / CLI validation | 依文件執行 Claude Code plugin install 與 plugin/skills list | 安裝成功並可看到四個 skills |
| 5 | GitHub Copilot 安裝流程可用 | Phase 3 | manual / CLI validation | 依文件執行 `copilot plugin install` 與 plugin list | 安裝成功，無需 marketplace |
| 6 | 缺漏 metadata 時能明確失敗 | Phase 1, 3 | negative test | 故意破壞 manifest 或路徑再安裝 | CLI 或驗證腳本給出具體錯誤訊息 |

[返回開頭](#快速導覽)
