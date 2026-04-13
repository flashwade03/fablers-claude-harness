#!/bin/bash
# Toggle dev mode: symlink the fablers marketplace cache to this local repo
# so Claude Code loads plugins from here instead of the checked-out cache.
#
# Usage:
#   bash scripts/dev-mode.sh --enable   # backup cache + symlink this repo
#   bash scripts/dev-mode.sh --disable  # restore original cache
#   bash scripts/dev-mode.sh --status   # show current state
#
# After toggling, restart Claude Code for changes to take effect. You may
# also need to run /plugin marketplace update fablers inside Claude Code
# to pick up the new plugin roster (e.g., vibe-architecture replacing the
# old fablers-claude-harness).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MARKETPLACE_DIR="$HOME/.claude/plugins/marketplaces/fablers"
BACKUP_DIR="${MARKETPLACE_DIR}.bak"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

usage() {
  cat <<EOF
Usage: $0 [--enable|--disable|--status]

  --enable   Backup current marketplace cache and symlink this repo in its place
  --disable  Remove symlink and restore backup
  --status   Show current state

After toggling, restart Claude Code. Inside Claude Code you may need:
  /plugin marketplace update fablers
  /plugin install vibe-architecture@fablers
EOF
}

do_status() {
  if [ -L "$MARKETPLACE_DIR" ]; then
    local target
    target=$(readlink "$MARKETPLACE_DIR")
    echo -e "${GREEN}Dev mode: ENABLED${NC}"
    echo "  Symlink: $MARKETPLACE_DIR"
    echo "  Target:  $target"
    [ -d "$BACKUP_DIR" ] && echo "  Backup:  $BACKUP_DIR (present)"
  elif [ -d "$MARKETPLACE_DIR" ]; then
    echo -e "${YELLOW}Dev mode: DISABLED${NC}"
    echo "  Real directory: $MARKETPLACE_DIR"
    [ -d "$BACKUP_DIR" ] && echo "  Backup exists:  $BACKUP_DIR (stale?)"
  else
    echo -e "${RED}No fablers marketplace found at $MARKETPLACE_DIR${NC}"
    echo "Install first: /plugin marketplace add flashwade03/fablers-claude-plugins"
    exit 1
  fi
  echo "  Repo root: $REPO_ROOT"
}

do_enable() {
  if [ -L "$MARKETPLACE_DIR" ]; then
    echo -e "${YELLOW}Dev mode already enabled.${NC}"
    echo "  Symlink: $MARKETPLACE_DIR -> $(readlink "$MARKETPLACE_DIR")"
    exit 0
  fi

  if [ ! -d "$MARKETPLACE_DIR" ]; then
    echo -e "${RED}No fablers marketplace found at $MARKETPLACE_DIR${NC}"
    echo "Install it first inside Claude Code:"
    echo "  /plugin marketplace add flashwade03/fablers-claude-plugins"
    exit 1
  fi

  if [ -d "$BACKUP_DIR" ]; then
    echo -e "${YELLOW}Backup already exists at $BACKUP_DIR${NC}"
    echo "Removing current cache (old backup kept)..."
    rm -rf "$MARKETPLACE_DIR"
  else
    echo "Backing up: $MARKETPLACE_DIR -> $BACKUP_DIR"
    mv "$MARKETPLACE_DIR" "$BACKUP_DIR"
  fi

  ln -s "$REPO_ROOT" "$MARKETPLACE_DIR"
  echo -e "${GREEN}Dev mode enabled.${NC}"
  echo "  Symlink: $MARKETPLACE_DIR -> $REPO_ROOT"
  echo ""
  echo "Next steps:"
  echo "  1. Restart Claude Code"
  echo "  2. Inside Claude Code: /plugin marketplace update fablers"
  echo "  3. Inside Claude Code: /plugin install vibe-architecture@fablers"
}

do_disable() {
  if [ ! -L "$MARKETPLACE_DIR" ]; then
    echo -e "${YELLOW}Dev mode is not enabled (not a symlink).${NC}"
    exit 0
  fi

  rm "$MARKETPLACE_DIR"
  if [ -d "$BACKUP_DIR" ]; then
    echo "Restoring: $BACKUP_DIR -> $MARKETPLACE_DIR"
    mv "$BACKUP_DIR" "$MARKETPLACE_DIR"
    echo -e "${GREEN}Dev mode disabled. Original marketplace restored.${NC}"
  else
    echo -e "${YELLOW}Symlink removed but no backup found.${NC}"
    echo "Re-add the marketplace inside Claude Code if needed:"
    echo "  /plugin marketplace add flashwade03/fablers-claude-plugins"
  fi
  echo ""
  echo "Restart Claude Code for changes to take effect."
}

case "${1:-}" in
  --enable)  do_enable ;;
  --disable) do_disable ;;
  --status)  do_status ;;
  *)         usage ;;
esac
