#!/usr/bin/env bash
# Hook: Stop
#   - mark session state as idle
#   - remove the assistant marker so statusline row4 falls back to transcript
input=$(cat)
session_id=$(echo "$input" | node -e "
let d='';process.stdin.on('data',c=>d+=c);
process.stdin.on('end',()=>{
  try{process.stdout.write(JSON.parse(d)?.session_id??'')}catch(e){}
})")
if [ -n "$session_id" ]; then
    tmp="${TMPDIR:-/tmp}"
    printf 'idle' > "${tmp}/claude_state_${session_id}"
    rm -f "${tmp}/claude_last_asst_${session_id}"
fi
