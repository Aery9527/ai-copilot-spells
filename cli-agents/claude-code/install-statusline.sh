#!/usr/bin/env bash
# Installs the statusLine configuration and state-tracking hooks to ~/.claude.
# macOS/Linux counterpart of install-statusline.ps1; see that script's header
# comment for the four steps this performs.
#
# Hooks stay registered in shell form here (command="<bash> ~/.claude/hooks/...sh"),
# unlike the Windows installer's exec form: the extra fork this costs goes through a
# real POSIX fork(), not MSYS2's CreateProcess(SUSPENDED) emulation, so there's no
# zombie-on-teardown risk to design around on this platform.
#
# Usage: bash ./cli-agents/claude-code/install-statusline.sh [--force]
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

force=0
if [[ "${1:-}" == "--force" ]]; then
    force=1
fi

sh_src="$SCRIPT_DIR/statusline-command.sh"
hooks_src_dir="$SCRIPT_DIR/hooks"
claude_dir="$HOME/.claude"
sh_dst="$claude_dir/statusline-command.sh"
hooks_dst_dir="$claude_dir/hooks"
settings_path="$claude_dir/settings.json"

if [[ ! -f "$sh_src" ]]; then
    printf 'ERROR: Source not found: %s\n' "$sh_src" >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    printf 'ERROR: jq is required to safely edit settings.json. Install it first (e.g. "brew install jq"), then re-run this script.\n' >&2
    exit 1
fi

# --- Locate a Bash 5+ interpreter ---
# statusline-command.sh uses mapfile/${var,,}/EPOCHSECONDS/printf '%()T', and the hooks
# use `read -N` with a fractional timeout — all Bash 4/5-only. macOS ships Bash 3.2 as
# /bin/bash for licensing reasons and never upgrades it, so a bare "bash" in settings.json
# can silently resolve to an interpreter too old to run any of this. Resolve one specific,
# known-good interpreter now and pin its absolute path into settings.json instead.
find_bash5() {
    local candidates=() c major
    local path_bash
    path_bash=$(command -v bash 2>/dev/null || true)
    [[ -n "$path_bash" ]] && candidates+=("$path_bash")
    candidates+=(/opt/homebrew/bin/bash /usr/local/bin/bash /opt/local/bin/bash)

    for c in "${candidates[@]}"; do
        [[ -x "$c" ]] || continue
        major=$("$c" -c 'echo ${BASH_VERSINFO[0]}' 2>/dev/null || echo 0)
        [[ "$major" =~ ^[0-9]+$ ]] || continue
        if (( major >= 5 )); then
            printf '%s\n' "$c"
            return 0
        fi
    done
    return 1
}

bash5=$(find_bash5) || {
    printf 'ERROR: Bash 5+ not found (statusline-command.sh and the hooks need mapfile / EPOCHSECONDS / read -N, all Bash 4/5-only; macOS ships Bash 3.2 by default).\n' >&2
    printf 'Install one, e.g. "brew install bash", then re-run this script.\n' >&2
    exit 1
}
printf 'Using  : %s\n' "$bash5"

if [[ ! -d "$claude_dir" ]]; then
    mkdir -p "$claude_dir"
    printf 'Created: %s\n' "$claude_dir"
fi

copy_sh_file() {
    local src="$1" dst="$2"
    if [[ "$force" -eq 1 || ! -f "$dst" ]]; then
        cp -f "$src" "$dst"
        printf 'Copied : %s -> %s\n' "$src" "$dst"
        return
    fi
    if cmp -s "$src" "$dst"; then
        printf 'Skipped: %s (already up-to-date)\n' "$dst"
    else
        cp -f "$src" "$dst"
        printf 'Updated: %s\n' "$dst"
    fi
}

copy_sh_file "$sh_src" "$sh_dst"

if [[ -d "$hooks_src_dir" ]]; then
    if [[ ! -d "$hooks_dst_dir" ]]; then
        mkdir -p "$hooks_dst_dir"
        printf 'Created: %s\n' "$hooks_dst_dir"
    fi
    for f in "$hooks_src_dir"/*.sh; do
        [[ -e "$f" ]] || continue
        copy_sh_file "$f" "$hooks_dst_dir/$(basename "$f")"
    done
fi

if [[ ! -f "$settings_path" ]]; then
    printf '{}' > "$settings_path"
fi

# --- Inject statusLine ---
before=$(cat "$settings_path")
tmp=$(mktemp)
jq --arg cmd "\"$bash5\" ~/.claude/statusline-command.sh" \
    '.statusLine = {"type": "command", "command": $cmd}' \
    "$settings_path" > "$tmp" && mv "$tmp" "$settings_path"
after=$(cat "$settings_path")
if [[ "$before" != "$after" ]]; then
    printf 'Updated: statusLine in %s\n' "$settings_path"
else
    printf 'Skipped: statusLine already up-to-date in %s\n' "$settings_path"
fi

# --- Inject state-tracking hooks ---
# Always rebuild rather than "add if not already present": for each event, drop any
# handler exactly matching a command this installer has ever written for this script —
# the current pinned-bash5 form, or the literal pre-pinning legacy string ("bash <path>")
# — then re-add exactly one fresh, correct entry. Matching is exact string equality, not
# a suffix/wildcard: a third-party hook that wraps this same script (e.g. a profiling
# wrapper calling "bash ~/.claude/hooks/state-running.sh" with extra args around it)
# must never be silently deleted just because it happens to end the same way. The
# trade-off is that a registration pinned to a since-changed bash5 path (e.g. after a
# Homebrew upgrade) won't be recognized as stale and removed — it's left as a harmless
# duplicate rather than risking deletion of something we can't prove we own.
add_hook() {
    local event="$1" cmd="$2" legacy_cmd="$3" tmp
    tmp=$(mktemp)
    jq --arg event "$event" --arg cmd "$cmd" --arg legacy "$legacy_cmd" '
        .hooks[$event] = (
            ((.hooks[$event] // [])
                | map(.hooks = ((.hooks // []) | map(select(.command != $cmd and .command != $legacy))))
                | map(select((.hooks | length) > 0))
            ) + [{"hooks": [{"type": "command", "command": $cmd}]}]
        )
    ' "$settings_path" > "$tmp" && mv "$tmp" "$settings_path"
}

before=$(cat "$settings_path")
for pair in \
    'UserPromptSubmit|~/.claude/hooks/state-running.sh' \
    'PreToolUse|~/.claude/hooks/state-running.sh' \
    'Stop|~/.claude/hooks/state-idle.sh'
do
    event="${pair%%|*}"
    suffix="${pair#*|}"
    script_dst="$hooks_dst_dir/$(basename "$suffix")"
    if [[ ! -f "$script_dst" ]]; then
        printf 'ERROR: %s not found — hooks/ was not copied, refusing to register a dangling hook.\n' "$script_dst" >&2
        exit 1
    fi
    add_hook "$event" "\"$bash5\" $suffix" "bash $suffix"
done
after=$(cat "$settings_path")
if [[ "$before" != "$after" ]]; then
    printf 'Updated: hooks in %s\n' "$settings_path"
else
    printf 'Skipped: hooks already configured in %s\n' "$settings_path"
fi

printf '\n'
printf 'Done. Status line and state-tracking hooks are now active for all Claude Code sessions.\n'
