#!/usr/bin/env bash
# ~/.claude/statusline-command.sh
#
# 設計約束：呼叫端每次畫面刷新都重新啟動本腳本，並會強殺仍在執行的前一次。
# 而 MSYS2 建立子行程的方式是「先 CreateProcess(SUSPENDED) 再喚醒」，
# 父行程若被殺在這個視窗內，子行程就永遠停在 suspended 且無人能喚醒（實測每次強殺約 4% 機率）。
# 因此本腳本的兩個目標是：
#   1. 絕大多數呼叫走完全不建立任何子行程的快取路徑 —— 此路徑被殺也不可能殘留。
#   2. 需要重算時盡快結束，讓下一次刷新到達前就跑完，根本不會被殺。
# 註：曾實測「bash exec node，全部工作交給單一 Node 行程」的寫法，
#     它把唯一的 spawn 視窗集中在啟動後 150~400ms，正好落在呼叫端的取消時點，
#     同樣條件下強殺 50 次殘留 46 個（92%），遠差於此版，故不採用。

CACHE_TTL=3
# git diff 掃全庫在大型 monorepo 要近 1 秒，是冷路徑最大的成本；
# 增刪行數本來就是慢變量，獨立用較長 TTL 快取，讓冷路徑短到能在下一次刷新抵達前結束
GIT_DIFF_TTL=30
CLEANUP_INTERVAL=600
CLEANUP_MIN_AGE=30   # 秒；只清超過這個年齡的，避免殺到剛 fork、尚未 ResumeThread 的合法子行程
CLEANUP_SENTINEL='claude-statusline-cleaner-v1'  # 讓下一輪清理也認得清理器自己萬一卡死留下的 powershell.exe
CLEANUP_FILE_MAX_AGE_DAYS=30  # per-session 快取/狀態檔的實際有效期只有秒級，此為單純的無界成長防呆

# --- 週期性自清除殘留殭屍與過期 per-session 檔案（非阻塞，絕大多數呼叫零額外成本）---
# 被強殺卡在 suspended 的 MSYS2 fork child 從未完成向 msys 行程表註冊，bash 自己的
# ps/kill 完全看不到它們（只存在於 Win32 層級），純 bash 無法偵測，只能偶爾背景丟一次
# PowerShell 去查、用跟人工驗證過同一組安全條件比對後清除。用時間戳記檔案節流，只有
# 超過 CLEANUP_INTERVAL 才會觸發，其餘呼叫只多一次檔案讀取比較。背景呼叫不等待其結果：
# 清理本身要 fork 出 powershell.exe，這一步跟本腳本其他子行程一樣仍走 MSYS2 的
# CreateProcess(SUSPENDED) 路徑，被下一次刷新連坐強殺時一樣可能留下 suspended
# powershell.exe（並非「原生行程就不會殘留」），所以掃描條件同時比對這個型態，
# 靠 CLEANUP_SENTINEL 認出來，讓這個機制對自己造成的殘留也能收斂，而不僅是清別人的。
# 同一次呼叫順手清掉超過 CLEANUP_FILE_MAX_AGE_DAYS 的 per-session 快取/狀態檔——
# 這些檔案只覆寫從不刪除，會隨 session 數無界累積；搭這班便車是零額外 fork 的做法。
# claude_* 這個 glob 同時會吃到自己這個節流用的 marker 檔，必須明確排除，
# 否則哪天門檻調緊，marker 被自己清掉會讓節流失效、變成每次呼叫都 fork 一次。
_cleanup_marker="${TMPDIR:-/tmp}/claude_sl_cleanup_marker"
_last_cleanup=0
[ -r "$_cleanup_marker" ] && IFS= read -r _last_cleanup < "$_cleanup_marker" 2>/dev/null
[[ $_last_cleanup =~ ^[0-9]+$ ]] && _last_cleanup=$((10#$_last_cleanup)) 2>/dev/null || _last_cleanup=0
if (( EPOCHSECONDS - _last_cleanup >= CLEANUP_INTERVAL )) \
    && printf '%s\n' "$EPOCHSECONDS" > "$_cleanup_marker" 2>/dev/null; then
    # marker 寫入失敗（例如 TMPDIR 不可寫）就不啟動 PowerShell：否則 _last_cleanup 永遠停在
    # 0，會變成每次呼叫都多 fork 一次，違背「絕大多數呼叫零額外成本」的設計目標。
    powershell.exe -NoProfile -WindowStyle Hidden -Command "
        \$cutoff = (Get-Date).AddSeconds(-${CLEANUP_MIN_AGE})
        Get-CimInstance Win32_Process | Where-Object {
            \$_.ProcessId -ne \$PID -and \$_.CreationDate -lt \$cutoff -and (
                (\$_.Name -eq 'bash.exe' -and \$_.CommandLine -like '*statusline-command*') -or
                (\$_.Name -eq 'powershell.exe' -and \$_.CommandLine -like '*${CLEANUP_SENTINEL}*')
            )
        } | ForEach-Object {
            # PID 可能在「用舊 CIM 快照認出殭屍」到「這裡重新查」之間被回收給別的行程，
            # 所以年齡與執行緒條件都要對這裡實際查到的物件重驗一次，並直接砍這個已驗證過的
            # 物件（-InputObject），不要再用 PID 二次查找，縮小 TOCTOU 窗口。
            \$p = Get-Process -Id \$_.ProcessId -ErrorAction SilentlyContinue
            if (\$p -and \$p.StartTime -lt \$cutoff -and \$p.Threads.Count -eq 1 -and \$p.Threads[0].ThreadState -eq 'Wait' -and \$p.Threads[0].WaitReason -eq 'Suspended') {
                Stop-Process -InputObject \$p -Force -ErrorAction SilentlyContinue
            }
        }
        \$fileCutoff = (Get-Date).AddDays(-${CLEANUP_FILE_MAX_AGE_DAYS})
        Get-ChildItem -LiteralPath \$env:TEMP -File -Filter 'claude_*' -ErrorAction SilentlyContinue | Where-Object {
            \$_.Name -ne 'claude_sl_cleanup_marker' -and \$_.LastWriteTime -lt \$fileCutoff
        } | Remove-Item -Force -ErrorAction SilentlyContinue
    " >/dev/null 2>&1 &
    disown
fi

# 讀 stdin：EOF 立即返回；呼叫端未關閉寫入端時最多等 5 秒（純 builtin，零 fork）
input=''
[ -t 0 ] || IFS= read -r -d '' -t 5 input

# --- 快取快路徑（零 fork，唯一能保證「被殺也不殘留」的路徑）-----------------
sid=''
[[ $input =~ \"session_id\"[[:space:]]*:[[:space:]]*\"([A-Za-z0-9._-]+)\" ]] && sid="${BASH_REMATCH[1]}"
cache="${TMPDIR:-/tmp}/claude_sl_${sid:-default}"

_cached=()
[ -n "$sid" ] && [ -r "$cache" ] && mapfile -t _cached < "$cache"

# 尾端哨符：寫入非原子，讀到被截斷的半份內容時視同未命中而不是拿去顯示
_n=${#_cached[@]}
_valid=0
(( _n >= 4 )) && [ "${_cached[_n-1]}" = "END" ] && _valid=1

emit_cached() {
    local out='' i
    # 以索引判斷分隔位置，不能用「out 是否為空」—— 第一行本身可能就是空字串
    for ((i = 1; i < _n - 1; i++)); do
        (( i > 1 )) && out+=$'\n'
        out+="${_cached[i]}"
    done
    printf '%s' "$out"
}

if (( _valid )) && (( EPOCHSECONDS - ${_cached[0]:-0} < CACHE_TTL )); then
    emit_cached
    exit 0
fi

# 先把時間戳推進再開始重算：同時湧入的其他刷新會改走快路徑，避免併發重算的 fork 風暴。
# 這裡刻意不用 noclobber 之類的真鎖 —— 持鎖者隨時可能被強殺，
# 留下的孤兒鎖會讓畫面凍結到鎖過期為止，比偶爾多算一次更糟。
if (( _valid )); then
    { printf '%s\n' "$EPOCHSECONDS"
      for ((i = 1; i < _n; i++)); do printf '%s\n' "${_cached[i]}"; done
    } > "$cache"
fi

# --- 單次 node 呼叫：JSON 解析、transcript 尾端訊息與 mtime -----------------
_raw=$(node -e '
const fs = require("fs");
const out = [];
const push = v => out.push(v == null ? "" : String(v).replace(/[\r\n]/g, " "));
let j = {};
try { j = JSON.parse(fs.readFileSync(0, "utf8")) || {}; } catch (e) {}
const cw = j.context_window || {}, u = cw.current_usage || {}, rl = j.rate_limits || {};
push(cw.used_percentage);
push(Math.round((cw.used_percentage ?? 0) * (cw.context_window_size ?? 200000) / 100));
push(cw.context_window_size);
push(rl.five_hour?.used_percentage);
push(rl.five_hour?.resets_at);
push(rl.seven_day?.used_percentage);
push(rl.seven_day?.resets_at);
push(j.model?.display_name);
push(j.model?.id);
push(j.effort?.level);
push(j.workspace?.current_dir);
push(j.turn_count);
push(j.session_state);
push(j.session_id);
push(u.cache_read_input_tokens);
push(u.cache_creation_input_tokens);
push(cw.total_input_tokens);

const tp = j.transcript_path || "";
let mtime = "", lastUser = "", lastAsst = "";
const norm = s => s.replace(/[\n\r]/g, " ").replace(/ +/g, " ").trim();
const textOf = o => {
  if (typeof o.message === "string") return o.message;
  if (o.message && Array.isArray(o.message.content)) return (o.message.content.find(c => c.type === "text") || {}).text || "";
  if (o.message && typeof o.message.content === "string") return o.message.content;
  if (Array.isArray(o.content)) return (o.content.find(c => c.type === "text") || {}).text || "";
  if (typeof o.content === "string") return o.content;
  return "";
};
try {
  const st = fs.statSync(tp);
  if (st.isFile()) {
    mtime = Math.floor(st.mtimeMs / 1000);
    // transcript 可達數百 MB，只從檔尾取樣並設上限，避免病態情況把整份讀進記憶體
    const fd = fs.openSync(tp, "r");
    try {
      for (const win of [262144, 2097152, 16777216]) {
        const size = Math.min(win, st.size);
        const buf = Buffer.alloc(size);
        fs.readSync(fd, buf, 0, size, st.size - size);
        const lines = buf.toString("utf8").split("\n");
        if (size < st.size) lines.shift();
        for (let i = lines.length - 1; i >= 0 && (!lastUser || !lastAsst); i--) {
          let o; try { o = JSON.parse(lines[i]); } catch (e) { continue; }
          const t = (textOf(o) || "").trim();
          if (!t) continue;
          if (!lastAsst && (o.role === "assistant" || o.type === "assistant" || o.message?.role === "assistant")) lastAsst = t;
          else if (!lastUser && (o.type === "user" || o.role === "user" || o.message?.role === "user")) lastUser = t;
        }
        if ((lastUser && lastAsst) || size >= st.size) break;
      }
    } finally { fs.closeSync(fd); }
  }
} catch (e) {}
push(mtime);
push(norm(lastUser));
push(norm(lastAsst));
out.push("END");
process.stdout.write(out.join("\n"));
' <<< "$input")
_node_rc=$?

mapfile -t F <<< "$_raw"

# node 若啟動失敗、中途例外或輸出被截斷，欄位會錯位；此時一律退回安全的預設畫面，
# 且絕不把損壞結果寫進快取
_ok=0
[ "$_node_rc" -eq 0 ] && [ "${#F[@]}" -eq 21 ] && [ "${F[20]}" = "END" ] && _ok=1
if (( ! _ok )); then
    F=()
    for ((i = 0; i < 21; i++)); do F[i]=''; done
fi

used_pct="${F[0]}"
ctx_used="${F[1]}"
ctx_total="${F[2]}"
five_pct="${F[3]}"
five_resets="${F[4]}"
week_pct="${F[5]}"
week_resets="${F[6]}"
model_name="${F[7]}"
model_id="${F[8]}"
effort_level="${F[9]}"
cwd_path="${F[10]}"
turn_count="${F[11]}"
session_state="${F[12]}"
session_id="${F[13]}"
cache_read_tokens="${F[14]}"
cache_creation_tokens="${F[15]}"
session_input_tokens="${F[16]}"
transcript_mtime="${F[17]}"
transcript_user="${F[18]}"
transcript_asst="${F[19]}"

# 進入 $(( )) 前一律確認是純數字，避免任何非預期字串被當成算式求值
isnum() { [[ $1 =~ ^-?[0-9]+$ ]]; }
# 取數值但絕不使用 $( )：command substitution 會 fork，正是本腳本要避免的
num() { isnum "$1" && REPLY="$1" || REPLY=0; }

ESC=$'\033'
DIM="${ESC}[37m"
RESET="${ESC}[0m"
SOFT="${ESC}[38;5;216m"

# 以下輔助函式一律以 REPLY 回傳，避免 $( ) 產生 subshell fork
format_k() {
    local n="$1"
    REPLY=''
    [ -z "$n" ] && return
    if isnum "$n" && [ "$n" -ge 1000 ]; then
        local k=$(( n / 1000 ))
        local r=$(( (n % 1000 + 50) / 100 ))
        [ "$r" -ge 10 ] && k=$(( k + 1 )) && r=0
        if [ "$r" -eq 0 ]; then REPLY="${k}k"; else REPLY="${k}.${r}k"; fi
    else
        REPLY="${n}"
    fi
}

make_bar() {
    local pct="$1" width=6 i
    local filled=$(( (pct * width * 10 / 100 + 5) / 10 ))
    REPLY=''
    for ((i = 0; i < width; i++)); do
        if [ "$i" -lt "$filled" ]; then REPLY+="█"; else REPLY+="░"; fi
    done
}

color_for_pct() {
    if   [ "$1" -lt 50 ]; then REPLY="${ESC}[38;5;114m"
    elif [ "$1" -lt 80 ]; then REPLY="${ESC}[38;5;226m"
    else                       REPLY="${ESC}[38;5;203m"
    fi
}

color_for_ctx_pct() {
    if   [ "$1" -lt 40 ]; then REPLY="${ESC}[38;5;114m"
    elif [ "$1" -lt 60 ]; then REPLY="${ESC}[38;5;226m"
    else                       REPLY="${ESC}[38;5;203m"
    fi
}

color_for_cache_pct() {
    if   [ "$1" -ge 60 ]; then REPLY="${ESC}[38;5;114m"
    elif [ "$1" -ge 30 ]; then REPLY="${ESC}[38;5;226m"
    else                       REPLY="${ESC}[38;5;203m"
    fi
}

model_label=''
if [ -n "$model_name" ]; then
    short="${model_name/Claude /}"
    short="${short/ Sonnet/S}"
    short="${short/ Haiku/H}"
    short="${short/ Opus/O}"
    short="${short/ (Extended Thinking)/}"
    [[ ${model_id,,} == *thinking* ]] && short="${short/ 🧠/}"
    [ -n "$effort_level" ] && short="${short} (${effort_level})"
    model_label="$short"
fi

normalize_path() {
    local p="${1//\\//}"
    if [[ "$p" =~ ^([A-Za-z]):(/.*)$ ]]; then
        p="/${BASH_REMATCH[1],,}${BASH_REMATCH[2]}"
    fi
    REPLY="$p"
}

git_branch=""
git_root=""
git_display_path=""
if [ -n "$cwd_path" ] && command -v git >/dev/null 2>&1; then
    _git_info=$(git -C "$cwd_path" --no-optional-locks rev-parse --abbrev-ref HEAD --show-toplevel 2>/dev/null)
    if [ -n "$_git_info" ]; then
        mapfile -t _gi <<< "$_git_info"
        git_branch="${_gi[0]}"
        [ "$git_branch" = "HEAD" ] && git_branch=""   # detached HEAD 對齊 --show-current 的空值語意
        git_root="${_gi[1]}"
    fi
    if [ -n "$git_root" ]; then
        normalize_path "${HOME:-$USERPROFILE}"; home_norm="$REPLY"
        normalize_path "$git_root"; git_root_norm="$REPLY"
        # 需比到路徑分界，否則 home=/c/users/foo 會把 /c/users/foobar/x 誤縮成 ~bar/x
        if [ -n "$home_norm" ] && { [ "$git_root_norm" = "$home_norm" ] || [[ "$git_root_norm" == "$home_norm"/* ]]; }; then
            git_display_path="~${git_root_norm#$home_norm}"
        else
            git_display_path="$git_root_norm"
        fi
    fi
fi

diff_ins=""
diff_del=""
if [ -n "$git_root" ]; then
    # 快取鍵改用 repo 路徑而非 session_id：這個值本質上屬於 repo，同一 repo 開多個
    # session 不該各自重算。純 bash 字元替換轉檔名（零 fork）；這是多對一的有損映射，
    # 下面的 git_root 全字串比對因此從「防禦性檢查」升級成「必要的碰撞偵測」，不可拿掉。
    _grk="${git_root//[^A-Za-z0-9._-]/_}"
    _gc="${TMPDIR:-/tmp}/claude_sl_git_${_grk:-default}"
    _gcached=()
    [ -r "$_gc" ] && mapfile -t _gcached < "$_gc"
    # 哨符確認完整性，並靠 git_root 全字串比對排除檔名碰撞 —— 換專案或碰撞時視同未命中
    if (( ${#_gcached[@]} == 5 )) && [ "${_gcached[4]}" = "END" ] \
       && [ "${_gcached[1]}" = "$git_root" ] \
       && (( EPOCHSECONDS - ${_gcached[0]:-0} < GIT_DIFF_TTL )); then
        diff_ins="${_gcached[2]}"
        diff_del="${_gcached[3]}"
    else
        # --ignore-submodules=dirty：全庫 diff 的耗時多數來自逐一掃描每個 submodule
        # worktree 是否 dirty，但這個資訊對 numstat 加總沒有貢獻；=dirty 只忽略這個，
        # gitlink 本身的變更（真正該顯示的）仍會照常回報，不可誤用 =all（那會連
        # gitlink 變更都一併藏起來）。無 submodule 的 repo 上此旗標為 no-op。
        _numstat=$(git -C "$git_root" --no-optional-locks diff --ignore-submodules=dirty HEAD --numstat 2>/dev/null)
        if [ -n "$_numstat" ]; then
            _ins=0; _del=0
            while read -r _a _b _; do
                isnum "$_a" && (( _ins += _a ))
                isnum "$_b" && (( _del += _b ))
            done <<< "$_numstat"
            diff_ins="$_ins"
            diff_del="$_del"
        fi
        printf '%s\n%s\n%s\n%s\nEND\n' "$EPOCHSECONDS" "$git_root" "$diff_ins" "$diff_del" > "$_gc"
    fi
fi

format_remaining() {
    num "$1"
    local diff=$(( REPLY - EPOCHSECONDS ))
    if [ "$diff" -le 0 ]; then REPLY="↺"; return; fi
    local days=$(( diff / 86400 )) hours=$(( (diff % 86400) / 3600 )) mins=$(( (diff % 3600) / 60 ))
    if   [ "$days"  -gt 0 ]; then REPLY="${days}d${hours}h"
    elif [ "$hours" -gt 0 ]; then REPLY="${hours}h${mins}m"
    else REPLY="${mins}m"
    fi
}

render_seg() {
    local label="$1" pct_raw="$2" resets_at="$3" color_fn="${4:-color_for_pct}"
    local pct bar col remaining
    printf -v pct "%.0f" "$pct_raw" 2>/dev/null || pct=0
    isnum "$pct" || pct=0
    make_bar "$pct"; bar="$REPLY"
    "$color_fn" "$pct"; col="$REPLY"
    if [ -n "$resets_at" ]; then
        format_remaining "$resets_at"; remaining="$REPLY"
        printf -v REPLY "${DIM}${label}${RESET}${col}${bar}${RESET} ${DIM}${pct}%%(${remaining})${RESET}"
    else
        printf -v REPLY "${DIM}${label}${RESET}${col}${bar}${RESET} ${DIM}${pct}%%${RESET}"
    fi
}

SEP="${DIM} | ${RESET}"

if [ -n "$used_pct" ]; then
    ctx_label="ctx "
    if [ -n "$ctx_used" ] && [ -n "$ctx_total" ]; then
        format_k "$ctx_used"; _ku="$REPLY"
        format_k "$ctx_total"; _kt="$REPLY"
        ctx_label="ctx ${_ku}/${_kt} "
    fi
    render_seg "$ctx_label" "$used_pct" "" "color_for_ctx_pct"; ctx_part="$REPLY"
else
    ctx_part="${DIM}ctx ░░░░░░ --%${RESET}"
fi

five_part=""
[ -n "$five_pct" ] && [ -n "$five_resets" ] && { render_seg "5H " "$five_pct" "$five_resets"; five_part="$REPLY"; }

week_part=""
[ -n "$week_pct" ] && [ -n "$week_resets" ] && { render_seg "7D " "$week_pct" "$week_resets"; week_part="$REPLY"; }

model_part=""
[ -n "$model_label" ] && model_part="${ESC}[38;5;111m${model_label}${RESET}"

_branch_inner="${ESC}[38;5;183m${git_branch}${RESET}"
num "${diff_ins:-0}"; _di=$REPLY
num "${diff_del:-0}"; _dd=$REPLY
if [ "$_di" -gt 0 ] || [ "$_dd" -gt 0 ]; then
    [ "$_di" -gt 0 ] && _branch_inner+=" ${ESC}[38;5;114m+${diff_ins}${RESET}"
    [ "$_dd" -gt 0 ] && _branch_inner+=" ${ESC}[38;5;203m-${diff_del}${RESET}"
fi

if [ -n "$git_display_path" ] && [ -n "$git_branch" ]; then
    git_part="${ESC}[38;5;183m${git_display_path}${RESET} ${DIM}(${RESET}${_branch_inner}${DIM})${RESET}"
elif [ -n "$git_display_path" ]; then
    git_part="${ESC}[38;5;183m${git_display_path}${RESET}"
else
    git_part=""
fi

update_part=""
if isnum "$transcript_mtime"; then
    printf -v _update_stamp '%(%y-%m-%d %H:%M:%S)T' "$transcript_mtime"
    [ -n "$_update_stamp" ] && update_part="${SOFT}更新 ${_update_stamp}${RESET}"
fi

cache_part=""
if isnum "$cache_read_tokens" && [ "$cache_read_tokens" -gt 0 ]; then
    format_k "$cache_read_tokens"; _cache="$REPLY"
    num "$cache_creation_tokens"; _cc=$REPLY
    num "$session_input_tokens"; _si=$REPLY
    _total_in=$(( cache_read_tokens + _cc + _si ))
    if [ "$_total_in" -gt 0 ]; then
        _hit_pct=$(( cache_read_tokens * 100 / _total_in ))
        color_for_cache_pct "$_hit_pct"; _col="$REPLY"
        cache_part="${DIM}cache ${_cache} ${RESET}${_col}●${RESET} ${DIM}${_hit_pct}%${RESET}"
    else
        cache_part="${DIM}cache ${_cache}${RESET}"
    fi
fi

turn_part=""
isnum "$turn_count" && [ "$turn_count" -gt 0 ] && turn_part="${DIM}turn ${turn_count}${RESET}"

# 讀整份檔案但不 fork：read -d '' 讀到 EOF 為止
slurp() {
    REPLY=''
    [ -r "$1" ] || return
    IFS= read -r -d '' REPLY < "$1"
    while [[ $REPLY == *$'\n' ]]; do REPLY="${REPLY%$'\n'}"; done
}

# hook 狀態檔與 transcript 內容都不受本腳本控制，可能含換行與連續空白；
# 一律壓成單行，否則會撐爛 status line 版面，也會破壞以行為單位的快取格式
flatten() {
    local s="${1//$'\n'/ }"
    s="${s//$'\r'/ }"
    while [[ $s == *"  "* ]]; do s="${s//  / }"; done
    REPLY="$s"
}

# session_id 會拼進檔名，只接受安全字元
_sid_safe=''
[[ $session_id =~ ^[A-Za-z0-9._-]+$ ]] && _sid_safe="$session_id"

state_part=""
hook_state=""
if [ -n "$_sid_safe" ]; then
    _sf="${TMPDIR:-/tmp}/claude_state_${_sid_safe}"
    [ -f "$_sf" ] && { slurp "$_sf"; flatten "$REPLY"; hook_state="$REPLY"; }
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

# 截斷長度沿用原本語意：此執行環境 locale 為 C，${#s} 與 ${s:0:120} 都以位元組計
truncate_line() {
    flatten "$1"
    local s="$REPLY"
    if [ "${#s}" -gt 120 ]; then s="${s:0:120}…"; fi
    REPLY="$s"
}

row3_part=""
row4_part=""

_user_text=""
if [ -n "$_sid_safe" ]; then
    _uf="${TMPDIR:-/tmp}/claude_last_user_${_sid_safe}"
    [ -f "$_uf" ] && { slurp "$_uf"; _user_text="$REPLY"; }
fi
[ -z "$_user_text" ] && _user_text="$transcript_user"
if [ -n "$_user_text" ]; then
    truncate_line "$_user_text"
    row3_part="${ESC}[38;5;245m▶ ${REPLY}${RESET}"
fi

_suppress_row4=0
if [ -n "$_sid_safe" ]; then
    _af="${TMPDIR:-/tmp}/claude_last_asst_${_sid_safe}"
    [ -f "$_af" ] && [ ! -s "$_af" ] && _suppress_row4=1
fi
if [ "$_suppress_row4" -eq 0 ] && [ -n "$transcript_asst" ]; then
    truncate_line "$transcript_asst"
    row4_part="${ESC}[38;5;245m◀ ${REPLY}${RESET}"
fi

line1=""
[ -n "$model_part"  ] && line1+="${model_part}"
[ -n "$git_part"    ] && line1+="${SEP}${git_part}"
[ -n "$update_part" ] && line1+="${SEP}${update_part}"

line2=""
[ -n "$cache_part" ] && line2+="${cache_part}"
[ -n "$turn_part"  ] && { [ -n "$line2" ] && line2+="${SEP}"; line2+="${turn_part}"; }
[ -n "$line2"      ] && line2+="${SEP}${ctx_part}" || line2="${ctx_part}"
[ -n "$five_part"  ] && line2+="${SEP}${five_part}"
[ -n "$week_part"  ] && line2+="${SEP}${week_part}"
[ -n "$state_part" ] && line2+="${SEP}${state_part}"

if [ -n "$row3_part" ] && [ -n "$row4_part" ]; then
    printf -v out "%s\n%s\n%s\n%s" "$line1" "$line2" "$row3_part" "$row4_part"
elif [ -n "$row3_part" ]; then
    printf -v out "%s\n%s\n%s" "$line1" "$line2" "$row3_part"
elif [ -n "$row4_part" ]; then
    printf -v out "%s\n%s\n%s" "$line1" "$line2" "$row4_part"
else
    printf -v out "%s\n%s" "$line1" "$line2"
fi

printf '%s' "$out"
# node 結果不完整時不寫快取，避免把損壞畫面留到下一次
(( _ok )) && [ -n "$sid" ] && printf '%s\n%s\nEND\n' "$EPOCHSECONDS" "$out" > "$cache"
exit 0
