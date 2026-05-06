#!/usr/bin/env bash
# Hook: Stop — mark session state as idle
input=$(cat)
session_id=$(echo "$input" | node -e "
let d='';process.stdin.on('data',c=>d+=c);
process.stdin.on('end',()=>{
  try{process.stdout.write(JSON.parse(d)?.session_id??'')}catch(e){}
})")
[ -n "$session_id" ] && printf 'idle' > "${TMPDIR:-/tmp}/claude_state_${session_id}"
