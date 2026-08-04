#!/usr/bin/env bash
# Bootstrap Claude Code on macOS: npm (via Homebrew), the Claude Code CLI, then the status line/hooks.
# Windows counterpart: install-cc.ps1 (uses winget instead of Homebrew).
#
# Usage: bash ./cli-agents/claude-code/install-cc.sh
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

printf '%s\n' '=== Step 1: npm ==='

if ! command -v brew >/dev/null 2>&1; then
    printf 'ERROR: Homebrew not found. Install it first (https://brew.sh), then re-run this script.\n' >&2
    exit 1
fi

if command -v npm >/dev/null 2>&1; then
    if brew list node >/dev/null 2>&1; then
        printf '  npm already installed via Homebrew, checking for updates...\n'
        brew upgrade node || printf '  Homebrew reported no upgrade needed for node.\n'
    else
        printf '  npm already installed but not via Homebrew (e.g. nvm or the official installer) - leaving it as-is, no update attempted.\n'
    fi
else
    printf '  npm not found, installing Node.js via Homebrew...\n'
    brew install node
fi

if ! command -v npm >/dev/null 2>&1; then
    printf 'ERROR: npm still not found after installation. Open a new shell and re-run this script.\n' >&2
    exit 1
fi
printf '  [OK] npm is available.\n'

printf '%s\n' '=== Step 2: Claude Code CLI ==='
npm install -g @anthropic-ai/claude-code
printf '  [OK] Claude Code CLI installed/updated.\n'

printf '%s\n' '=== Step 3: statusLine ==='
if ! command -v jq >/dev/null 2>&1; then
    printf '  jq not found, installing via Homebrew (required to safely edit settings.json)...\n'
    brew install jq
fi
bash "$SCRIPT_DIR/install-statusline.sh"

printf '\n'
printf 'Done.\n'
