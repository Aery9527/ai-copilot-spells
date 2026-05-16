#!/usr/bin/env bash
# Hook: UserPromptSubmit / PreToolUse
#   - mark session state as running
#   - on UserPromptSubmit: capture prompt for statusline row3,
#     and truncate the assistant marker to empty so row4 is suppressed
#     until the next Stop hook clears it.
input=$(cat)

parsed=$(echo "$input" | node -e "
let d='';process.stdin.on('data',c=>d+=c);
process.stdin.on('end',()=>{
  try{
    const j=JSON.parse(d);
    process.stdout.write((j?.session_id??'')+'\n');
    process.stdout.write((j?.hook_event_name??''));
  }catch(e){}
})")
session_id=$(printf '%s' "$parsed" | head -n1)
event=$(printf '%s' "$parsed" | sed -n '2p')

[ -z "$session_id" ] && exit 0

tmp="${TMPDIR:-/tmp}"
printf 'running' > "${tmp}/claude_state_${session_id}"

if [ "$event" = "UserPromptSubmit" ]; then
    echo "$input" | node -e "
let d='';process.stdin.on('data',c=>d+=c);
process.stdin.on('end',()=>{
  try{process.stdout.write(JSON.parse(d)?.prompt??'')}catch(e){}
})" > "${tmp}/claude_last_user_${session_id}"
    : > "${tmp}/claude_last_asst_${session_id}"
fi
