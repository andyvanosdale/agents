# Example CLAUDE.md fragment

Copy this into a project's `CLAUDE.md`. The **Working agreements** below are
concrete rules an agent can follow as-is. The **Project facts** section is the
only part you must fill in for your project — tailor it, or delete lines that
don't apply.

## Working agreements

- Match the style of surrounding code; don't introduce new dependencies without
  reason.
- Keep changes scoped to the request; flag unrelated issues instead of fixing
  them silently.
- Verify before declaring a change done: run the relevant tests (or exercise the
  affected flow) and report honestly — what you ran, what passed or failed, and
  what you skipped. Don't claim done on an unverified change.

### Handle uncertainty by asking, not guessing

- When the request is ambiguous, or a decision is genuinely the user's to make,
  ask before acting rather than picking a direction and running with it.
- **A declined or timed-out picker is not permission to pick a default.** When
  you ask the user to choose (e.g. an `AskUserQuestion` picker) and they decline,
  dismiss, or let it time out, treat the needed detail as still missing — the
  picker was raised precisely because you couldn't safely assume it. Do not fall
  back to a default and proceed; stop and get the answer another way, or surface
  that you're blocked on it, rather than guessing.

### Version control

- **Every change ships via a pull request. Never commit directly to the default
  branch.** If work is sitting on the default branch, branch first, using a
  short kebab-case name describing the change.
- Write clear, descriptive commit messages. Keep the PR description current as
  the branch evolves, so it always reflects the change's present state.

### Safety

- **No secrets.** Never commit API keys, tokens, credentials, internal
  hostnames, or private paths. Read your own diff before pushing — the
  `.gitignore` is a backstop, not a substitute.

## Project facts (fill these in)

- **Build / test / lint commands** so a session can run them without guessing
  (e.g. `npm test`, `make lint`).
- **Layout:** where source, tests, and generated files live, and any non-obvious
  structure.
- **Gotchas:** the traps a newcomer hits — flaky tests, required env vars (named,
  never with values), services that must be running locally.
