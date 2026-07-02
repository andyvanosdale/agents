# Example CLAUDE.md fragment

Copy the sections you want into a project's `CLAUDE.md`. This is a starting
point, not a rule set to follow verbatim — tailor it to the project.

## Project conventions

- Describe the stack, build, and test commands here so a session can run them
  without guessing (e.g. `npm test`, `make lint`).
- Note any non-obvious layout: where source, tests, and generated files live.

## Working agreements

- Match the style of surrounding code; don't introduce new dependencies without
  reason.
- Run the test suite before declaring a change done; report failures honestly.
- Keep changes scoped to the request; flag unrelated issues instead of fixing
  them silently.
- **A declined or timed-out picker is not permission to pick a default.** When
  you ask the user to choose (e.g. an `AskUserQuestion` picker) and they decline,
  dismiss, or let it time out, treat the needed detail as still missing — the
  picker was raised precisely because you couldn't safely assume it. Do not
  fall back to a default and proceed; stop and get the answer another way, or
  surface that you're blocked on it, rather than guessing.

## Gotchas

- List the traps a newcomer hits: flaky tests, required env vars (named, never
  with values), services that must be running locally.
