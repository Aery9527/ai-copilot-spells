# 用 AutoHotkey 設定快捷鍵叫出 Claude Desktop

## 1. 安裝 AutoHotkey

1. 前往 [https://www.autohotkey.com](https://www.autohotkey.com) 下載
2. 選擇 **AutoHotkey v2** 版本安裝
3. 安裝完成後不需要額外設定

---

## 2. 查詢 Claude Desktop 的 AppID

> 不同電腦或版本的 AppID 可能不同，建議每次設定前先查詢確認。

開啟 **PowerShell**，執行以下指令：

```powershell
Get-StartApps | Where-Object {$_.Name -like "*claude*"}
```

輸出範例：

```
Name   AppID
----   -----
Claude Claude_pzs8sxrjxfjjc!Claude
```

記下 `AppID` 欄位的值，下一步會用到。

---

## 3. 建立腳本

1. 在任意位置新增一個文字檔，副檔名命名為 `.ahk`
    - 例如：`claude-hotkey.ahk`
2. 用文字編輯器開啟，貼上以下內容，並將 `Claude_pzs8sxrjxfjjc!Claude` 替換成上一步查到的 AppID：

```ahk
#Requires AutoHotkey v2.0

!Space:: {
    appExe := "Claude.exe"

    hwnd := WinExist("ahk_exe " appExe)

    if (!hwnd) {
        ; 沒啟動 → 啟動（將 AppID 替換成你查到的值）
        Run "shell:AppsFolder\Claude_pzs8sxrjxfjjc!Claude"
    } else {
        if WinActive("ahk_exe " appExe) {
            ; 已經是 focus 狀態 → 最小化
            WinMinimize "ahk_exe " appExe
        } else {
            ; 有視窗但沒 focus → 叫出來
            WinRestore "ahk_exe " appExe
            WinActivate "ahk_exe " appExe
        }
    }
}
```

3. 儲存檔案

---

## 4. 使用方式

**雙擊** `.ahk` 檔案即可啟動腳本。

啟動後：
- 右下角 tray 會出現 **AHK 綠色圖示**，代表腳本正在執行
- 按下 `Alt + 空白鍵` 即可控制 Claude Desktop

### 快捷鍵行為

| 情境 | 行為 |
|------|------|
| Claude Desktop 未啟動 | 自動啟動 Claude Desktop |
| Claude Desktop 已開啟但未 focus | 將視窗叫到前景並 focus |
| Claude Desktop 已經是 focus | 最小化視窗 |

---

## 5. 開機自動啟動（選用）

如果希望每次開機都自動生效：

1. 對 `.ahk` 檔案按右鍵 → **建立捷徑**
2. 按 `Win + R`，輸入 `shell:startup`，按 Enter
3. 將剛才建立的**捷徑**移到這個資料夾中

之後每次開機，腳本就會自動執行。

---

## 附註

- 本腳本適用於從 **Microsoft Store** 安裝的 Claude Desktop
- 若是從官網下載安裝的版本，`Run` 的路徑需改為實際的 `Claude.exe` 路徑
- 如需更換快捷鍵，修改 `!Space::` 這行即可（`!` 代表 Alt，`#` 代表 Win，`^` 代表 Ctrl，`+` 代表 Shift）