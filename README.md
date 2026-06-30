# agents

A public library of reusable **agent documents** for Claude Code — subagents,
slash commands, skills, and example settings. Meant to be browsed for ideas and
**symlinked (or copied) into your own projects** or your home config.

This repo ships **no secrets**. Every document here is safe to read and share.

## What's in here

| Directory   | Holds                                  | Claude Code looks for it under        |
|-------------|----------------------------------------|---------------------------------------|
| `agents/`   | Subagent definitions (`.md` + frontmatter) | `~/.claude/agents/`, `<proj>/.claude/agents/` |
| `commands/` | Slash commands (`.md`)                 | `~/.claude/commands/`, `<proj>/.claude/commands/` |
| `skills/`   | Skills (a folder per skill, with `SKILL.md`) | `~/.claude/skills/`, `<proj>/.claude/skills/` |
| `settings/` | Example `settings.json` / hook snippets | `~/.claude/settings.json`, `<proj>/.claude/settings.json` |
| `docs/`     | Reusable `CLAUDE.md` fragments to copy  | (copied into a project's `CLAUDE.md`) |

The directory names mirror what Claude Code resolves, so a symlink works with no
renaming.

## Using a document

**Link a single document into a project:**

```sh
ln -s "$PWD/agents/code-reviewer.md" /path/to/project/.claude/agents/
```

**Link a whole category into your home config (applies everywhere):**

```sh
ln -s "$PWD/agents" ~/.claude/agents
ln -s "$PWD/commands" ~/.claude/commands
```

**Prefer copying** if you want to edit a document without changing the shared
original:

```sh
cp agents/code-reviewer.md /path/to/project/.claude/agents/
```

## Using it everywhere, privately

To make this library your **personal** set of documents across all your repos —
including **Claude Code on the Web** — without those documents showing up in
teammates' sessions when you share a repo, see
[docs/personal-library-setup.md](docs/personal-library-setup.md). For web
sessions, [`scripts/web-setup.sh`](scripts/web-setup.sh) repopulates your
user-scope config (`~/.claude/...`) on each session from an environment setup
script.

> [!NOTE]
> Agent documents are **instructions** the model loads into context — and
> settings/hooks can run shell commands. Read a document before linking it, the
> same way you'd review code before running it. Everything here is yours; apply
> the same scrutiny to anything you pull in from elsewhere.

## Adding your own

See [CONTRIBUTING.md](CONTRIBUTING.md) for naming and frontmatter conventions.
