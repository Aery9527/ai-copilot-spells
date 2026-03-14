# ai-copilot-spells

記錄我使用 AI 輔助開發時的一些常用設定與魔法小語~

- gemini: gemini 啟動時會在當前目錄讀取 GEMINI.md, 以及家目錄的 .gemini 目錄下的 GEMINI.md
- github-copilot: .github 目錄結構即是擺放位置

---

## 目錄結構說明

| 目錄 | 說明 |
|------|------|
| `anthropic-skills/` | Anthropic 官方 skill 定義（上游 repo） |
| `.claude/skills/` | 針對 `anthropic-skills` 的**進階解說版**，協助 AI 在使用者詢問功能時，從中組合可使用的 skill |
| `.agents/skills/` | **個人自製 skills**，工作上實際遇到的問題與踩坑經驗沉澱而成，與 anthropic-skills 無關 |
| `AGENT.md` | 全部 skills 的導覽索引 |

### `.agents/` — 個人自製 Skills

這些 skill 是在工作中遇到具體問題後自行撰寫，記錄常見陷阱、守則與實戰決策邏輯：

- **mongo** — MongoDB 查詢/aggregation/Go driver/JS shell 陷阱防範
- **windows-script** — .bat/.cmd/.ps1 語法陷阱、errorlevel、delayed expansion、PowerShell 錯誤處理
- **write-md** — Markdown 文件撰寫，含 Mermaid 圖表決策規則

### `.claude/` — Anthropic Skills 進階解說

`.claude/skills/` 內的每個 SKILL.md 是對應 `anthropic-skills` 的精華摘要。  
當使用者描述功能需求時，AI 可快速判斷各 skill 能力邊界，決定單 skill 或組合方案。  
完整 skills 導覽見 [`AGENTS.md`](AGENTS.md)。
