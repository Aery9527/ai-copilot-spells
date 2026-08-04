#!/usr/bin/env bash
# Bootstrap Codex CLI on macOS: npm (via Homebrew), the Codex CLI, then the pet sprites.
# Windows counterpart: install-cx.ps1 (uses winget instead of Homebrew).
#
# Usage: bash ./cli-agents/codex/install-cx.sh
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

printf '%s\n' '=== Step 2: Codex CLI ==='
npm install -g @openai/codex
printf '  [OK] Codex CLI installed/updated.\n'

printf '%s\n' '=== Step 3: pets ==='
pets_src="$SCRIPT_DIR/pets"
pets_dst="$HOME/.codex/pets"

if [[ ! -d "$pets_src" ]]; then
    printf 'ERROR: pets source not found: %s\n' "$pets_src" >&2
    exit 1
fi
mkdir -p "$pets_dst"
cp -Rf "$pets_src/." "$pets_dst/"
printf '  [OK] Copied: %s -> %s\n' "$pets_src" "$pets_dst"

printf '\n'
printf 'Done.\n'
