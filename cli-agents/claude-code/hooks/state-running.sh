#!/usr/bin/env bash
# Hook: UserPromptSubmit / PreToolUse — mark session state as running
input=$(cat)
session_id=$(echo "$input" | node -e "
let d='';process.stdin.on('data',c=>d+=c);
process.stdin.on('end',()=>{
  try{process.stdout.write(JSON.parse(d)?.session_id??'')}catch(e){}
})")
[ -n "$session_id" ] && printf 'running' > "${TMPDIR:-/tmp}/claude_state_${session_id}"
