#!/usr/bin/env bash
# link-agent-skills.sh
# Creates symlinks for .agents/skills into .claude/skills
# Run from any location — script always resolves paths relative to itself.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_SKILLS="$REPO_ROOT/.agents/skills"
CLAUDE_SKILLS="$REPO_ROOT/.claude/skills"
GITIGNORE="$REPO_ROOT/.gitignore"

if [[ ! -d "$AGENTS_SKILLS" ]]; then
  echo "錯誤：找不到 $AGENTS_SKILLS" >&2
  exit 1
fi

echo "請選擇連結模式："
echo "  0) 取消"
echo "  1) 將整個 .claude/skills 連結至 .agents/skills（單一 symlink）"
echo "  2) 逐一將 .agents/skills 底下的每個 skill 連結至 .claude/skills（可重複執行：新增的 skill 會建立連結，已從 .agents/skills 移除的 skill 會同步清除連結與 .gitignore 條目）"
read -rp "請輸入選項 [0/1/2]：" choice

case "$choice" in
  1)
    if [[ -L "$CLAUDE_SKILLS" ]]; then
      rm "$CLAUDE_SKILLS"
    elif [[ -e "$CLAUDE_SKILLS" ]]; then
      rm -rf "$CLAUDE_SKILLS"
    fi
    ln -s "../.agents/skills" "$CLAUDE_SKILLS"
    echo "link  .claude/skills  →  ../.agents/skills"

    if ! grep -qxF ".claude/skills" "$GITIGNORE" 2>/dev/null; then
      echo ".claude/skills" >> "$GITIGNORE"
      echo "gitignore  .claude/skills"
    fi
    ;;

  2)
    mkdir -p "$CLAUDE_SKILLS"
    created=0
    skipped=0

    for skill_dir in "$AGENTS_SKILLS"/*/; do
      [[ -d "$skill_dir" ]] || continue
      skill_name="$(basename "$skill_dir")"
      target="$CLAUDE_SKILLS/$skill_name"
      rel_path="../../.agents/skills/$skill_name"
      gitignore_entry=".claude/skills/$skill_name"

      if [[ -e "$target" || -L "$target" ]]; then
        echo "略過  $skill_name  （已存在）"
        ((skipped++)) || true
      else
        ln -s "$rel_path" "$target"
        echo "link  $skill_name  →  $rel_path"
        ((created++)) || true
      fi

      if ! grep -qxF "$gitignore_entry" "$GITIGNORE" 2>/dev/null; then
        echo "$gitignore_entry" >> "$GITIGNORE"
        echo "gitignore  $gitignore_entry"
      fi
    done

    # 清理：移除 .claude/skills 中指向 .agents/skills 但來源已不存在的連結
    removed=0
    for existing_link in "$CLAUDE_SKILLS"/*/; do
      skill_name="$(basename "${existing_link%/}")"
      [[ -L "$CLAUDE_SKILLS/$skill_name" ]] || continue
      link_target="$(readlink "$CLAUDE_SKILLS/$skill_name")"
      [[ "$link_target" == *".agents/skills"* ]] || continue
      if [[ ! -d "$AGENTS_SKILLS/$skill_name" ]]; then
        rm "$CLAUDE_SKILLS/$skill_name"
        echo "移除  $skill_name  （.agents/skills 中已不存在）"
        ((removed++)) || true
        gitignore_entry=".claude/skills/$skill_name"
        if grep -qxF "$gitignore_entry" "$GITIGNORE" 2>/dev/null; then
          grep -vxF "$gitignore_entry" "$GITIGNORE" > "$GITIGNORE.tmp" && mv "$GITIGNORE.tmp" "$GITIGNORE"
          echo "gitignore 移除  $gitignore_entry"
        fi
      fi
    done

    echo ""
    echo "完成：新建 $created 個，略過 $skipped 個，移除 $removed 個"
    ;;

  0)
    echo "已取消"
    exit 0
    ;;

  *)
    echo "錯誤：無效的選項 '$choice'" >&2
    exit 1
    ;;
esac
