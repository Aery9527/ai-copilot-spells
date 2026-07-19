#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

if [[ -z "${HOME:-}" ]]; then
    printf '%s\n' 'ERROR: HOME is not set.' >&2
    exit 1
fi

rules_source="$SCRIPT_DIR/sys-prompt.md"
template_claude="$SCRIPT_DIR/claude-code/.claude/CLAUDE.md"
template_codex="$SCRIPT_DIR/codex/.codex/AGENTS.md"
template_copilot="$SCRIPT_DIR/github-copilot/.copilot/copilot-instructions.md"

for source in "$rules_source" "$template_claude" "$template_codex" "$template_copilot"; do
    if [[ ! -f "$source" ]]; then
        printf 'ERROR: Source file not found: %s\n' "$source" >&2
        exit 1
    fi
done

printf '%s\n' '=== Install system prompts ==='

target_claude="$HOME/.claude/CLAUDE.md"
target_codex="$HOME/.codex/AGENTS.md"
target_copilot="$HOME/.copilot/copilot-instructions.md"

mkdir -p "$(dirname "$target_claude")" "$(dirname "$target_codex")" "$(dirname "$target_copilot")"

cp -f "$template_claude" "$target_claude"
printf '  [OK] Template: %s\n' "$target_claude"
cp -f "$template_codex" "$target_codex"
printf '  [OK] Template: %s\n' "$target_codex"
cp -f "$template_copilot" "$target_copilot"
printf '  [OK] Template: %s\n' "$target_copilot"

cp -f "$rules_source" "$target_claude"
printf '  [OK] Rules:    %s\n' "$target_claude"
cp -f "$rules_source" "$target_codex"
printf '  [OK] Rules:    %s\n' "$target_codex"
cp -f "$rules_source" "$target_copilot"
printf '  [OK] Rules:    %s\n' "$target_copilot"

printf '%s\n' 'Done.'
