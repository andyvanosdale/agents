#!/usr/bin/env sh
#
# web-setup.sh — make THIS personal agent-document library available inside a
# Claude Code on the Web session.
#
# Web sessions run in an ephemeral container: the working repo is cloned fresh
# and ~/.claude does NOT persist between sessions. This script repopulates the
# user-scope config (~/.claude/agents, /commands, /skills) on each session by
# fetching the library and symlinking its categories into place.
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
# A note on how the library is fetched. Claude Code on the Web routes EVERY
# `git` operation through a dedicated, scoped GitHub proxy. That proxy only
# honours the scoped credential git is given inside the working checkout, so a
# standalone `git clone`/`git pull` fired from a setup script is rejected with
# `HTTP 403` — even for a public repo. Ordinary HTTPS traffic uses a separate
# security proxy that DOES allow public GitHub downloads, so on the web we fetch
# the library as a public tarball instead of cloning it. On a normal machine
# `git` works fine and gives a real, updatable checkout, so we try that first
# and fall back to the tarball only when git is unavailable or blocked.
#
# This library is public and secret-free, so neither path needs credentials. If
# you fork it to a private repo, set AGENTS_LIB_REPO to a URL the environment
# can authenticate to (a private repo will require the git path — the anonymous
# tarball download will not work).
#
# Override any of these by exporting them before the script runs:
AGENTS_LIB_REPO="${AGENTS_LIB_REPO:-https://github.com/andyvanosdale/agents}"
AGENTS_LIB_BRANCH="${AGENTS_LIB_BRANCH:-main}"
AGENTS_LIB_DIR="${AGENTS_LIB_DIR:-$HOME/.agents-lib}"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"

set -eu

# Normalize the repo URL: strip any trailing slash or `.git` suffix so we can
# derive both the clone URL and the archive (tarball) URL from it.
AGENTS_LIB_REPO="${AGENTS_LIB_REPO%/}"
AGENTS_LIB_REPO="${AGENTS_LIB_REPO%.git}"

# 1a. Fetch (or update) the library via git. Works on a normal machine; on the
#     Web this is expected to fail (the git proxy returns 403), and we fall
#     through to the tarball path below. Called inside an `if`, so `set -e`
#     does not abort the script when git fails here.
fetch_via_git() {
  command -v git >/dev/null 2>&1 || return 1
  if [ -d "$AGENTS_LIB_DIR/.git" ]; then
    git -C "$AGENTS_LIB_DIR" pull --ff-only --quiet
  else
    rm -rf "$AGENTS_LIB_DIR"
    git clone --depth 1 --quiet --branch "$AGENTS_LIB_BRANCH" \
      "$AGENTS_LIB_REPO" "$AGENTS_LIB_DIR"
  fi
}

# 1b. Fetch the library as a public tarball over ordinary HTTPS. This bypasses
#     the git proxy entirely and needs no credentials for a public repo.
fetch_via_tarball() {
  tarball_url="$AGENTS_LIB_REPO/archive/refs/heads/$AGENTS_LIB_BRANCH.tar.gz"
  tmp_dir="$AGENTS_LIB_DIR.tmp.$$"
  rm -rf "$tmp_dir"
  mkdir -p "$tmp_dir"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$tarball_url" -o "$tmp_dir/lib.tar.gz"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$tmp_dir/lib.tar.gz" "$tarball_url"
  else
    echo "web-setup: need git, curl, or wget to fetch the library" >&2
    rm -rf "$tmp_dir"
    return 1
  fi

  # GitHub archives wrap everything in a single top-level "<repo>-<branch>/"
  # directory; --strip-components=1 drops it so files land at the root.
  mkdir -p "$tmp_dir/extracted"
  tar -xzf "$tmp_dir/lib.tar.gz" -C "$tmp_dir/extracted" --strip-components=1

  # Swap the freshly extracted tree into place.
  rm -rf "$AGENTS_LIB_DIR"
  mv "$tmp_dir/extracted" "$AGENTS_LIB_DIR"
  rm -rf "$tmp_dir"
}

if fetch_via_git 2>/dev/null; then
  echo "web-setup: library ready via git in $AGENTS_LIB_DIR"
else
  echo "web-setup: git unavailable or blocked (expected on Claude Code on the Web) — fetching tarball" >&2
  fetch_via_tarball
  echo "web-setup: library ready via tarball in $AGENTS_LIB_DIR"
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
