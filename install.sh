#!/usr/bin/env bash
# Make this repo the primary skills source for Codex and Claude Code.
#
#   Codex:       ~/.agents/skills  -> this repo (whole-directory symlink)
#   Claude Code: ~/.claude/skills/<skill> -> this repo/<skill> (per skill, because
#                ~/.claude/skills also holds Claude-managed dirs like `synced/`)
#
# Usage: ./install.sh              # install / refresh
#        ./install.sh --uninstall  # remove all links into this repo
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
AGENTS_DIR="$HOME/.agents/skills"
CLAUDE_DIR="$HOME/.claude/skills"
UNINSTALL=false
[[ "${1:-}" == "--uninstall" ]] && UNINSTALL=true

# --- Codex: ~/.agents/skills -> repo ---------------------------------------
if $UNINSTALL; then
  if [[ -L "$AGENTS_DIR" && "$(readlink "$AGENTS_DIR")" == "$REPO" ]]; then
    rm "$AGENTS_DIR" && echo "removed  $AGENTS_DIR"
  fi
elif [[ -L "$AGENTS_DIR" && "$(readlink "$AGENTS_DIR")" == "$REPO" ]]; then
  :
elif [[ -e "$AGENTS_DIR" || -L "$AGENTS_DIR" ]]; then
  echo "skipped  $AGENTS_DIR already exists; move its skills into $REPO and remove it" >&2
else
  mkdir -p "$(dirname "$AGENTS_DIR")"
  ln -s "$REPO" "$AGENTS_DIR" && echo "linked   $AGENTS_DIR -> $REPO"
fi

# --- Claude Code: per-skill links ------------------------------------------
mkdir -p "$CLAUDE_DIR"
for link in "$CLAUDE_DIR"/* "$CLAUDE_DIR"/.[!.]*; do
  [[ -L "$link" ]] || continue
  dest="$(readlink "$link")"
  [[ "$dest" == "$REPO"/* ]] || continue
  if $UNINSTALL || [[ ! -f "$dest/SKILL.md" ]]; then
    rm "$link" && echo "removed  $link"
  fi
done

if ! $UNINSTALL; then
  for skill in "$REPO"/*/; do
    skill="${skill%/}"
    [[ -f "$skill/SKILL.md" ]] || continue
    link="$CLAUDE_DIR/$(basename "$skill")"
    if [[ -L "$link" ]]; then
      [[ "$(readlink "$link")" == "$skill" ]] && continue
      echo "skipped  $link (symlink to $(readlink "$link") already exists)" >&2
    elif [[ -e "$link" ]]; then
      echo "skipped  $link (non-symlink already exists)" >&2
    else
      ln -s "$skill" "$link" && echo "linked   $link -> $skill"
    fi
  done
fi
