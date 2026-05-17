# 測試反模式

**在以下情況讀取此參考：** 撰寫或修改測試、新增 mock，或有意在生產程式碼中加入僅供測試使用的方法時。

## 概覽

測試必須驗證真實行為，而不是 mock 的行為。Mock 是隔離工具，不是被測本體。

**核心原則：** 測試程式碼真正做了什麼，而不是 mock 做了什麼。

**嚴格遵循 TDD 可以預防這些反模式。**

## 鐵律

```
1. 絕不測試 mock 行為
2. 絕不在生產類別中新增僅供測試使用的方法
3. 絕不在未理解依賴關係的情況下使用 mock
```

## 反模式 1：測試 Mock 行為

**違規範例：**
```typescript
// ❌ 壞：測試 mock 是否存在
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
});
```

**為何錯誤：**
- 你只是在驗證 mock 有效，而不是元件有效
- 有 mock 就通過，沒有 mock 就失敗
- 對真實行為毫無說明

**你的人類夥伴的糾正：**「我們在測試 mock 的行為嗎？」

**修正方式：**
```typescript
// ✅ 好：測試真實元件，或不要 mock 它
test('renders sidebar', () => {
  render(<Page />);  // 不要 mock sidebar
  expect(screen.getByRole('navigation')).toBeInTheDocument();
});

// 或者若因隔離需要 mock sidebar：
// 不要對 mock 本身做斷言——測試在 sidebar 存在時 Page 的行為
```

### 閘門函式

```
在對任何 mock 元素做斷言之前：
  問自己：「我在測試真實元件行為，還是只在測 mock 是否存在？」

  如果是在測 mock 是否存在：
    停止——刪除斷言或取消 mock

  改為測試真實行為
```

## 反模式 2：在生產程式碼中放置僅供測試使用的方法

**違規範例：**
```typescript
// ❌ 壞：destroy() 只在測試中使用
class Session {
  async destroy() {  // 看起來像生產 API！
    await this._workspaceManager?.destroyWorkspace(this.id);
    // ... 清理
  }
}

// 在測試中
afterEach(() => session.destroy());
```

**為何錯誤：**
- 生產類別被僅供測試的程式碼污染
- 若在生產環境中意外呼叫，存在危險
- 違反 YAGNI 與職責分離
- 將物件生命週期與實體生命週期混為一談

**修正方式：**
```typescript
// ✅ 好：測試工具負責測試清理
// Session 沒有 destroy()——它在生產環境中是無狀態的

// 在 test-utils/ 中
export async function cleanupSession(session: Session) {
  const workspace = session.getWorkspaceInfo();
  if (workspace) {
    await workspaceManager.destroyWorkspace(workspace.id);
  }
}

// 在測試中
afterEach(() => cleanupSession(session));
```

### 閘門函式

```
在向生產類別新增任何方法之前：
  問自己：「這個方法只會被測試使用嗎？」

  如果是：
    停止——不要新增它
    改放到測試工具中

  問自己：「這個類別擁有此資源的生命週期嗎？」

  如果否：
    停止——這個方法放錯類別了
```

## 反模式 3：不理解依賴就亂用 Mock

**違規範例：**
```typescript
// ❌ 壞：Mock 破壞了測試邏輯
test('detects duplicate server', () => {
  // Mock 阻止了測試依賴的設定寫入！
  vi.mock('ToolCatalog', () => ({
    discoverAndCacheTools: vi.fn().mockResolvedValue(undefined)
  }));

  await addServer(config);
  await addServer(config);  // 應該拋出錯誤——但不會！
});
```

**為何錯誤：**
- 被 mock 的方法有測試依賴的副作用（寫入設定）
- 為了「安全」而過度 mock，破壞了真實行為
- 測試通過的原因是錯的，或以莫名方式失敗

**修正方式：**
```typescript
// ✅ 好：在正確層級 mock
test('detects duplicate server', () => {
  // 只 mock 緩慢的部分，保留測試需要的行為
  vi.mock('MCPServerManager'); // 只 mock 緩慢的伺服器啟動

  await addServer(config);  // 設定已寫入
  await addServer(config);  // 偵測到重複 ✓
});
```

### 閘門函式

```
在 mock 任何方法之前：
  停止——還不要 mock

  1. 問自己：「真實方法有哪些副作用？」
  2. 問自己：「這個測試依賴這些副作用中的任何一個嗎？」
  3. 問自己：「我完全了解這個測試需要什麼嗎？」

  如果依賴副作用：
    在更低層級 mock（實際的緩慢／外部操作）
    或使用能保留必要行為的測試替身
    而不是測試所依賴的高層方法

  如果不確定測試依賴什麼：
    先用真實實作跑測試
    觀察實際需要發生的事情
    然後在正確層級做最小 mock

  紅旗：
    - 「我 mock 這個以求安全」
    - 「這可能很慢，最好 mock 掉」
    - 在不了解依賴鏈的情況下 mock
```

## 反模式 4：不完整的 Mock

**違規範例：**
```typescript
// ❌ 壞：部分 mock——只包含你以為需要的欄位
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' }
  // 缺少：下游程式碼使用的 metadata
};

// 之後：當程式碼存取 response.metadata.requestId 時崩潰
```

**為何錯誤：**
- **部分 mock 隱藏結構假設**——你只 mock 了你知道的欄位
- **下游程式碼可能依賴你未包含的欄位**——靜默失敗
- **測試通過但整合失敗**——mock 不完整，真實 API 完整
- **虛假的信心**——測試對真實行為毫無說明

**鐵律：** Mock 資料結構時，必須完整反映真實情況，而不只是當前測試用到的欄位。

**修正方式：**
```typescript
// ✅ 好：完整反映真實 API
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
  metadata: { requestId: 'req-789', timestamp: 1234567890 }
  // 真實 API 回傳的所有欄位
};
```

### 閘門函式

```
在建立 mock 回應之前：
  確認：「真實 API 回應包含哪些欄位？」

  行動：
    1. 檢查文件／範例中的實際 API 回應
    2. 包含系統下游可能消費的所有欄位
    3. 驗證 mock 完整符合真實回應結構

  關鍵：
    如果你要建立 mock，你必須理解完整的資料結構
    當程式碼依賴被省略的欄位時，部分 mock 會靜默失敗

  如果不確定：包含所有已記錄的欄位
```

## 反模式 5：將整合測試當作事後補充

**違規範例：**
```
✅ 實作完成
❌ 沒有寫測試
「可以測試了」
```

**為何錯誤：**
- 測試是實作的一部分，不是可選的後續工作
- TDD 本可防止這種情況
- 沒有測試就不能宣稱完成

**修正方式：**
```
TDD 循環：
1. 寫失敗測試
2. 實作使其通過
3. 重構
4. 然後才宣稱完成
```

## 當 Mock 變得過於複雜

**警告訊號：**
- Mock 設置比測試邏輯還長
- 為了讓測試通過而 mock 一切
- Mock 缺少真實元件有的方法
- Mock 改動時測試就壞掉

**你的人類夥伴的問題：**「我們真的需要在這裡用 mock 嗎？」

**考慮：** 使用真實元件的整合測試，往往比複雜的 mock 更簡單

## TDD 如何預防這些反模式

**TDD 的幫助原因：**
1. **先寫測試** → 迫使你思考你實際在測試什麼
2. **觀察失敗** → 確認測試在測試真實行為，而非 mock
3. **最小實作** → 不會有僅供測試的方法悄悄混入
4. **真實依賴** → 在 mock 之前你先看到測試實際需要什麼

**如果你在測試 mock 行為，代表你違反了 TDD**——你在沒有先觀察測試對真實程式碼失敗的情況下就加入了 mock。

## 快速參考

| 反模式 | 修正方式 |
|--------|----------|
| 對 mock 元素做斷言 | 測試真實元件或取消 mock |
| 生產程式碼中有僅供測試的方法 | 移至測試工具 |
| 不理解依賴就 mock | 先理解依賴，再做最小 mock |
| 不完整的 mock | 完整反映真實 API |
| 測試當作事後補充 | TDD——先寫測試 |
| 過於複雜的 mock | 考慮整合測試 |

## 紅旗

- 斷言檢查 `*-mock` 測試 ID
- 方法只在測試檔案中被呼叫
- Mock 設置超過測試的 50%
- 移除 mock 時測試就失敗
- 無法解釋為何需要 mock
- 「為了安全」而 mock

## 結論

**Mock 是隔離工具，不是測試目標。**

如果 TDD 揭露你在測試 mock 行為，代表你走偏了。

修正方式：測試真實行為，或反思你為何要 mock。
