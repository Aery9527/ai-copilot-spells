#!/usr/bin/env bash
# ~/.claude/statusline-command.sh

input=$(cat)

read_json() {
    local field="$1"
    echo "$input" | node -e "
let d=''; process.stdin.on('data',c=>d+=c);
process.stdin.on('end',()=>{
  try { const j=JSON.parse(d); const v=${field}; process.stdout.write(v!=null?String(v):''); }
  catch(e){}
});"
}

used_pct=$(read_json "j?.context_window?.used_percentage")
five_pct=$(read_json "j?.rate_limits?.five_hour?.used_percentage")
five_resets=$(read_json "j?.rate_limits?.five_hour?.resets_at")
week_pct=$(read_json "j?.rate_limits?.seven_day?.used_percentage")
week_resets=$(read_json "j?.rate_limits?.seven_day?.resets_at")

# --- Progress bar (width=6) ---
make_bar() {
    local pct="$1"
    local width=6
    local filled=$(( (pct * width * 10 / 100 + 5) / 10 ))
    local bar=""
    for ((i=0; i<width; i++)); do
        if [ "$i" -lt "$filled" ]; then bar+="█"; else bar+="░"; fi
    done
    echo "$bar"
}

# --- Color by pct ---
color_for_pct() {
    local pct="$1"
    if   [ "$pct" -lt 50 ]; then printf "${ESC}[38;5;114m"   # soft green
    elif [ "$pct" -lt 80 ]; then printf "${ESC}[38;5;221m"  # amber
    else                         printf "${ESC}[38;5;203m"  # coral red
    fi
}

ESC=$'\033'
DIM="${ESC}[2m"
RESET="${ESC}[0m"

# --- Remaining time ---
format_remaining() {
    local resets_at="$1"
    local now; now=$(date +%s)
    local diff=$(( resets_at - now ))
    [ "$diff" -le 0 ] && echo "↺" && return
    local days=$(( diff / 86400 ))
    local hours=$(( (diff % 86400) / 3600 ))
    local mins=$(( (diff % 3600) / 60 ))
    if   [ "$days"  -gt 0 ]; then echo "${days}d${hours}h"
    elif [ "$hours" -gt 0 ]; then echo "${hours}h${mins}m"
    else echo "${mins}m"
    fi
}

# --- Render one segment: label bar% (time) ---
render_seg() {
    local label="$1" pct_raw="$2" resets_at="$3"
    local pct; pct=$(printf "%.0f" "$pct_raw")
    local bar; bar=$(make_bar "$pct")
    local col; col=$(color_for_pct "$pct")
    if [ -n "$resets_at" ]; then
        local remaining; remaining=$(format_remaining "$resets_at")
        printf "${DIM}${label}${RESET}${col}${bar}${RESET}${DIM}${pct}%%(${remaining})${RESET}"
    else
        printf "${DIM}${label}${RESET}${col}${bar}${RESET}${DIM}${pct}%%${RESET}"
    fi
}

SEP="${DIM} ▏${RESET}"

# --- Context ---
if [ -n "$used_pct" ]; then
    ctx_part=$(render_seg "ctx " "$used_pct" "")
else
    ctx_part="${DIM}ctx ░░░░░░ --%${RESET}"
fi

# --- 5h ---
if [ -n "$five_pct" ] && [ -n "$five_resets" ]; then
    five_part=$(render_seg "5h " "$five_pct" "$five_resets")
else
    five_part=""
fi

# --- 7d ---
if [ -n "$week_pct" ] && [ -n "$week_resets" ]; then
    week_part=$(render_seg "7d " "$week_pct" "$week_resets")
else
    week_part=""
fi

# --- Assemble ---
out="$ctx_part"
[ -n "$five_part" ] && out+="${SEP}${five_part}"
[ -n "$week_part" ] && out+="${SEP}${week_part}"

printf "%s" "$out"
