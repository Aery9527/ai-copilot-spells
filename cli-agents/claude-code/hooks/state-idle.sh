#!/usr/bin/env bash
# Hook: Stop
#   標記 session 狀態為 idle，並解除 statusline row4 的壓制，讓它回頭顯示 transcript。
#
# 設計約束同 state-running.sh：settings.json 用 exec form 直接啟動 bash.exe，
# 本腳本內容維持 builtin-only（不用 cat/node），兩者合起來讓整條呼叫鏈不 fork 出
# 會被 MSYS2 CreateProcess(SUSPENDED) 卡死的子行程。
# rm -f 保留一個 fork，不改用「寫入非空內容」取代刪檔：Stop 頻率遠低於 PreToolUse，
# 省下這一個 fork 不值得在兩個檔案之間引入「檔案存在與否」以外的隱性協定耦合。

input=''
[ -t 0 ] || IFS= read -r -N 4096 -t 0.5 input

_re_sid='"session_id"[[:space:]]*:[[:space:]]*"([A-Za-z0-9._-]+)"'
[[ $input =~ $_re_sid ]] || exit 0
sid="${BASH_REMATCH[1]}"

tmp="${TMPDIR:-/tmp}"
printf 'idle' > "${tmp}/claude_state_${sid}"
rm -f -- "${tmp}/claude_last_asst_${sid}"

exit 0
