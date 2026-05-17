#!/usr/bin/env bash
# 停止 brainstorm 伺服器並清理
# 用法：stop-server.sh <session_dir>
#
# 終止伺服器行程。只有當 session 目錄在 /tmp 下（暫存）時才刪除它。
# 持久性目錄（.superpowers/）會保留，以便之後檢視 mockup。

SESSION_DIR="$1"

if [[ -z "$SESSION_DIR" ]]; then
  echo '{"error": "Usage: stop-server.sh <session_dir>"}'
  exit 1
fi

STATE_DIR="${SESSION_DIR}/state"
PID_FILE="${STATE_DIR}/server.pid"

if [[ -f "$PID_FILE" ]]; then
  pid=$(cat "$PID_FILE")

  # 嘗試優雅地停止，若仍在運行則強制終止
  kill "$pid" 2>/dev/null || true

  # 等待優雅關閉（最多約 2 秒）
  for i in {1..20}; do
    if ! kill -0 "$pid" 2>/dev/null; then
      break
    fi
    sleep 0.1
  done

  # 若仍在運行，升級為 SIGKILL
  if kill -0 "$pid" 2>/dev/null; then
    kill -9 "$pid" 2>/dev/null || true

    # 給 SIGKILL 一點時間生效
    sleep 0.1
  fi

  if kill -0 "$pid" 2>/dev/null; then
    echo '{"status": "failed", "error": "process still running"}'
    exit 1
  fi

  rm -f "$PID_FILE" "${STATE_DIR}/server.log"

  # 只刪除暫存的 /tmp 目錄
  if [[ "$SESSION_DIR" == /tmp/* ]]; then
    rm -rf "$SESSION_DIR"
  fi

  echo '{"status": "stopped"}'
else
  echo '{"status": "not_running"}'
fi
