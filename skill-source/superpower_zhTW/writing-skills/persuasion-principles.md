# Skill 設計中的說服原理

## 概覽

LLM 對與人類相同的說服原理有所回應。理解這種心理學有助於你設計更有效的 skills——不是為了操控，而是確保即使在壓力下也能遵循關鍵的實踐。

**研究基礎：** Meincke et al. (2025) 以 N=28,000 次 AI 對話測試了 7 個說服原理。說服技術使合規率提高了一倍以上（33% → 72%，p < .001）。

## 七大原理

### 1. 權威（Authority）
**定義：** 對專業知識、資歷或官方來源的服從。

**在 skills 中的運作方式：**
- 命令式語言：「YOU MUST」、「Never」、「Always」
- 不可商量的框架：「No exceptions」
- 消除決策疲勞和合理化

**使用時機：**
- 紀律強制 skills（TDD、驗證要求）
- 安全關鍵實踐
- 已建立的最佳實踐

**範例：**
```markdown
✅ Write code before test? Delete it. Start over. No exceptions.
❌ Consider writing tests first when feasible.
```

### 2. 承諾（Commitment）
**定義：** 與先前行動、聲明或公開宣告的一致性。

**在 skills 中的運作方式：**
- 要求公告：「Announce skill usage」
- 強制明確選擇：「Choose A, B, or C」
- 使用追蹤：TodoWrite 用於清單

**使用時機：**
- 確保 skills 確實被遵循
- 多步驟流程
- 問責機制

**範例：**
```markdown
✅ When you find a skill, you MUST announce: "I'm using [Skill Name]"
❌ Consider letting your partner know which skill you're using.
```

### 3. 稀缺性（Scarcity）
**定義：** 來自時間限制或有限可用性的緊迫感。

**在 skills 中的運作方式：**
- 時間限定的要求：「Before proceeding」
- 順序依賴：「Immediately after X」
- 防止拖延

**使用時機：**
- 即時驗證要求
- 時間敏感的工作流程
- 防止「稍後再做」

**範例：**
```markdown
✅ After completing a task, IMMEDIATELY request code review before proceeding.
❌ You can review code when convenient.
```

### 4. 社會認同（Social Proof）
**定義：** 遵從他人的做法或被認為是正常的事。

**在 skills 中的運作方式：**
- 普遍模式：「Every time」、「Always」
- 失敗模式：「X without Y = failure」
- 建立規範

**使用時機：**
- 記錄普遍實踐
- 警告常見失敗
- 強化標準

**範例：**
```markdown
✅ Checklists without TodoWrite tracking = steps get skipped. Every time.
❌ Some people find TodoWrite helpful for checklists.
```

### 5. 團結（Unity）
**定義：** 共同身分、「我們感」、內群體歸屬感。

**在 skills 中的運作方式：**
- 協作語言：「our codebase」、「we're colleagues」
- 共同目標：「we both want quality」

**使用時機：**
- 協作工作流程
- 建立團隊文化
- 非階層制的實踐

**範例：**
```markdown
✅ We're colleagues working together. I need your honest technical judgment.
❌ You should probably tell me if I'm wrong.
```

### 6. 互惠（Reciprocity）
**定義：** 回報所受益處的義務感。

**運作方式：**
- 謹慎使用——可能感覺像在操控
- 在 skills 中很少需要

**何時避免：**
- 幾乎永遠（其他原理更有效）

### 7. 好感（Liking）
**定義：** 傾向與我們喜歡的人合作。

**運作方式：**
- **不要用於合規性**
- 與誠實回饋文化相衝突
- 造成諂媚行為

**何時避免：**
- 紀律強制時永遠避免

## 依 Skill 類型的原理組合

| Skill 類型 | 使用 | 避免 |
|------------|-----|-------|
| 紀律強制 | Authority + Commitment + Social Proof | Liking、Reciprocity |
| 指引/技術 | 適度 Authority + Unity | 過重 authority |
| 協作 | Unity + Commitment | Authority、Liking |
| 參考 | 只要清晰 | 所有說服原理 |

## 為什麼有效：心理學機制

**明確規則減少合理化：**
- 「YOU MUST」消除決策疲勞
- 絕對語言消除「這是例外嗎？」的問題
- 明確的反合理化措施堵住特定漏洞

**執行意圖創造自動行為：**
- 清楚的觸發器 + 必要行動 = 自動執行
- 「When X, do Y」比「generally do Y」更有效
- 減少合規的認知負荷

**LLM 是「準人類」（Parahuman）：**
- 在包含這些模式的人類文字上訓練
- 訓練資料中，權威語言出現在合規之前
- 承諾序列（聲明 → 行動）被頻繁建模
- 社會認同模式（everyone does X）建立規範

## 道德使用

**合理的用途：**
- 確保遵循關鍵實踐
- 建立有效的文件
- 防止可預見的失敗

**不合理的用途：**
- 為個人利益操控
- 製造虛假緊迫感
- 基於愧疚感的合規

**測試標準：** 如果使用者完全理解這些技術，它們是否仍然符合使用者的真實利益？

## 研究引用

**Cialdini, R. B. (2021).** *Influence: The Psychology of Persuasion (New and Expanded).* Harper Business.
- 七大說服原理
- 影響力研究的實證基礎

**Meincke, L., Shapiro, D., Duckworth, A. L., Mollick, E., Mollick, L., & Cialdini, R. (2025).** Call Me A Jerk: Persuading AI to Comply with Objectionable Requests. University of Pennsylvania.
- 以 N=28,000 次 LLM 對話測試 7 個原理
- 說服技術使合規率從 33% 提升至 72%
- Authority、commitment、scarcity 最有效
- 驗證了 LLM 行為的準人類模型

## 快速參考

設計 skill 時，問自己：

1. **它是什麼類型？**（紀律強制 vs. 指引 vs. 參考）
2. **我試圖改變什麼行為？**
3. **哪些原理適用？**（紀律通常是 authority + commitment）
4. **我是否組合了太多原理？**（不要用上全部七個）
5. **這道德嗎？**（符合使用者的真實利益？）
