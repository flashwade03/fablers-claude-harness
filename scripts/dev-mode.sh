#!/bin/bash
# Toggle dev mode: symlink installed plugin cache directories to this local
# repo's `plugins/<name>/` sources so Claude Code loads live edits without
# reinstall.
#
# The marketplace-level symlink is not enough — Claude Code loads plugins
# from the per-version cache path recorded in installed_plugins.json, not
# from the marketplace directory. This script replaces those cache
# directories with symlinks to the repo sources.
#
# Usage:
#   bash scripts/dev-mode.sh --enable
#   bash scripts/dev-mode.sh --disable
#   bash scripts/dev-mode.sh --status
#
# After toggling, run `/reload-plugins` inside Claude Code to pick up
# frontmatter/manifest changes. Body-only edits take effect on the next
# skill invocation without a reload.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALLED_JSON="$HOME/.claude/plugins/installed_plugins.json"

# Plugins to manage: "<plugin_id>:<repo-subdir>"
PLUGIN_IDS=(
  "vibe-architecture@fablers:plugins/vibe-architecture"
  "damascus@fablers:plugins/damascus"
  "fablers-agentic-rag@fablers:plugins/fablers-agentic-rag"
)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
  cat <<EOF
Usage: $0 [--enable|--disable|--status]

  --enable   For each installed fablers plugin, backup its installed cache
             directory and symlink it to the matching repo subdirectory.
  --disable  Remove symlinks and restore backups.
  --status   Show per-plugin dev-mode state.

After toggling, inside Claude Code run /reload-plugins (or restart).
EOF
}

get_install_path() {
  local plugin_id="$1"
  [ -f "$INSTALLED_JSON" ] || return
  python3 - <<PY 2>/dev/null
import json, os, sys
path = os.path.expanduser("$INSTALLED_JSON")
try:
    data = json.load(open(path))
except Exception:
    sys.exit(0)
entries = data.get("plugins", {}).get("$plugin_id", [])
if entries:
    p = entries[0].get("installPath", "")
    p = p.replace("~", os.path.expanduser("~"))
    print(p)
PY
}

plugin_status() {
  local plugin_id="$1" repo_subdir="$2"
  local install_path
  install_path=$(get_install_path "$plugin_id")
  echo -e "${CYAN}$plugin_id${NC}"
  if [ -z "$install_path" ]; then
    echo -e "  ${RED}not installed${NC}"
    return
  fi
  echo "  installPath: $install_path"
  echo "  target:      $REPO_ROOT/$repo_subdir"
  if [ -L "$install_path" ]; then
    local linked
    linked=$(readlink "$install_path")
    if [ "$linked" = "$REPO_ROOT/$repo_subdir" ]; then
      echo -e "  state:       ${GREEN}ENABLED${NC} (symlink correct)"
    else
      echo -e "  state:       ${YELLOW}symlink, but to $linked${NC}"
    fi
  elif [ -d "$install_path" ]; then
    echo -e "  state:       ${YELLOW}DISABLED${NC} (real dir)"
    if [ -d "${install_path}.bak" ]; then echo -e "  backup:      ${YELLOW}${install_path}.bak exists${NC}"; fi
  else
    echo -e "  state:       ${RED}path missing${NC}"
  fi

  # Warn about stale higher-version dirs that would outrank our symlink
  local parent installed_version_name
  parent=$(dirname "$install_path")
  installed_version_name=$(basename "$install_path")
  if [ -d "$parent" ]; then
    local stale_found=""
    for entry in "$parent"/*/; do
      [ -e "$entry" ] || continue
      local name
      name=$(basename "${entry%/}")
      # Skip .bak and the install path itself
      [[ "$name" == *.bak ]] && continue
      [ "$name" = "$installed_version_name" ] && continue
      # Higher version dirs (lexicographic sort is a good enough heuristic for semver)
      if [[ "$name" > "$installed_version_name" ]]; then
        stale_found="$stale_found $name"
      fi
    done
    if [ -n "$stale_found" ]; then
      echo -e "  ${RED}WARNING${NC}: higher-version dirs present —${stale_found} — plugin loader picks these over your symlink!"
      echo -e "           Fix:    rm -rf${stale_found/#/ $parent/}"
    fi
  fi
}

plugin_enable() {
  local plugin_id="$1" repo_subdir="$2"
  local install_path target
  install_path=$(get_install_path "$plugin_id")
  target="$REPO_ROOT/$repo_subdir"

  if [ -z "$install_path" ]; then
    echo -e "${YELLOW}$plugin_id${NC}: not installed — skip (install it first with /plugin install)"
    return
  fi
  if [ ! -d "$target" ]; then
    echo -e "${RED}$plugin_id${NC}: repo target $target missing — skip"
    return
  fi
  if [ -L "$install_path" ]; then
    echo -e "${YELLOW}$plugin_id${NC}: already a symlink ($(readlink "$install_path")) — skip"
    return
  fi
  if [ ! -d "$install_path" ]; then
    echo -e "${RED}$plugin_id${NC}: install path $install_path missing — skip"
    return
  fi

  local backup="${install_path}.bak"
  if [ -d "$backup" ]; then
    echo -e "${YELLOW}$plugin_id${NC}: backup $backup already exists — removing current cache"
    rm -rf "$install_path"
  else
    echo -e "${CYAN}$plugin_id${NC}: backing up $install_path -> $backup"
    mv "$install_path" "$backup"
  fi
  ln -s "$target" "$install_path"
  echo -e "${GREEN}$plugin_id${NC}: linked $install_path -> $target"
}

plugin_disable() {
  local plugin_id="$1" _repo_subdir="$2"
  local install_path
  install_path=$(get_install_path "$plugin_id")

  if [ -z "$install_path" ]; then
    echo -e "${YELLOW}$plugin_id${NC}: not installed — skip"
    return
  fi
  if [ ! -L "$install_path" ]; then
    echo -e "${YELLOW}$plugin_id${NC}: not a symlink, nothing to disable — skip"
    return
  fi

  local backup="${install_path}.bak"
  rm "$install_path"
  if [ -d "$backup" ]; then
    echo -e "${CYAN}$plugin_id${NC}: restoring $backup -> $install_path"
    mv "$backup" "$install_path"
    echo -e "${GREEN}$plugin_id${NC}: restored"
  else
    echo -e "${YELLOW}$plugin_id${NC}: symlink removed but no backup found — reinstall needed"
  fi
}

do_status() {
  for entry in "${PLUGIN_IDS[@]}"; do
    plugin_id="${entry%%:*}"
    repo_subdir="${entry#*:}"
    plugin_status "$plugin_id" "$repo_subdir"
  done
  echo
  echo "Repo: $REPO_ROOT"
}

do_enable() {
  for entry in "${PLUGIN_IDS[@]}"; do
    plugin_id="${entry%%:*}"
    repo_subdir="${entry#*:}"
    plugin_enable "$plugin_id" "$repo_subdir"
  done
  echo
  echo "Next: inside Claude Code run /reload-plugins (or restart) to pick up manifest changes."
}

do_disable() {
  for entry in "${PLUGIN_IDS[@]}"; do
    plugin_id="${entry%%:*}"
    repo_subdir="${entry#*:}"
    plugin_disable "$plugin_id" "$repo_subdir"
  done
  echo
  echo "Next: inside Claude Code run /reload-plugins (or restart)."
}

case "${1:-}" in
  --enable)  do_enable ;;
  --disable) do_disable ;;
  --status)  do_status ;;
  *)         usage ;;
esac
