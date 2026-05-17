# 縱深防禦式驗證

## 概觀

當修復一個由無效資料引起的錯誤時，在單一位置加入驗證看似已足夠。但這個單一檢查可能被不同的 code path、重構或 mocks 繞過。

**核心原則：** 在資料流經的每一層都加入驗證。讓錯誤在結構上不可能發生。

## 為何需要多層驗證

單一驗證：「我們修復了這個錯誤」
多層驗證：「我們讓這個錯誤不可能發生」

不同層次捕捉不同的情況：
- 入口驗證捕捉大多數錯誤
- 業務邏輯捕捉邊界案例
- 環境保護防止特定情境下的危險操作
- 除錯記錄在其他層失效時提供協助

## 四個層次

### 第一層：入口點驗證
**目的：** 在 API 邊界拒絕明顯無效的輸入

```typescript
function createProject(name: string, workingDirectory: string) {
  if (!workingDirectory || workingDirectory.trim() === '') {
    throw new Error('workingDirectory cannot be empty');
  }
  if (!existsSync(workingDirectory)) {
    throw new Error(`workingDirectory does not exist: ${workingDirectory}`);
  }
  if (!statSync(workingDirectory).isDirectory()) {
    throw new Error(`workingDirectory is not a directory: ${workingDirectory}`);
  }
  // ... proceed
}
```

### 第二層：業務邏輯驗證
**目的：** 確保資料對此操作具有意義

```typescript
function initializeWorkspace(projectDir: string, sessionId: string) {
  if (!projectDir) {
    throw new Error('projectDir required for workspace initialization');
  }
  // ... proceed
}
```

### 第三層：環境保護
**目的：** 在特定情境下防止危險操作

```typescript
async function gitInit(directory: string) {
  // In tests, refuse git init outside temp directories
  if (process.env.NODE_ENV === 'test') {
    const normalized = normalize(resolve(directory));
    const tmpDir = normalize(resolve(tmpdir()));

    if (!normalized.startsWith(tmpDir)) {
      throw new Error(
        `Refusing git init outside temp dir during tests: ${directory}`
      );
    }
  }
  // ... proceed
}
```

### 第四層：除錯埋點
**目的：** 捕捉用於事後分析的情境資訊

```typescript
async function gitInit(directory: string) {
  const stack = new Error().stack;
  logger.debug('About to git init', {
    directory,
    cwd: process.cwd(),
    stack,
  });
  // ... proceed
}
```

## 套用此模式

找到錯誤時：

1. **追蹤資料流** — 無效值從何而來？在哪裡被使用？
2. **列出所有檢查點** — 列出資料流經的每個位置
3. **在每一層加入驗證** — 入口、業務、環境、除錯
4. **測試每一層** — 嘗試繞過第一層，確認第二層能捕捉

## 來自實際 Session 的範例

錯誤：`projectDir` 為空字串，導致 `git init` 在原始碼目錄執行

**資料流：**
1. 測試設定 → 空字串
2. `Project.create(name, '')`
3. `WorkspaceManager.createWorkspace('')`
4. `git init` 在 `process.cwd()` 執行

**加入的四個層次：**
- 第一層：`Project.create()` 驗證非空、存在、可寫入
- 第二層：`WorkspaceManager` 驗證 projectDir 非空
- 第三層：`WorktreeManager` 在測試中拒絕於 tmpdir 外執行 git init
- 第四層：git init 前記錄 stack trace

**結果：** 所有 1847 個測試通過，錯誤不可能重現

## 關鍵洞察

四個層次全部都是必要的。測試過程中，每個層次都捕捉到其他層次未能捕捉的錯誤：
- 不同的 code path 繞過了入口驗證
- Mocks 繞過了業務邏輯檢查
- 不同平台上的邊界案例需要環境保護
- 除錯記錄識別出結構性誤用

**不要在一個驗證點就停下來。** 在每一層都加入檢查。
