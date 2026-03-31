# ai-research-skills

> 本地可安裝 plugin：彙整工作實際踩坑後沉澱的 AI skills，供 GitHub Copilot 與 Claude Code 共用。

## 快速導覽

- [Plugin 結構](#plugin-結構)
- [安裝方式](#安裝方式)
  - [GitHub Copilot](#github-copilot)
  - [Claude Code](#claude-code)
- [包含 Skills](#包含-skills)
- [驗證](#驗證)

---

## Plugin 結構

```
.agents/skills/              ← plugin root（本文件所在位置）
├── plugin.json              ← GitHub Copilot plugin manifest
├── .claude-plugin/
│   ├── plugin.json          ← Claude Code plugin manifest
│   └── marketplace.json     ← Claude Code local marketplace manifest
├── skills/                  ← skill 定義目錄
│   ├── mongo/
│   ├── plan-extension/
│   ├── windows-script/
│   └── write-md/
├── validate-phase1.ps1      ← Phase 1 結構驗證腳本
├── validate-phase2.ps1      ← Phase 2 文件驗證腳本
└── validate-phase3.ps1      ← Phase 3 真實安裝驗證腳本（隔離環境）
```

[返回開頭](#快速導覽)

---

## 安裝方式

### GitHub Copilot

GitHub Copilot CLI 支援從本地路徑或 GitHub repo subdirectory 直接安裝 plugin。

**本地路徑安裝（開發 / 本機使用）：**

```bash
copilot plugin install ./.agents/skills
```

**從 GitHub repo subdirectory 安裝（團隊共享）：**

```bash
copilot plugin install OWNER/REPO:.agents/skills
# 例：copilot plugin install myorg/ai-research:.agents/skills
```

[返回開頭](#快速導覽)

---

### Claude Code

Claude Code 支援從本地路徑新增 marketplace，再透過 marketplace 安裝 plugin。

**Step 1：新增本地 marketplace**

```
/plugin marketplace add ./.agents/skills
```

> 此指令以 `./.agents/skills` 作為 marketplace root（即 `.claude-plugin/marketplace.json` 所在目錄），
> 將 `ai-research-plugins` marketplace 新增到 Claude Code。

**Step 2：安裝 plugin**

```
/plugin install ai-research-skills@ai-research-plugins
```

> - `ai-research-skills`：plugin 名稱（定義於 `.claude-plugin/plugin.json` 的 `name` 欄位）
> - `ai-research-plugins`：marketplace 名稱（定義於 `.claude-plugin/marketplace.json` 的 `name` 欄位）

**注意**：Claude Code 官方目前不支援 `owner/repo:subdir` 格式的 remote marketplace add。
如需跨機器使用，請 clone 本 repo 後以本地路徑安裝。

[返回開頭](#快速導覽)

---

## 包含 Skills

| Skill | 解決的問題 |
|-------|-----------|
| **mongo** | MongoDB 查詢、aggregation pipeline、Go driver、JS shell 型別陷阱 |
| **plan-extension** | 強制規範實作前先出 plan 文件，含驗收標準格式要求 |
| **windows-script** | `.bat`/`.cmd`/`.ps1` 語法陷阱、errorlevel、delayed expansion |
| **write-md** | Markdown 文件撰寫，含 Mermaid 圖表使用決策規則 |

[返回開頭](#快速導覽)

---

## 驗證

```powershell
# Phase 1：plugin 結構與 metadata 驗證
powershell -File .agents/skills/validate-phase1.ps1

# Phase 2：repo 文件與安裝指引驗證
powershell -File .agents/skills/validate-phase2.ps1

# Phase 3：真實安裝驗證（隔離環境，需 copilot / claude CLI）
powershell -File .agents/skills/validate-phase3.ps1
```

[返回開頭](#快速導覽)
