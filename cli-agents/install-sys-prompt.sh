#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

if [[ -z "${HOME:-}" ]]; then
    printf '%s\n' 'ERROR: HOME is not set.' >&2
    exit 1
fi

common_prompt_source="$SCRIPT_DIR/common-prompt.md"
template_claude="$SCRIPT_DIR/claude-code/.claude/CLAUDE.md"
template_codex="$SCRIPT_DIR/codex/.codex/AGENTS.md"
template_copilot="$SCRIPT_DIR/github-copilot/.copilot/copilot-instructions.md"

for source in "$common_prompt_source" "$template_claude" "$template_codex" "$template_copilot"; do
    if [[ ! -f "$source" ]]; then
        printf 'ERROR: Source file not found: %s\n' "$source" >&2
        exit 1
    fi
done

printf '%s\n' '=== Install common prompts ==='

target_claude="$HOME/.claude/CLAUDE.md"
target_codex="$HOME/.codex/AGENTS.md"
target_copilot="$HOME/.copilot/copilot-instructions.md"

mkdir -p "$(dirname "$target_claude")" "$(dirname "$target_codex")" "$(dirname "$target_copilot")"

backup_suffix=$(date +%y%m%d%H%M%S)

backup_if_exists() {
    local target="$1"
    if [[ -f "$target" ]]; then
        local backup="${target}_${backup_suffix}"
        mv -f "$target" "$backup"
        printf '  [Backup] %s -> %s\n' "$target" "$backup"
    fi
}

backup_if_exists "$target_claude"
cp -f "$template_claude" "$target_claude"
printf '  [OK] Template: %s\n' "$target_claude"
backup_if_exists "$target_codex"
cp -f "$template_codex" "$target_codex"
printf '  [OK] Template: %s\n' "$target_codex"
backup_if_exists "$target_copilot"
cp -f "$template_copilot" "$target_copilot"
printf '  [OK] Template: %s\n' "$target_copilot"

printf '\n' >> "$target_claude"
cat "$common_prompt_source" >> "$target_claude"
printf '  [OK] Common prompt: %s\n' "$target_claude"
printf '\n' >> "$target_codex"
cat "$common_prompt_source" >> "$target_codex"
printf '  [OK] Common prompt: %s\n' "$target_codex"
printf '\n' >> "$target_copilot"
cat "$common_prompt_source" >> "$target_copilot"
printf '  [OK] Common prompt: %s\n' "$target_copilot"

printf '%s\n' 'Done.'
