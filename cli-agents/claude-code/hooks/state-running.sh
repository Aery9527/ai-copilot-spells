#!/usr/bin/env bash
# Hook: UserPromptSubmit / PreToolUse
#   標記 session 狀態為 running；UserPromptSubmit 另外把 prompt 存給 statusline row3，
#   並把 assistant marker 清空以壓下 row4，直到下一次 Stop hook 解除。
#
# 設計約束：本腳本掛在 PreToolUse，每一次工具呼叫都會執行且為阻塞呼叫。settings.json
# 用 exec form（bash.exe 絕對路徑 + args）直接啟動 bash.exe，跳過外層 shell 包裝，
# 避免巢狀 bash.exe；本腳本內容維持 builtin-only（不用 cat/node/head/sed），
# 兩者合起來讓整條呼叫鏈不 fork 出任何會被 MSYS2 CreateProcess(SUSPENDED) 卡死的子行程。

# stdin：-N 是有緩衝的批次讀取，-d '' 在 MSYS2 上是逐位元組讀取、大 payload 下慢一個
# 數量級（hook 的 payload 可能內嵌使用者貼上的大段 prompt 或 Write/Edit 的完整檔案內容，
# 遠比一般 JSON 大）。0.5 秒是本腳本唯一的等待點：這是純粹的狀態顯示用途，
# 寧可偶爾漏一次更新（fail-open）也不要讓工具呼叫被拖住。
# 下面 -N/子字串的數量單位是否為 bytes 或字元，取決於 LANG/LC_ALL/LC_CTYPE：這台機器
# 三者皆未設定，bash 退回 C locale，是 byte 語意（實測 read -N 10 對 CJK 字串會切斷在
# 多位元組字元中間）；若日後這個環境改設了 UTF-8 locale，語意會跟著變成字元，這裡的常數要重估。
input=''
[ -t 0 ] || IFS= read -r -N 16384 -t 0.5 input

# session_id 會直接拼進檔名，字元集限制同時擔任路徑安全驗證
_re_sid='"session_id"[[:space:]]*:[[:space:]]*"([A-Za-z0-9._-]+)"'
[[ $input =~ $_re_sid ]] || exit 0
sid="${BASH_REMATCH[1]}"

tmp="${TMPDIR:-/tmp}"
printf 'running' > "${tmp}/claude_state_${sid}"

_re_evt='"hook_event_name"[[:space:]]*:[[:space:]]*"UserPromptSubmit"'
[[ $input =~ $_re_evt ]] || exit 0

# JSON 字串主體：非引號非反斜線的字元，或反斜線加任一字元。
# 刻意不要求收尾引號 —— 輸入被上面的 -N 上限截斷時仍能取到前綴，statusline 本來就只顯示開頭。
_re_prompt='"prompt"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)'
prompt=''
# 只留 2560 個單位再還原跳脫符號：下面的還原是逐個反斜線切字串，成本隨長度平方
# 成長，貼上大量反斜線密集內容（例如 Windows 路徑，在這個 monorepo 是日常操作）時
# 實測會讓耗時從 200ms 暴增到 2 秒以上。最長的跳脫序列是 6 字元的 \uXXXX，
# 2560 在任何情況下都還原得出超過下面要落地的 400 這個上限。
[[ $input =~ $_re_prompt ]] && prompt="${BASH_REMATCH[1]:0:2560}"

# 單趟掃描還原 JSON 跳脫符號。逐段切到下一個反斜線，避免多次 ${//} 取代互相污染
# （\\n 是字面反斜線+n，不是換行，若處理順序錯誤會被誤讀）。截斷點落在反斜線本身
# 或 \uXXXX 中間都安全結束（bash 子字串越界取值回傳空字串，不會出錯）。
unescaped=''
rest="$prompt"
while [[ $rest == *'\'* ]]; do
    unescaped+="${rest%%\\*}"
    rest="${rest#*\\}"
    case "${rest:0:1}" in
        n|r|t|b|f) unescaped+=' ' ;;
        u)         unescaped+=' '; rest="${rest:4}" ;;
        '')        ;;
        *)         unescaped+="${rest:0:1}" ;;
    esac
    rest="${rest:1}"
done
unescaped+="$rest"

# statusline 只顯示開頭一小段，沒有理由把整段大 prompt 落地
printf '%s' "${unescaped:0:400}" > "${tmp}/claude_last_user_${sid}"
# 空檔即「壓下 row4」，由 state-idle.sh 解除；兩檔協定，改一邊必壞
: > "${tmp}/claude_last_asst_${sid}"

# hook 的離開碼有語意：PreToolUse 回傳非零（尤其是 2）會擋掉或干擾工具呼叫。
# 上面最後執行的 read／[[ ]] 都可能回傳非零，必須明確歸零。
exit 0
