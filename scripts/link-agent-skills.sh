#!/usr/bin/env bash
# ===========================================
# Agent Skills Linker (bash)
# 建立 .agents/skills → .claude/skills 的 symlink
#
# 用法:
#   ./script/link-agent-skills.sh    互動式選單
# ===========================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CLAUDE_SKILLS="$REPO_ROOT/.claude/skills"   # 真實目錄（source）
AGENTS_SKILLS="$REPO_ROOT/.agents/skills"   # symlink 位置（target）
GITIGNORE="$REPO_ROOT/.gitignore"

# ---------------------------------------------------------------------------
# Helper: Add entry to .gitignore (if not already present)
# ---------------------------------------------------------------------------
add_gitignore_entry() {
    local entry="$1"
    if [ ! -f "$GITIGNORE" ]; then
        echo "$entry" > "$GITIGNORE"
        echo "  [OK] Added '$entry' to .gitignore"
        return
    fi
    if ! grep -qxF "$entry" "$GITIGNORE"; then
        echo "$entry" >> "$GITIGNORE"
        echo "  [OK] Added '$entry' to .gitignore"
    else
        echo "  [--] '$entry' already in .gitignore"
    fi
}

# ---------------------------------------------------------------------------
# Helper: Remove entry from .gitignore
# ---------------------------------------------------------------------------
remove_gitignore_entry() {
    local entry="$1"
    if [ ! -f "$GITIGNORE" ]; then return; fi
    local tmp
    tmp="$(mktemp)"
    grep -vxF "$entry" "$GITIGNORE" > "$tmp" || true
    if ! diff -q "$GITIGNORE" "$tmp" > /dev/null 2>&1; then
        mv "$tmp" "$GITIGNORE"
        echo "  [OK] Removed '$entry' from .gitignore"
    else
        rm -f "$tmp"
    fi
}

# ---------------------------------------------------------------------------
# Menu
# ---------------------------------------------------------------------------
echo "=========================================="
echo "   Agent Skills Linker"
echo "=========================================="
echo ""
echo "  真實目錄: .claude/skills"
echo "  Symlink:  .agents/skills  ->  .claude/skills"
echo ""
echo "  [0] 取消"
echo "  [1] 將整個 .agents/skills 連結至 .claude/skills（單一 symlink）"
echo "  [2] 逐一將 .claude/skills 底下的每個 skill 連結至 .agents/skills"
echo "  [3] 取消連結（移除已建立的 symlink 與 gitignore 條目）"
echo ""
echo "=========================================="

read -rp "Enter your choice (0-3): " choice

case "$choice" in
    0)
        echo "Operation cancelled."
        exit 0
        ;;

    1)
        # Mode 1: Single symlink for the whole .agents/skills directory
        echo ""
        echo "Mode 1: 建立單一 symlink..."

        if [ ! -d "$CLAUDE_SKILLS" ]; then
            echo "ERROR: .claude/skills 不存在，請先建立真實目錄" >&2
            exit 1
        fi

        if [ -e "$AGENTS_SKILLS" ] || [ -L "$AGENTS_SKILLS" ]; then
            echo "  移除既有的 .agents/skills..."
            rm -rf "$AGENTS_SKILLS"
        fi

        ln -s "$CLAUDE_SKILLS" "$AGENTS_SKILLS"
        echo "  [OK] Symlink created: .agents/skills -> .claude/skills"

        add_gitignore_entry ".agents/skills"
        ;;

    2)
        # Mode 2: Per-skill symlinks
        echo ""
        echo "Mode 2: 建立逐個 skill symlink..."

        if [ ! -d "$CLAUDE_SKILLS" ]; then
            echo "ERROR: .claude/skills 不存在，請先建立真實目錄" >&2
            exit 1
        fi

        # Ensure .agents/skills is a real directory (not a symlink)
        if [ -L "$AGENTS_SKILLS" ]; then
            echo "  [!] .agents/skills 目前是 symlink，移除後重建為目錄..."
            rm -f "$AGENTS_SKILLS"
        fi
        mkdir -p "$AGENTS_SKILLS"

        # Create per-skill symlinks
        found_skills=false
        while IFS= read -r -d '' skill_path; do
            found_skills=true
            skill_name="$(basename "$skill_path")"
            link_path="$AGENTS_SKILLS/$skill_name"

            if [ -L "$link_path" ]; then
                echo "  [--] $skill_name: symlink 已存在，略過"
                add_gitignore_entry ".agents/skills/$skill_name"
                continue
            elif [ -e "$link_path" ]; then
                echo "  [!] $skill_name: 目標已存在但非 symlink，略過"
                add_gitignore_entry ".agents/skills/$skill_name"
                continue
            fi

            ln -s "$skill_path" "$link_path"
            echo "  [OK] $skill_name: symlink created"
            add_gitignore_entry ".agents/skills/$skill_name"
        done < <(find "$CLAUDE_SKILLS" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null)

        if [ "$found_skills" = false ]; then
            echo "  [!] .claude/skills 下沒有子目錄"
        fi

        # Cleanup: remove symlinks pointing to non-existent .claude/skills sources
        echo ""
        echo "  清理失效的 symlink..."
        removed=0
        while IFS= read -r -d '' item; do
            if [ -L "$item" ]; then
                target="$(readlink "$item")"
                if [[ "$target" == *"/.claude/skills/"* ]] && [ ! -e "$item" ]; then
                    skill_name="$(basename "$item")"
                    echo "  [RM] $skill_name: 來源已不存在，移除 symlink"
                    rm -f "$item"
                    remove_gitignore_entry ".agents/skills/$skill_name"
                    ((removed++)) || true
                fi
            fi
        done < <(find "$AGENTS_SKILLS" -maxdepth 1 -mindepth 1 -print0 2>/dev/null)
        ;;

    3)
        # Mode 3: Unlink
        echo ""
        echo "Mode 3: 取消連結..."

        if [ ! -e "$AGENTS_SKILLS" ] && [ ! -L "$AGENTS_SKILLS" ]; then
            echo "  [--] .agents/skills 不存在，無需清理"
            exit 0
        fi

        if [ -L "$AGENTS_SKILLS" ]; then
            # Case A: .agents/skills itself is a symlink
            rm -f "$AGENTS_SKILLS"
            echo "  [OK] 移除 symlink: .agents/skills"
            remove_gitignore_entry ".agents/skills"
        else
            # Case B: scan for per-skill symlinks pointing to .claude/skills
            removed=0
            while IFS= read -r -d '' item; do
                if [ -L "$item" ]; then
                    target="$(readlink "$item")"
                    if [[ "$target" == *"/.claude/skills"* ]]; then
                        skill_name="$(basename "$item")"
                        rm -f "$item"
                        echo "  [OK] 移除 symlink: .agents/skills/$skill_name"
                        remove_gitignore_entry ".agents/skills/$skill_name"
                        ((removed++)) || true
                    fi
                fi
            done < <(find "$AGENTS_SKILLS" -maxdepth 1 -mindepth 1 -print0 2>/dev/null)

            if [ "$removed" -eq 0 ]; then
                echo "  [--] 未找到指向 .claude/skills 的 symlink"
            fi
        fi
        ;;

    *)
        echo "Invalid choice." >&2
        exit 1
        ;;
esac

echo ""
echo "[OK] 完成"
