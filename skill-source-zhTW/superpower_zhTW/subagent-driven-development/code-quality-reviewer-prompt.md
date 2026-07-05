# 程式碼品質審查者 Prompt 模板

派遣程式碼品質審查者子代理時使用此模板。

**目的：** 驗證實作是否做得夠好（乾淨、有測試、可維護）

**只在規格合規審查通過後才派發。**

```
Task tool (general-purpose):
  Use template at requesting-code-review/code-reviewer.md

  DESCRIPTION: [task summary, from implementer's report]
  PLAN_OR_REQUIREMENTS: Task N from [plan-file]
  BASE_SHA: [commit before task]
  HEAD_SHA: [current commit]
```

**除了標準程式碼品質考量外，審查者還應檢查：**
- 每個檔案是否只有一個清楚的責任且介面定義良好？
- 各單元是否分解到可被獨立理解與測試的程度？
- 實作是否遵循計畫中定義的檔案結構？
- 此次實作是否建立了過大的新檔案，或顯著地使既有檔案膨脹？（不要標記既有的檔案大小——專注於此次改動帶來的影響。）

**程式碼審查者回報：** 優點、問題（Critical/Important/Minor）、評估結論
