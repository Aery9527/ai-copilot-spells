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
session_input_tokens=$(read_json "j?.context_window?.total_input_tokens")
session_output_tokens=$(read_json "j?.context_window?.total_output_tokens")
effort_level=$(read_json "j?.effort?.level")
cache_read_tokens=$(read_json "j?.context_window?.current_usage?.cache_read_input_tokens")
cache_creation_tokens=$(read_json "j?.context_window?.current_usage?.cache_creation_input_tokens")
turn_count=$(read_json "j?.turn_count")
session_state=$(read_json "j?.session_state")
session_id=$(read_json "j?.session_id")
transcript_path=$(read_json "j?.transcript_path")

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
    if   [ "$pct" -lt 50 ]; then printf "${ESC}[38;5;114m"  # soft green
    elif [ "$pct" -lt 80 ]; then printf "${ESC}[38;5;226m"  # yellow
    else                         printf "${ESC}[38;5;203m"  # coral red
    fi
}

# --- Color for ctx (tighter thresholds: 40/60) ---
color_for_ctx_pct() {
    local pct="$1"
    if   [ "$pct" -lt 40 ]; then printf "${ESC}[38;5;114m"  # soft green
    elif [ "$pct" -lt 60 ]; then printf "${ESC}[38;5;226m"  # yellow
    else                         printf "${ESC}[38;5;203m"  # coral red
    fi
}

# --- Color by cache hit rate (inverted: high = good) ---
color_for_cache_pct() {
    local pct="$1"
    if   [ "$pct" -ge 60 ]; then printf "${ESC}[38;5;114m"  # soft green
    elif [ "$pct" -ge 30 ]; then printf "${ESC}[38;5;226m"  # yellow
    else                         printf "${ESC}[38;5;203m"  # coral red
    fi
}

ESC=$'\033'
DIM="${ESC}[37m"
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
SOFT="${ESC}[38;5;216m"

# --- Model label with think level ---
# Detect extended thinking from model ID suffix: -thinking variants
build_model_label() {
    local display="$1"
    local id="$2"
    local effort="$3"
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
        -e 's/ (Extended Thinking)//' \
    )
    # Fallback: if model ID contains "thinking", strip suffix for display
    if echo "$id" | grep -qi "thinking"; then
        short=$(echo "$short" | sed 's/ 🧠//')
    fi
    # Append effort level in parentheses if present
    if [ -n "$effort" ]; then
        short="${short} (${effort})"
    fi
    echo "$short"
}

model_label=$(build_model_label "$model_name" "$model_id" "$effort_level")

# --- Normalize path: backslash→slash, C:/...→/c/... ---
normalize_path() {
    local p="${1//\\//}"
    if [[ "$p" =~ ^([A-Za-z]):(/.*)$ ]]; then
        p="/$(echo "${BASH_REMATCH[1]}" | tr '[:upper:]' '[:lower:]')${BASH_REMATCH[2]}"
    fi
    echo "$p"
}

# --- Git branch and repo root folder ---
git_branch=""
git_display_path=""
if [ -n "$cwd_path" ] && command -v git >/dev/null 2>&1; then
    git_branch=$(git -C "$cwd_path" --no-optional-locks branch --show-current 2>/dev/null)
    git_root=$(git -C "$cwd_path" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$git_root" ]; then
        home_norm=$(normalize_path "${HOME:-$(eval echo ~)}")
        git_root_norm=$(normalize_path "$git_root")
        if [[ "$git_root_norm" == "$home_norm"* ]]; then
            git_display_path="~${git_root_norm#$home_norm}"
        else
            git_display_path="$git_root_norm"
        fi
    fi
fi

# --- Git diff line counts vs HEAD (staged + unstaged combined) ---
diff_ins=""
diff_del=""
if [ -n "$git_root" ]; then
    _numstat=$(git -C "$git_root" --no-optional-locks diff HEAD --numstat 2>/dev/null)
    if [ -n "$_numstat" ]; then
        _sums=$(echo "$_numstat" | awk '{ins+=$1; del+=$2} END {print ins+0, del+0}')
        diff_ins=$(echo "$_sums" | cut -d' ' -f1)
        diff_del=$(echo "$_sums" | cut -d' ' -f2)
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
    local label="$1" pct_raw="$2" resets_at="$3" color_fn="${4:-color_for_pct}"
    local pct; pct=$(printf "%.0f" "$pct_raw")
    local bar; bar=$(make_bar "$pct")
    local col; col=$($color_fn "$pct")
    if [ -n "$resets_at" ]; then
        local remaining; remaining=$(format_remaining "$resets_at")
        printf "${DIM}${label}${RESET}${col}${bar}${RESET} ${DIM}${pct}%%(${remaining})${RESET}"
    else
        printf "${DIM}${label}${RESET}${col}${bar}${RESET} ${DIM}${pct}%%${RESET}"
    fi
}

SEP="${DIM} | ${RESET}"

# --- Context ---
if [ -n "$used_pct" ]; then
    ctx_label="ctx "
    if [ -n "$ctx_used" ] && [ -n "$ctx_total" ]; then
        ctx_label="ctx $(format_k "$ctx_used")/$(format_k "$ctx_total") "
    fi
    ctx_part=$(render_seg "$ctx_label" "$used_pct" "" "color_for_ctx_pct")
else
    ctx_part="${DIM}ctx ░░░░░░ --%${RESET}"
fi

# --- 5h ---
if [ -n "$five_pct" ] && [ -n "$five_resets" ]; then
    five_part=$(render_seg "5H " "$five_pct" "$five_resets")
else
    five_part=""
fi

# --- 7d ---
if [ -n "$week_pct" ] && [ -n "$week_resets" ]; then
    week_part=$(render_seg "7D " "$week_pct" "$week_resets")
else
    week_part=""
fi

# --- Model segment ---
if [ -n "$model_label" ]; then
    model_part="${ESC}[38;5;111m${model_label}${RESET}"
else
    model_part=""
fi

# --- Git segment: path (branch +ins -del) ---
_branch_inner="${ESC}[38;5;183m${git_branch}${RESET}"
if [ "${diff_ins:-0}" -gt 0 ] 2>/dev/null || [ "${diff_del:-0}" -gt 0 ] 2>/dev/null; then
    [ "${diff_ins:-0}" -gt 0 ] 2>/dev/null && _branch_inner+=" ${ESC}[38;5;114m+${diff_ins}${RESET}"
    [ "${diff_del:-0}" -gt 0 ] 2>/dev/null && _branch_inner+=" ${ESC}[38;5;203m-${diff_del}${RESET}"
fi

if [ -n "$git_display_path" ] && [ -n "$git_branch" ]; then
    git_part="${ESC}[38;5;183m${git_display_path}${RESET} ${DIM}(${RESET}${_branch_inner}${DIM})${RESET}"
elif [ -n "$git_display_path" ]; then
    git_part="${ESC}[38;5;183m${git_display_path}${RESET}"
else
    git_part=""
fi

# --- Session tokens + cost segment: in X + out X ≈ $X.XX ---
session_tokens_part=""
cost_part=""
if { [ -n "$session_input_tokens" ] && [ "$session_input_tokens" -gt 0 ] 2>/dev/null; } || \
   { [ -n "$session_output_tokens" ] && [ "$session_output_tokens" -gt 0 ] 2>/dev/null; }; then
    _in=$(format_k "${session_input_tokens:-0}")
    _out=$(format_k "${session_output_tokens:-0}")
    _cost=$(awk "BEGIN { printf \"%.2f\", (${session_input_tokens:-0} * 3 + ${session_output_tokens:-0} * 15) / 1000000 }")
    session_tokens_part="${SOFT}in ${_in} ${DIM}+${RESET} ${SOFT}out ${_out} ${DIM}≈${RESET} ${SOFT}\$${_cost}${RESET}"
fi

# --- Cache read tokens segment with hit rate bar ---
cache_part=""
if [ -n "$cache_read_tokens" ] && [ "$cache_read_tokens" -gt 0 ] 2>/dev/null; then
    _cache=$(format_k "$cache_read_tokens")
    _total_in=$(awk "BEGIN { print ${cache_read_tokens} + ${cache_creation_tokens:-0} + ${session_input_tokens:-0} }")
    if [ "${_total_in}" -gt 0 ] 2>/dev/null; then
        _hit_pct=$(awk "BEGIN { printf \"%d\", ${cache_read_tokens} * 100 / ${_total_in} }")
        _col=$(color_for_cache_pct "$_hit_pct")
        cache_part="${DIM}cache ${_cache} ${RESET}${_col}●${RESET} ${DIM}${_hit_pct}%${RESET}"
    else
        cache_part="${DIM}cache ${_cache}${RESET}"
    fi
fi

# --- Turn count segment ---
turn_part=""
if [ -n "$turn_count" ] && [ "$turn_count" -gt 0 ] 2>/dev/null; then
    turn_part="${DIM}turn ${turn_count}${RESET}"
fi

# --- Session state segment ---
# Priority: hook state file > session_state field (future Claude Code) > default idle
state_part=""
hook_state=""
if [ -n "$session_id" ]; then
    _sf="${TMPDIR:-/tmp}/claude_state_${session_id}"
    [ -f "$_sf" ] && hook_state=$(cat "$_sf" 2>/dev/null)
fi

if [ -n "$hook_state" ]; then
    case "$hook_state" in
        running) state_part="${ESC}[38;5;114m◉ 執行中${RESET}" ;;
        idle)    state_part="${DIM}◉ 等待指示${RESET}" ;;
        *)       state_part="${DIM}◉ ${hook_state}${RESET}" ;;
    esac
elif [ -n "$session_state" ]; then
    case "$session_state" in
        idle)                                  state_part="${DIM}◉ 等待指示${RESET}" ;;
        awaiting_selection|awaiting-selection) state_part="${ESC}[38;5;226m◉ 等待選擇${RESET}" ;;
        active|running)                        state_part="${ESC}[38;5;114m◉ 執行中${RESET}" ;;
        *)                                     state_part="${DIM}◉ ${session_state}${RESET}" ;;
    esac
else
    state_part="${DIM}◉ 等待指示${RESET}"
fi

# --- Last user prompt (from transcript) ---
last_prompt_part=""
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    _raw_prompt=$(node -e "
let d=''; process.stdin.on('data',c=>d+=c);
process.stdin.on('end',()=>{
  try {
    const lines = d.trim().split('\n');
    for (let i = lines.length - 1; i >= 0; i--) {
      try {
        const obj = JSON.parse(lines[i]);
        if (obj.type === 'user' || obj.role === 'user') {
          let text = '';
          if (typeof obj.message === 'string') { text = obj.message; }
          else if (obj.message && Array.isArray(obj.message.content)) {
            const t = obj.message.content.find(c => c.type === 'text');
            if (t) text = t.text;
          } else if (obj.message && typeof obj.message.content === 'string') {
            text = obj.message.content;
          } else if (Array.isArray(obj.content)) {
            const t = obj.content.find(c => c.type === 'text');
            if (t) text = t.text;
          } else if (typeof obj.content === 'string') {
            text = obj.content;
          }
          if (text.trim()) { process.stdout.write(text.trim()); break; }
        }
      } catch(e2) {}
    }
  } catch(e) {}
});" < "$transcript_path" 2>/dev/null)
    if [ -n "$_raw_prompt" ]; then
        # Collapse newlines into space, then truncate to 80 chars
        _single=$(echo "$_raw_prompt" | tr '\n\r' '  ' | sed 's/  */ /g')
        _max=80
        if [ "${#_single}" -gt "$_max" ]; then
            _single="${_single:0:$_max}…"
        fi
        last_prompt_part="${ESC}[38;5;111m»${RESET} ${ESC}[38;5;245m${_single}${RESET}"
    fi
fi

# --- Assemble ---
line1=""
[ -n "$model_part"          ] && line1+="${model_part}"
[ -n "$git_part"            ] && line1+="${SEP}${git_part}"
[ -n "$session_tokens_part" ] && line1+="${SEP}${session_tokens_part}"

line2=""
[ -n "$cache_part" ] && line2+="${cache_part}"
[ -n "$turn_part"  ] && { [ -n "$line2" ] && line2+="${SEP}"; line2+="${turn_part}"; }
[ -n "$line2"      ] && line2+="${SEP}${ctx_part}" || line2="${ctx_part}"
[ -n "$five_part"  ] && line2+="${SEP}${five_part}"
[ -n "$week_part"  ] && line2+="${SEP}${week_part}"
[ -n "$state_part" ] && line2+="${SEP}${state_part}"

line3=""
[ -n "$last_prompt_part" ] && line3="${last_prompt_part}"

if [ -n "$line3" ]; then
    printf "%s\n%s\n%s" "$line1" "$line2" "$line3"
else
    printf "%s\n%s" "$line1" "$line2"
fi
