# Windows 從零開始安裝 WSL、Claude Code、sandbox 依賴與 Python

這份文件整理一條 **Windows → WSL 2 → Claude Code → sandbox → Python** 的最小可行安裝流程，目標是讓你在 Windows 上用 WSL 建立一個適合 Claude Code 的 Linux 開發環境。

> 本文件以 **Windows 11 / Windows 10 2004+** 搭配 **Ubuntu on WSL** 為主要路徑。
>
> Claude Code 官方目前建議使用 **native installer**，**不需要另外先安裝 Node.js**。`npm install -g @anthropic-ai/claude-code` 仍可用，但官方已標示為 **deprecated**，不建議作為新安裝流程。

---

## 這份文件會做什麼

1. 在 Windows 啟用並安裝 WSL
2. 確保 Linux 發行版跑在 **WSL 2**
3. 在 Ubuntu 內更新基礎套件
4. 安裝 Claude Code
5. 安裝 Claude Code **sandbox 模式**所需套件
6. 安裝 Python、`pip`、`venv`
7. 驗證整套環境是否可用

---

## 前置條件

### Windows 需求

- Windows 10 version 2004+（Build 19041+）或 Windows 11
- 可以使用系統管理員身分開 PowerShell
- 建議 BIOS / UEFI 已開啟虛擬化（若 WSL 2 啟動異常時尤其要檢查）

### Claude Code 帳號需求

Claude Code 需要以下其中一種帳號型態：

- Pro
- Max
- Teams
- Enterprise
- Console

免費版 `Claude.ai` 不包含 Claude Code CLI 存取權。

---

## Step 1：在 Windows 安裝 WSL

請用 **系統管理員** 身分開啟 PowerShell，執行：

```powershell
wsl --install
```

這個命令會自動：

- 啟用 WSL 與 Virtual Machine Platform
- 安裝最新 Linux kernel
- 將新安裝的 Linux 發行版預設為 WSL 2
- 預設安裝 Ubuntu

執行完成後，**重新開機**。

### 如果 `wsl --install` 沒有直接安裝成功

先列出可安裝的發行版：

```powershell
wsl --list --online
```

再明確安裝 Ubuntu：

```powershell
wsl --install -d Ubuntu
```

如果安裝過程卡在 `0.0%`，可改用 web download：

```powershell
wsl --install --web-download -d Ubuntu
```

---

## Step 2：第一次啟動 Ubuntu，建立 Linux 帳號

重新開機後，從 Windows 開始功能表打開 `Ubuntu`。

第一次啟動時，系統會要求你建立：

- Linux 使用者名稱
- Linux 密碼

這組帳密是 **WSL 裡的 Linux 帳號**，不是 Windows 帳號。

建立完成後，這個帳號會成為預設使用者，之後可以使用 `sudo`。

---

## Step 3：確認你現在使用的是 WSL 2

`sandbox` 模式在 Windows 上需要 **WSL 2**。

先在 Windows PowerShell 檢查目前版本：

```powershell
wsl --list --verbose
```

如果看到 Ubuntu 是 `VERSION 2`，就可以繼續。

如果還是 WSL 1，請升級：

```powershell
wsl --set-version Ubuntu 2
```

> Claude Code 在官方文件中標明：
>
> - **WSL 1 / WSL 2 都能安裝 Claude Code**
> - 但 **sandboxing 只支援 WSL 2**
> - **WSL 1 不支援 sandboxing**

---

## Step 4：更新 Ubuntu 套件並安裝基礎工具

以下命令請在 **WSL / Ubuntu** 內執行，不是在 PowerShell。

先更新套件索引與已安裝套件：

```bash
sudo apt update
sudo apt upgrade -y
```

再安裝常用基礎工具：

```bash
sudo apt install -y curl git ca-certificates build-essential
```

### 建議把專案放在 Linux 檔案系統

如果你的主要工具跑在 WSL（例如 Claude Code、Python、Git），建議專案放在 Linux 檔案系統中，例如：

```bash
mkdir -p ~/workspace
cd ~/workspace
```

**建議位置：**

```text
/home/<your-user>/workspace
```

**不建議長期把 WSL 開發專案放在：**

```text
/mnt/c/Users/<your-user>/...
```

原因是 Microsoft 官方明確建議：**工具在哪個 OS 上跑，專案就盡量放在同一個檔案系統**，效能與相容性會更好。

---

## Step 5：在 WSL 內安裝 Claude Code

Claude Code 官方目前推薦使用 **native installer**：

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

安裝完成後，驗證版本：

```bash
claude --version
```

再跑一次健康檢查：

```bash
claude doctor
```

### 第一次登入 Claude Code

```bash
claude
```

接著依照畫面流程完成登入與授權。

### 重要：不建議走舊的 npm 安裝路線

官方文件已說明：

- `npm` 安裝方式已 **deprecated**
- 新安裝優先使用 native installer
- 如果真的要用 npm，才需要 **Node.js 18+**

也就是說：

- **你現在這條 WSL 安裝流程，不需要先裝 Node.js 才能裝 Claude Code**
- 如果你只是要使用 Claude Code CLI，本文件的 native installer 路徑即可

---

## Step 6：安裝 Claude Code sandbox 模式需要的套件

Claude Code 官方文件指出：在 **Linux / WSL 2** 上，sandboxing 需要先安裝：

- `bubblewrap`
- `socat`

在 Ubuntu / Debian 內執行：

```bash
sudo apt-get install -y bubblewrap socat
```

安裝後，啟動 Claude Code，執行：

```text
/sandbox
```

然後依照互動式選單啟用 sandbox 模式。

### 為什麼是 WSL 2 而不是 WSL 1

Claude Code 官方文件說明：

- Linux 與 WSL 2 的 sandbox 是基於 `bubblewrap`
- `bubblewrap` 需要 WSL 2 才具備的 kernel 功能
- 因此 **WSL 1 不支援 sandboxing**

---

## Step 7：在 WSL 內安裝 Python

如果你的主要開發工作都會在 WSL 裡完成，Python 也建議直接安裝在 **Ubuntu / WSL** 內。

### 安裝 Python 3、pip、venv

```bash
sudo apt install -y python3 python3-pip python3-venv python3-dev
```

### 驗證版本

```bash
python3 --version
pip3 --version
```

### 建立並啟用虛擬環境

先建立專案資料夾：

```bash
mkdir -p ~/workspace/python-demo
cd ~/workspace/python-demo
```

建立虛擬環境：

```bash
python3 -m venv .venv
```

啟用虛擬環境：

```bash
source .venv/bin/activate
```

啟用後升級 `pip`：

```bash
python -m pip install --upgrade pip
```

再次驗證：

```bash
python --version
pip --version
```

### 最小測試

```bash
python -c "print('hello from wsl python')"
```

如果要離開虛擬環境：

```bash
deactivate
```

---

## Step 8：整套環境驗證清單

### 在 Windows PowerShell 驗證 WSL

```powershell
wsl --list --verbose
```

應確認：

- `Ubuntu` 已安裝
- `VERSION` 是 `2`

### 在 WSL 驗證 Claude Code

```bash
claude --version
claude doctor
```

### 在 WSL 驗證 sandbox 依賴

```bash
which bwrap
which socat
```

### 在 WSL 驗證 Python

```bash
python3 --version
pip3 --version
python3 -m venv --help
```

---

## 建議的最終安裝順序

如果你只想照最短路徑做一次，順序如下。

### Windows PowerShell（系統管理員）

```powershell
wsl --install
```

重新開機後進入 Ubuntu。

### WSL / Ubuntu

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y curl git ca-certificates build-essential
curl -fsSL https://claude.ai/install.sh | bash
sudo apt-get install -y bubblewrap socat
sudo apt install -y python3 python3-pip python3-venv python3-dev
claude --version
claude doctor
python3 --version
pip3 --version
```

之後登入 Claude Code：

```bash
claude
```

在 Claude Code 裡啟用 sandbox：

```text
/sandbox
```

---

## 常見踩坑

### 1. 已經裝好 WSL，但 Ubuntu 還在 WSL 1

請改成 WSL 2：

```powershell
wsl --set-version Ubuntu 2
```

### 2. Claude Code 可以裝，但 `/sandbox` 無法正常用

先檢查兩件事：

1. 你的 distro 是否是 **WSL 2**
2. 是否已安裝：

```bash
sudo apt-get install -y bubblewrap socat
```

### 3. 你看到網路上教學要先裝 Node.js

那通常是舊的 npm 安裝路線。依目前官方文件：

- **新安裝優先用 native installer**
- **npm 安裝已 deprecated**
- **只有 npm 路線才需要 Node.js 18+**

### 4. 在 `/mnt/c/...` 下跑 WSL 專案覺得慢

這不是錯覺。Microsoft 官方建議：

- Linux 工具跑在 WSL 時，專案放在 Linux 檔案系統
- 例如 `/home/<user>/workspace/...`

---

## 參考來源

- [Microsoft Learn: Install WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
- [Microsoft Learn: Set up a WSL development environment](https://learn.microsoft.com/en-us/windows/wsl/setup/environment)
- [Claude Code Docs: Advanced setup](https://code.claude.com/docs/en/setup)
- [Claude Code Docs: Sandboxing](https://code.claude.com/docs/en/sandboxing)
- [Microsoft Learn: Set up your Python development environment on Windows](https://learn.microsoft.com/en-us/windows/dev-environment/python)

---

## 補充建議

如果你接下來會在 WSL 裡長期寫 Python，建議下一步再補這些：

- 安裝 [Visual Studio Code 與 WSL Remote 開發流程](https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-vscode)
- 在 WSL 裡設定 Git
- 針對不同專案固定使用 `.venv`
- 把常用專案統一放到 `~/workspace/`

