#!/usr/bin/env sh
#
# web-setup.sh — make THIS personal agent-document library available inside a
# Claude Code on the Web session.
#
# Web sessions run in an ephemeral container: the working repo is cloned fresh
# and ~/.claude does NOT persist between sessions. This script repopulates the
# user-scope config (~/.claude/agents, /commands, /skills) on each session by
# cloning the library and symlinking its categories into place.
#
# Why this keeps your docs private to YOU:
#   - Claude Code on the Web setup scripts are configured per user / per
#     environment. They are NOT stored in the repo you are working on, so
#     teammates working in the same repo never run this script and never see
#     these documents.
#   - User scope (~/.claude/...) applies across all your repos but is invisible
#     to anyone else's session. Project scope (<repo>/.claude/... committed to
#     git) is the only thing the whole team shares — keep team docs there and
#     personal docs here.
#
# How to use (Claude Code on the Web):
#   1. Open your environment's configuration for the repo you work on.
#   2. Paste this script (or `sh /path/to/web-setup.sh`) into the setup script.
#   3. Save. It runs at session start and your personal docs are ready.
#
# This library is public and secret-free, so the clone below needs no
# credentials. If you fork it to a private repo, set AGENTS_LIB_REPO to a URL
# the environment can authenticate to.
#
# Override any of these by exporting them before the script runs:
AGENTS_LIB_REPO="${AGENTS_LIB_REPO:-https://github.com/andyvanosdale/agents}"
AGENTS_LIB_DIR="${AGENTS_LIB_DIR:-$HOME/.agents-lib}"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"

set -eu

# 1. Fetch (or update) the library. Idempotent across re-runs.
if [ -d "$AGENTS_LIB_DIR/.git" ]; then
  git -C "$AGENTS_LIB_DIR" pull --ff-only --quiet || true
else
  rm -rf "$AGENTS_LIB_DIR"
  git clone --depth 1 --quiet "$AGENTS_LIB_REPO" "$AGENTS_LIB_DIR"
fi

# 2. Symlink each category into user scope. We refuse to clobber a real
#    directory (something else owns it) but happily replace a stale symlink.
mkdir -p "$CLAUDE_DIR"
link_category() {
  category="$1"
  src="$AGENTS_LIB_DIR/$category"
  dest="$CLAUDE_DIR/$category"
  [ -d "$src" ] || return 0
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "web-setup: $dest exists and is not a symlink — leaving it untouched" >&2
    return 0
  fi
  ln -sfn "$src" "$dest"
  echo "web-setup: linked $dest -> $src"
}

link_category agents
link_category commands
link_category skills

# Note: settings.json is intentionally NOT symlinked. Symlinking the whole file
# would clobber other personal preferences and can carry hooks you may not want
# to run unattended. Copy the specific keys you want from settings/ by hand.

echo "web-setup: personal agent library ready in $CLAUDE_DIR"
