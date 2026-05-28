#!/usr/bin/env bash
# 啟動 brainstorm 伺服器並輸出連線資訊
# 用法：start-server.sh [--project-dir <path>] [--host <bind-host>] [--url-host <display-host>] [--foreground] [--background]
#
# 在隨機高連接埠上啟動伺服器，輸出包含 URL 的 JSON。
# 每個 session 都有自己的目錄以避免衝突。
#
# 選項：
#   --project-dir <path>  將 session 檔案儲存在 <path>/.superpowers/brainstorm/ 下
#                         而非 /tmp。伺服器停止後檔案仍然保留。
#   --host <bind-host>    要綁定的主機/介面（預設：127.0.0.1）。
#                         在遠端/容器化環境中使用 0.0.0.0。
#   --url-host <host>     回傳的 URL JSON 中顯示的主機名稱。
#   --foreground          在當前終端機中執行伺服器（不在背景執行）。
#   --background          強制背景模式（覆蓋 Codex 自動前景模式）。

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 解析參數
PROJECT_DIR=""
FOREGROUND="false"
FORCE_BACKGROUND="false"
BIND_HOST="127.0.0.1"
URL_HOST=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-dir)
      PROJECT_DIR="$2"
      shift 2
      ;;
    --host)
      BIND_HOST="$2"
      shift 2
      ;;
    --url-host)
      URL_HOST="$2"
      shift 2
      ;;
    --foreground|--no-daemon)
      FOREGROUND="true"
      shift
      ;;
    --background|--daemon)
      FORCE_BACKGROUND="true"
      shift
      ;;
    *)
      echo "{\"error\": \"Unknown argument: $1\"}"
      exit 1
      ;;
  esac
done

if [[ -z "$URL_HOST" ]]; then
  if [[ "$BIND_HOST" == "127.0.0.1" || "$BIND_HOST" == "localhost" ]]; then
    URL_HOST="localhost"
  else
    URL_HOST="$BIND_HOST"
  fi
fi

# 某些環境會回收已分離/背景的行程。偵測到時自動切換前景模式。
if [[ -n "${CODEX_CI:-}" && "$FOREGROUND" != "true" && "$FORCE_BACKGROUND" != "true" ]]; then
  FOREGROUND="true"
fi

# Windows/Git Bash 會回收 nohup 背景行程。偵測到時自動切換前景模式。
if [[ "$FOREGROUND" != "true" && "$FORCE_BACKGROUND" != "true" ]]; then
  case "${OSTYPE:-}" in
    msys*|cygwin*|mingw*) FOREGROUND="true" ;;
  esac
  if [[ -n "${MSYSTEM:-}" ]]; then
    FOREGROUND="true"
  fi
fi

# 產生唯一的 session 目錄
SESSION_ID="$$-$(date +%s)"

if [[ -n "$PROJECT_DIR" ]]; then
  SESSION_DIR="${PROJECT_DIR}/.superpowers/brainstorm/${SESSION_ID}"
else
  SESSION_DIR="/tmp/brainstorm-${SESSION_ID}"
fi

STATE_DIR="${SESSION_DIR}/state"
PID_FILE="${STATE_DIR}/server.pid"
LOG_FILE="${STATE_DIR}/server.log"

# 建立新的 session 目錄，包含 content 和 state 子目錄
mkdir -p "${SESSION_DIR}/content" "$STATE_DIR"

# 終止任何現有的伺服器
if [[ -f "$PID_FILE" ]]; then
  old_pid=$(cat "$PID_FILE")
  kill "$old_pid" 2>/dev/null
  rm -f "$PID_FILE"
fi

cd "$SCRIPT_DIR"

# 解析 harness PID（此腳本的祖父行程）。
# $PPID 是 harness 為執行我們而產生的短暫 shell——它在
# 此腳本退出時死亡。harness 本身是 $PPID 的父行程。
OWNER_PID="$(ps -o ppid= -p "$PPID" 2>/dev/null | tr -d ' ')"
if [[ -z "$OWNER_PID" || "$OWNER_PID" == "1" ]]; then
  OWNER_PID="$PPID"
fi

# 對於會回收已分離/背景行程的環境，使用前景模式。
if [[ "$FOREGROUND" == "true" ]]; then
  echo "$$" > "$PID_FILE"
  env BRAINSTORM_DIR="$SESSION_DIR" BRAINSTORM_HOST="$BIND_HOST" BRAINSTORM_URL_HOST="$URL_HOST" BRAINSTORM_OWNER_PID="$OWNER_PID" node server.cjs
  exit $?
fi

# 啟動伺服器，將輸出擷取到日誌檔案
# 使用 nohup 在 shell 退出後存活；使用 disown 從工作表中移除
nohup env BRAINSTORM_DIR="$SESSION_DIR" BRAINSTORM_HOST="$BIND_HOST" BRAINSTORM_URL_HOST="$URL_HOST" BRAINSTORM_OWNER_PID="$OWNER_PID" node server.cjs > "$LOG_FILE" 2>&1 &
SERVER_PID=$!
disown "$SERVER_PID" 2>/dev/null
echo "$SERVER_PID" > "$PID_FILE"

# 等待 server-started 訊息（檢查日誌檔案）
for i in {1..50}; do
  if grep -q "server-started" "$LOG_FILE" 2>/dev/null; then
    # 在短暫等待後驗證伺服器仍在運行（用於捕捉行程回收器）
    alive="true"
    for _ in {1..20}; do
      if ! kill -0 "$SERVER_PID" 2>/dev/null; then
        alive="false"
        break
      fi
      sleep 0.1
    done
    if [[ "$alive" != "true" ]]; then
      echo "{\"error\": \"Server started but was killed. Retry in a persistent terminal with: $SCRIPT_DIR/start-server.sh${PROJECT_DIR:+ --project-dir $PROJECT_DIR} --host $BIND_HOST --url-host $URL_HOST --foreground\"}"
      exit 1
    fi
    grep "server-started" "$LOG_FILE" | head -1
    exit 0
  fi
  sleep 0.1
done

# 逾時——伺服器未啟動
echo '{"error": "Server failed to start within 5 seconds"}'
exit 1
