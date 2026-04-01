# aery-skills

> 本地可安裝 plugin：把實戰沉澱下來的 AI skills 收斂成自包含 package，供 GitHub Copilot 與 Claude Code 共用。
>
> **邊界說明**：這個目錄只放可安裝、可共享的 `aery-skills` plugin。repo 專用的內部治理 / custom skills 另放在 [`.agents/skills/skills-governance/SKILL.md`](../.agents/skills/skills-governance/SKILL.md)，不打包進本 plugin。

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
aery-marketplace/            ← self-contained marketplace / plugin root（本文件所在位置）
├── plugin.json              ← GitHub Copilot plugin manifest
├── .claude-plugin/
│   ├── plugin.json          ← Claude Code plugin manifest
│   └── marketplace.json     ← Claude Code local marketplace manifest
├── aery-skills/             ← skill 定義目錄
│   ├── mongo-guidelines/
│   ├── windows-script/
│   └── write-md/
└── README.md                ← 安裝與維護說明
```

[返回開頭](#快速導覽)

---

## 安裝方式

### GitHub Copilot

GitHub Copilot CLI 支援從本地路徑或 GitHub repo subdirectory 直接安裝 plugin。

**本地路徑安裝（開發 / 本機使用）：**

```bash
copilot plugin install ./aery-marketplace
```

**從 GitHub repo subdirectory 安裝（團隊共享）：**

```bash
copilot plugin install OWNER/REPO:aery-marketplace
# 例（本 repo）：copilot plugin install Aery9527/ai-research:aery-marketplace
```

[返回開頭](#快速導覽)

---

### Claude Code

Claude Code 支援從本地路徑新增 marketplace，再透過 marketplace 安裝 plugin。

**Step 1：新增本地 marketplace**

```
/plugin marketplace add ./aery-marketplace
```

> 此指令以 `./aery-marketplace` 作為 marketplace root（即 `.claude-plugin/marketplace.json` 所在目錄），
> 將 `aery-plugins` marketplace 新增到 Claude Code。

**Step 2：安裝 plugin**

```
/plugin install aery-skills@aery-plugins
```

> - `aery-skills`：plugin 名稱（定義於 `.claude-plugin/plugin.json` 的 `name` 欄位）
> - `aery-plugins`：marketplace 名稱（定義於 `.claude-plugin/marketplace.json` 的 `name` 欄位）

**注意**：Claude Code 官方目前不支援 `owner/repo:subdir` 格式的 remote marketplace add。
如需跨機器使用，請 clone 本 repo 後以本地路徑安裝。

[返回開頭](#快速導覽)

---

## 包含 Skills

| Skill | 解決的問題 |
|-------|-----------|
| **mongo-guidelines** | MongoDB 查詢、aggregation pipeline、Go driver、JS shell 型別陷阱 |
| **windows-script** | `.bat`/`.cmd`/`.ps1` 語法陷阱、errorlevel、delayed expansion |
| **write-md** | Markdown 文件撰寫，含 frontmatter 規則、YAML 安全與 Mermaid 圖表決策 |

[返回開頭](#快速導覽)

---

## 驗證

```text
# GitHub Copilot
copilot plugin install ./aery-marketplace
copilot plugin list

# Claude Code
/plugin marketplace add ./aery-marketplace
/plugin install aery-skills@aery-plugins
/plugin list
```

[返回開頭](#快速導覽)
