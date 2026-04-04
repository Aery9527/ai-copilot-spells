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
ctx_used=$(read_json "Math.round((j?.context_window?.used_percentage??0)*(j?.context_window?.context_window_size??200000)/100)")
ctx_total=$(read_json "j?.context_window?.context_window_size")
five_pct=$(read_json "j?.rate_limits?.five_hour?.used_percentage")
five_resets=$(read_json "j?.rate_limits?.five_hour?.resets_at")
week_pct=$(read_json "j?.rate_limits?.seven_day?.used_percentage")
week_resets=$(read_json "j?.rate_limits?.seven_day?.resets_at")
model_name=$(read_json "j?.model?.display_name")
model_id=$(read_json "j?.model?.id")
cwd_path=$(read_json "j?.workspace?.current_dir")

# --- Format number as Xk / X.Xk ---
format_k() {
    local n="$1"
    [ -z "$n" ] && echo "" && return
    if [ "$n" -ge 1000 ] 2>/dev/null; then
        local k=$(( n / 1000 ))
        local r=$(( (n % 1000 + 50) / 100 ))
        [ "$r" -ge 10 ] && k=$(( k + 1 )) && r=0
        if [ "$r" -eq 0 ]; then echo "${k}k"; else echo "${k}.${r}k"; fi
    else
        echo "${n}"
    fi
}

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
BOLD="${ESC}[1m"

# --- Model label with think level ---
# Detect extended thinking from model ID suffix: -thinking variants
build_model_label() {
    local display="$1"
    local id="$2"
    local label=""
    if [ -z "$display" ]; then
        echo ""
        return
    fi
    # Shorten known verbose names
    local short
    short=$(echo "$display" | sed \
        -e 's/Claude //' \
        -e 's/ Sonnet/S/' \
        -e 's/ Haiku/H/' \
        -e 's/ Opus/O/' \
        -e 's/ (Extended Thinking)/ 🧠/' \
    )
    # Fallback: if model ID contains "thinking", append indicator
    if echo "$id" | grep -qi "thinking" && ! echo "$short" | grep -q "🧠"; then
        short="${short} 🧠"
    fi
    echo "$short"
}

model_label=$(build_model_label "$model_name" "$model_id")

# --- Git branch and repo root folder ---
git_branch=""
git_root_folder=""
if [ -n "$cwd_path" ] && command -v git >/dev/null 2>&1; then
    git_branch=$(git -C "$cwd_path" --no-optional-locks branch --show-current 2>/dev/null)
    git_root=$(git -C "$cwd_path" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$git_root" ]; then
        git_root_folder=$(basename "$git_root")
    fi
fi

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
    ctx_label="ctx "
    if [ -n "$ctx_used" ] && [ -n "$ctx_total" ]; then
        ctx_label="ctx $(format_k "$ctx_used")/$(format_k "$ctx_total") "
    fi
    ctx_part=$(render_seg "$ctx_label" "$used_pct" "")
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

# --- Model segment ---
if [ -n "$model_label" ]; then
    model_part="${ESC}[38;5;111m${model_label}${RESET}"
else
    model_part=""
fi

# --- Git segment: folder:branch ---
if [ -n "$git_root_folder" ] && [ -n "$git_branch" ]; then
    git_part="${DIM}${git_root_folder}${RESET}${DIM}:${RESET}${ESC}[38;5;183m${git_branch}${RESET}"
elif [ -n "$git_root_folder" ]; then
    git_part="${DIM}${git_root_folder}${RESET}"
else
    git_part=""
fi

# --- Assemble ---
out=""
[ -n "$model_part" ] && out+="${model_part}"
[ -n "$git_part"   ] && out+="${SEP}${git_part}"
out+="${SEP}${ctx_part}"
[ -n "$five_part"  ] && out+="${SEP}${five_part}"
[ -n "$week_part"  ] && out+="${SEP}${week_part}"

printf "%s" "$out"
