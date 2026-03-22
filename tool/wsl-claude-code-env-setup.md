# Windows 從零開始安裝 WSL、GitHub SSH、Claude Code、sandbox 依賴、Python、Golang 與快捷指令

這份文件整理一條 **Windows → WSL 2 → GitHub SSH → Claude Code → sandbox → Python → Golang → 自訂快捷指令** 的最小可行安裝流程，目標是讓你在 Windows 上用 WSL 建立一個適合 Claude Code 的 Linux 開發環境。

> 本文件以 **Windows 11 / Windows 10 2004+** 搭配 **Ubuntu on WSL** 為主要路徑。
>
> Claude Code 官方目前建議使用 **native installer**，**不需要另外先安裝 Node.js**。`npm install -g @anthropic-ai/claude-code` 仍可用，但官方已標示為 **deprecated**，不建議作為新安裝流程。

## 快速跳轉

- [Step 1：在 Windows 安裝 WSL](#step-1)
- [Step 2：第一次啟動 Ubuntu，建立 Linux 帳號](#step-2)
- [Step 3：確認你現在使用的是 WSL 2](#step-3)
- [Step 4：更新 Ubuntu 套件並安裝基礎工具](#step-4)
- [Step 5：在 WSL 內設定 GitHub SSH key](#step-5)
- [Step 6：在 WSL 內安裝 Claude Code](#step-6)
- [Step 7：安裝 Claude Code sandbox 模式需要的套件](#step-7)
- [Step 8：在 WSL 內安裝 Python](#step-8)
- [Step 9：在 WSL 內安裝 Golang](#step-9)
- [Step 10：在 WSL 內建立自訂快速指令](#step-10)
- [Step 11：整套環境驗證清單](#step-11)
- [建議的最終安裝順序](#final-order)
- [常見踩坑](#pitfalls)
- [參考來源](#references)

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

## Step 1

### 在 Windows 安裝 WSL

請用 **系統管理員** 身分開啟 PowerShell，執行：

```powershell
wsl --install
```

這個命令會自動：

- 啟用 WSL 與 Virtual Machine Platform
- 安裝最新 Linux kernel
- 將新安裝的 Linux 發行版預設為 WSL 2
- 預設安裝一個 Linux 發行版；這份文件的目標是 Ubuntu

執行完成後，**重新開機**。

如果你電腦上已經有 Docker Desktop 或其他 WSL 發行版，預設 distro 可能不是 Ubuntu。重開機後請再執行一次下面這條，確保之後直接進 Ubuntu：

```powershell
wsl --set-default Ubuntu
```

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

### 如果 WSL 本體需要更新

如果你已經裝好 WSL，但想先把 WSL runtime / kernel 更新到最新版本，請在 **Windows PowerShell（系統管理員）** 內執行：

```powershell
wsl --update
```

更新完成後，建議把目前的 WSL 實例關掉再重新開啟，確保新版本真的載入：

```powershell
wsl --shutdown
```

如果你想先確認目前狀態，也可以先看：

```powershell
wsl --status
```

> 補充：如果 `wsl --update` 因網路或商店來源出問題而失敗，再考慮改用 `wsl --update --web-download`。

---

## Step 2

### 第一次啟動 Ubuntu，建立 Linux 帳號

重新開機後，從 Windows 開始功能表打開 `Ubuntu`。

第一次啟動時，系統會要求你建立：

- Linux 使用者名稱
- Linux 密碼

這組帳密是 **WSL 裡的 Linux 帳號**，不是 Windows 帳號。

建立完成後，這個帳號會成為預設使用者，之後可以使用 `sudo`。

---

## Step 3

### 確認你現在使用的是 WSL 2

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

## Step 4

### 更新 Ubuntu 套件並安裝基礎工具

以下命令請在 **WSL / Ubuntu** 內執行，不是在 PowerShell。

如果你希望目前這個 Linux account 執行 `sudo` 時**不需要輸入密碼**，建議用 `visudo` 走獨立 sudoers 檔，避免直接改壞主檔：

```bash
sudo visudo -f /etc/sudoers.d/99-nopasswd-$USER
```

加入下面這一行，把 `<your-user>` 換成你的 Ubuntu 使用者名稱：

```text
<your-user> ALL=(ALL) NOPASSWD: ALL
```

存檔後，確認檔案權限是 `440`：

```bash
sudo chmod 440 /etc/sudoers.d/99-nopasswd-$USER
```

如果你想讓**整個 `sudo` 群組**都免密碼，也可以改成：

```text
%sudo ALL=(ALL) NOPASSWD: ALL
```

但這個範圍比較大，除非你很清楚自己在做什麼，否則建議只放行單一帳號。

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

## Step 5

### 在 WSL 內設定 GitHub SSH key

因為 Step 4 已經安裝了 `git`，這時候就適合把 GitHub SSH 一次設好。之後無論是 `git clone`、Claude Code 操作 repo，還是你自己在 WSL 裡開發，都會比較順。

### 建立 `~/.ssh` 目錄與權限

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

### 產生 SSH key

建議使用 `ed25519`：

```bash
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/github_ed25519
```

執行時如果系統問你 passphrase：

- 想提高安全性：設定一組 passphrase
- 想讓本機操作更簡單：可直接 Enter 留空

### 啟動 ssh-agent 並加入 key

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/github_ed25519
```

### 查看 public key 內容

```bash
cat ~/.ssh/github_ed25519.pub
```

把輸出的整串內容複製起來，加到 GitHub：

- GitHub → Settings
- SSH and GPG keys
- New SSH key

### 設定 `~/.ssh/config`

先建立檔案：

```bash
touch ~/.ssh/config
chmod 600 ~/.ssh/config
```

再把以下內容寫進 `~/.ssh/config`：

```sshconfig
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_ed25519
    IdentitiesOnly yes
    AddKeysToAgent yes
```

### 這份設定的意義

- `Host github.com`：當你連到 `github.com` 時套用這組規則
- `HostName github.com`：實際連線目標
- `User git`：GitHub SSH 固定使用 `git` 這個使用者名稱
- `IdentityFile ~/.ssh/github_ed25519`：指定要用哪把私鑰
- `IdentitiesOnly yes`：避免 SSH 自動亂試其他 key，降低多把金鑰時的混亂
- `AddKeysToAgent yes`：讓 SSH agent 幫你管理這把 key

### 進階版本：同一台 WSL 使用多個 GitHub 帳號

如果你同時有：

- 個人 GitHub 帳號
- 公司 / 工作 GitHub 帳號

建議不要把兩把 key 都綁在同一個 `Host github.com` 上，而是改用 **alias host** 分開管理。

### 先建立兩把 key

```bash
ssh-keygen -t ed25519 -C "your_personal_email@example.com" -f ~/.ssh/github_personal_ed25519
ssh-keygen -t ed25519 -C "your_work_email@company.com" -f ~/.ssh/github_work_ed25519
```

再把兩把 key 都加進 agent：

```bash
ssh-add ~/.ssh/github_personal_ed25519
ssh-add ~/.ssh/github_work_ed25519
```

### `~/.ssh/config` 的多帳號範例

```sshconfig
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_personal_ed25519
    IdentitiesOnly yes
    AddKeysToAgent yes

Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_work_ed25519
    IdentitiesOnly yes
    AddKeysToAgent yes
```

### 這種寫法的重點

- `github-personal` 與 `github-work` 是你自訂的 alias
- `HostName` 仍然是 GitHub 真正的主機：`github.com`
- 真正決定用哪把 key 的，是你 clone / push 時用的 host alias

### 驗證兩個帳號是否都能連上

```bash
ssh -T git@github-personal
ssh -T git@github-work
```

如果設定正確，兩條命令應該會各自顯示對應帳號的名稱。

### 多帳號時的 clone 寫法

個人帳號 repo：

```bash
git clone git@github-personal:your-user/your-repo.git
```

公司帳號 repo：

```bash
git clone git@github-work:your-org/your-repo.git
```

> 重點：如果你 `.ssh/config` 用的是 `github-personal` / `github-work`，那 remote URL 也必須用這兩個 alias，不能偷換回 `git@github.com:...`，不然 SSH 不會套用你指定的那把 key。

### 驗證 GitHub SSH 是否成功

```bash
ssh -T git@github.com
```

第一次連線通常會看到類似訊息，詢問是否信任主機：

```text
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

輸入：

```text
yes
```

如果成功，通常會看到 GitHub 類似這種回應：

```text
Hi <your-account>! You've successfully authenticated, but GitHub does not provide shell access.
```

### 後續 clone repo 時請用 SSH URL

例如：

```bash
git clone git@github.com:owner/repo.git
```

不要混用成 HTTPS：

```bash
https://github.com/owner/repo.git
```

---

## Step 6

### 在 WSL 內安裝 Claude Code

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

## Step 7

### 安裝 Claude Code sandbox 模式需要的套件

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

## Step 8

### 在 WSL 內安裝 Python

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

## Step 9

### 在 WSL 內安裝 Golang

如果你會在 WSL 裡寫 Go，建議直接在 Ubuntu 內安裝，避免 Windows 與 WSL 兩邊各裝一套造成 PATH 與工作目錄混亂。

### 安裝 Go

```bash
sudo apt install -y golang-go
```

這條路徑的優點是：

- 安裝簡單
- 與 Ubuntu 套件管理整合
- 對這份文件的「先跑起來」目標最穩定

缺點是版本可能比 [Go 官方安裝頁](https://go.dev/doc/install) 最新版慢一些。若你之後需要更新版本，再改走官方 tarball 安裝即可。

### 驗證 Go 是否可用

```bash
go version
which go
```

### 建立最小測試程式

```bash
mkdir -p ~/workspace/go-demo
cd ~/workspace/go-demo
cat > hello.go <<'EOF'
package main

import "fmt"

func main() {
	fmt.Println("hello from wsl golang")
}
EOF
go run hello.go
```

---

## Step 10

### 在 WSL 內建立自訂快速指令

這個概念和 [`tool/ps_func.md`](ps_func.md) 一樣，只是 PowerShell 的 `function` 改成 Bash 的 `function` / `alias`。

Ubuntu on WSL 預設通常使用 **Bash**，所以建議把自訂快捷指令寫進：

```bash
~/.bashrc
```

如果你自己改用 zsh，則改寫進：

```bash
~/.zshrc
```

### 編輯 `~/.bashrc`

```bash
nano ~/.bashrc
```

把以下內容加到檔案底部：

```bash
# Claude Code / workspace shortcuts

function cc() {
  claude "$@"
}

function gcc() {
  claude --allowedTools "Bash(*)" "$@"
}

function gws() {
  cd ~/workspace/go
}

alias croot='cd ~/workspace'
```

### 重新載入設定

```bash
source ~/.bashrc
```

### 使用方式範例

```bash
cc
gcc
gws
croot
```

### 這幾個範例在做什麼

- `cc`：直接呼叫 `claude`，並保留你後面傳入的參數
- `gcc`：呼叫 `claude --allowedTools "Bash(*)"`，概念上對應 [`tool/ps_func.md`](ps_func.md) 裡的 PowerShell 版本
- `gws`：快速切到 Go 工作目錄
- `croot`：快速切到通用 workspace 根目錄

### 建議目錄先建立好

```bash
mkdir -p ~/workspace/go
```

---

## Step 11

### 整套環境驗證清單

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

### 在 WSL 驗證 GitHub SSH

```bash
ls -la ~/.ssh
ssh -T git@github.com
```

如果你使用的是多帳號進階版本，再補驗證：

```bash
ssh -T git@github-personal
ssh -T git@github-work
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

### 在 WSL 驗證 Golang

```bash
go version
go env GOPATH
```

### 在 WSL 驗證自訂快速指令

```bash
type cc
type gcc
type gws
type croot
```

---

## Final order

### 建議的最終安裝順序

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
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/github_ed25519
touch ~/.ssh/config
chmod 600 ~/.ssh/config
curl -fsSL https://claude.ai/install.sh | bash
sudo apt-get install -y bubblewrap socat
sudo apt install -y python3 python3-pip python3-venv python3-dev
sudo apt install -y golang-go
claude --version
claude doctor
ssh -T git@github.com
python3 --version
pip3 --version
go version
```

之後登入 Claude Code：

```bash
claude
```

在 Claude Code 裡啟用 sandbox：

```text
/sandbox
```

如果要加 Bash 自訂快速指令，再補這兩步：

```bash
nano ~/.bashrc
source ~/.bashrc
```

---

## Pitfalls

### 常見踩坑

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

### 5. `ssh -T git@github.com` 失敗，或一直吃不到指定 key

先檢查 `~/.ssh/config` 是否真的指到你建立的那把 key：

```sshconfig
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_ed25519
    IdentitiesOnly yes
```

再檢查權限是否合理：

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/github_ed25519
chmod 644 ~/.ssh/github_ed25519.pub
```

### 6. 已經設定 SSH key，但 clone 還是跳 HTTPS 認證

通常是因為你用的是 HTTPS clone URL。請改用：

```bash
git clone git@github.com:owner/repo.git
```

如果你用的是多帳號進階版本，就要改成對應 alias：

```bash
git clone git@github-personal:your-user/your-repo.git
git clone git@github-work:your-org/your-repo.git
```

### 7. `.ssh/config` 明明設了 `github-personal` / `github-work`，但 repo 還是吃錯帳號

這通常是因為 remote URL 還在用：

```bash
git@github.com:owner/repo.git
```

而不是你設定的 alias host。請改成：

```bash
git@github-personal:your-user/your-repo.git
```

或：

```bash
git@github-work:your-org/your-repo.git
```

### 8. Go 裝好了，但版本不是最新

如果你是用：

```bash
sudo apt install -y golang-go
```

那麼你拿到的是 Ubuntu 套件庫版本，不一定是 Go 官方最新版本。這是這份文件刻意採用的保守路線；想要最新版時，再改走 Go 官方安裝方式即可。

### 9. `~/.bashrc` 已經改了，但快捷指令不能用

通常是因為目前 shell 還沒重新載入設定。先執行：

```bash
source ~/.bashrc
```

如果你實際使用的是 zsh，就應該改寫 `~/.zshrc`，而不是 `~/.bashrc`。

---

## References

### 參考來源

- [Microsoft Learn: Install WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
- [Microsoft Learn: Set up a WSL development environment](https://learn.microsoft.com/en-us/windows/wsl/setup/environment)
- [Claude Code Docs: Advanced setup](https://code.claude.com/docs/en/setup)
- [Claude Code Docs: Sandboxing](https://code.claude.com/docs/en/sandboxing)
- [Microsoft Learn: Set up your Python development environment on Windows](https://learn.microsoft.com/en-us/windows/dev-environment/python)
- [Go Documentation: Download and install](https://go.dev/doc/install)

---

## 補充建議

如果你接下來會在 WSL 裡長期寫 Python，建議下一步再補這些：

- 安裝 [Visual Studio Code 與 WSL Remote 開發流程](https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-vscode)
- 在 WSL 裡設定 Git
- 針對不同專案固定使用 `.venv`
- 把常用專案統一放到 `~/workspace/`

