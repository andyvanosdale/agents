# Using this library as your personal, per-user agent docs

This guide explains how to make this library available across **all** your
repos and in **Claude Code on the Web**, while keeping your documents out of
your teammates' sessions when you share a repo with them.

## The one principle

Claude Code resolves agent documents and settings from two scopes that matter
here:

| Scope | Locations | Applies to | Visible to teammates? |
|-------|-----------|------------|-----------------------|
| **User** | `~/.claude/agents`, `~/.claude/commands`, `~/.claude/skills`, `~/.claude/settings.json` | You, across every repo | **No** — never |
| **Project** | `<repo>/.claude/...` committed to git | Everyone who opens that repo | **Yes** |

So the rule that gives you private-but-everywhere docs:

> **Personal docs go in user scope. Only genuinely team-wide docs go in a
> repo's committed `.claude/`.** Never commit your personal agents, commands,
> or skills — or a `SessionStart` hook that loads them — into a shared repo;
> that is the one thing that would leak them into teammates' sessions.

This library is the source you fan out into **user scope**. Treat it as
personal-only: team docs belong in each project repo's committed `.claude/`,
not here.

## Local / desktop terminal

Clone the library once somewhere stable, then symlink the categories into your
home config:

```sh
git clone https://github.com/andyvanosdale/agents ~/code/agents
ln -s ~/code/agents/agents   ~/.claude/agents
ln -s ~/code/agents/commands ~/.claude/commands
ln -s ~/code/agents/skills   ~/.claude/skills
```

These now apply in every repo you open and appear in none of your teammates'
sessions. `git pull` in `~/code/agents` updates them everywhere at once.

For `settings.json`, do **not** symlink the whole file — copy just the keys you
want from [`settings/`](../settings) so it merges with your other personal
preferences instead of clobbering them.

## Claude Code on the Web

Web sessions run in an **ephemeral container**: the working repo is cloned
fresh and `~/.claude` does **not** persist between sessions. You therefore can't
pre-place symlinks — you repopulate user scope at session start.

The right lever is your **environment's setup script**, because environments
and their setup scripts are configured **per user / per environment** and are
**not** stored in the repo you work on. Your teammates work in their own
environments, so your setup script never runs for them.

Use [`scripts/web-setup.sh`](../scripts/web-setup.sh): paste it (or
`sh /path/to/web-setup.sh`) into your environment's setup script. It fetches
this library and symlinks `agents/`, `commands/`, and `skills/` into
`~/.claude` on each session. Because the library is public and secret-free, the
fetch needs no credentials.

Claude Code on the Web routes every `git` operation through a scoped GitHub
proxy, and a `git clone` fired from a setup script lacks the credential that
proxy expects — so it is rejected with `HTTP 403` (`Setup script failed with
exit code 128`), even for a public repo. The script sidesteps this by
downloading the library as a public tarball over ordinary HTTPS, which uses a
separate proxy that allows anonymous GitHub downloads. On a normal machine
`git` works, so the script prefers it and only falls back to the tarball when
git is unavailable or blocked. Forking to a *private* repo requires the git
path, since the anonymous tarball download won't authenticate.

Each engineer points their own environment's setup script at their own library,
so nobody's personal docs ever enter anyone else's session.

## What to avoid

- Committing your personal agents/commands/skills into a shared repo's
  `.claude/`.
- Putting a `SessionStart` hook that loads *your* tools into a shared repo's
  `.claude/settings.json` — committed hooks run for **every** teammate.
- Reserve a repo's committed `.claude/` strictly for documents the **whole
  team** should share on that repo. Use [`docs/example-CLAUDE.md`](example-CLAUDE.md)
  as a starting point for shared `CLAUDE.md` fragments.
