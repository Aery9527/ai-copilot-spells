#!/usr/bin/env bash
# Installs the statusLine configuration and state-tracking hooks to ~/.claude.
# macOS/Linux counterpart of install-statusline.ps1; see that script's header
# comment for the four steps this performs.
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
jq '.statusLine = {"type": "command", "command": "bash ~/.claude/statusline-command.sh"}' \
    "$settings_path" > "$tmp" && mv "$tmp" "$settings_path"
after=$(cat "$settings_path")
if [[ "$before" != "$after" ]]; then
    printf 'Updated: statusLine in %s\n' "$settings_path"
else
    printf 'Skipped: statusLine already up-to-date in %s\n' "$settings_path"
fi

# --- Inject state-tracking hooks (idempotent: skip if the exact command is already registered) ---
add_hook() {
    local event="$1" cmd="$2" tmp
    tmp=$(mktemp)
    jq --arg event "$event" --arg cmd "$cmd" '
        .hooks[$event] = ((.hooks[$event] // []) as $entries |
            if ($entries | any(.hooks[]?.command == $cmd)) then
                $entries
            else
                $entries + [{"hooks": [{"type": "command", "command": $cmd}]}]
            end
        )
    ' "$settings_path" > "$tmp" && mv "$tmp" "$settings_path"
}

before=$(cat "$settings_path")
add_hook 'UserPromptSubmit' 'bash ~/.claude/hooks/state-running.sh'
add_hook 'PreToolUse'       'bash ~/.claude/hooks/state-running.sh'
add_hook 'Stop'             'bash ~/.claude/hooks/state-idle.sh'
after=$(cat "$settings_path")
if [[ "$before" != "$after" ]]; then
    printf 'Updated: hooks in %s\n' "$settings_path"
else
    printf 'Skipped: hooks already configured in %s\n' "$settings_path"
fi

printf '\n'
printf 'Done. Status line and state-tracking hooks are now active for all Claude Code sessions.\n'
