# Contributing a document

This is a public, secret-free library. Documents are meant to be copied or
symlinked into other people's projects, so they need to be self-contained and
safe to read.

## Rules

1. **No secrets.** No API keys, tokens, internal hostnames, or private paths.
   The `.gitignore` blocks common offenders, but it is not a substitute for
   reading your own diff.
2. **No machine-specific assumptions.** Avoid absolute paths and hard-coded
   usernames; a document should drop into any project unchanged.
3. **Write `description` for *when to use*, not *what it is*.** The model
   matches subagents and skills against their `description`, so phrase it as a
   trigger ("Use when reviewing a diff for...").
4. **Name files for what they do**, lowercase-with-hyphens. Examples here are
   prefixed `example-`; drop that prefix for real documents.

## Formats

### Subagent — `agents/<name>.md`

```md
---
name: code-reviewer
description: Use when reviewing a diff for correctness and clarity issues.
tools: Read, Grep, Glob
---

<system prompt / instructions for the subagent>
```

### Slash command — `commands/<name>.md`

```md
---
description: One-line summary shown in the command list.
---

<the prompt that runs when the command is invoked; use $ARGUMENTS for input>
```

### Skill — `skills/<name>/SKILL.md`

```md
---
name: pr-summary
description: Use when the user asks for a summary of a pull request's changes.
---

<instructions; supporting files can live alongside SKILL.md in the folder>
```

### Settings — `settings/<name>.json`

Illustrative only. Keep hooks obviously safe and explain what they do in a
comment or the README. Never include real credentials.

### GitHub templates — `.github/`

Issue and pull request templates follow GitHub's fixed locations and names
(`.github/ISSUE_TEMPLATE/<name>.md`, `.github/ISSUE_TEMPLATE/config.yml`,
`.github/pull_request_template.md`), which take precedence over the naming
rule above. They are live for this repo and meant to be copied into another
project's `.github/` unchanged.
