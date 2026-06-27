# Working in this repo

This is a public, secret-free library of agent documents. The conventions for
the documents themselves live in [CONTRIBUTING.md](CONTRIBUTING.md). This file
records how an agent (or contributor) should **work** in this repo.

## Pull requests

- **Every change ships via a pull request.** No direct commits to the default
  branch.
- **PRs are squashed and merged.** The squash commit message is taken from the
  prose summary paragraphs of the PR description.
- The agent performs its **own independent code review** of the change before
  requesting merge — it does not rely solely on CI or external reviewers.
- When responding to PR review comments, the agent may decide a change is or is
  not warranted, but **must request permission or ask for clarification** before
  acting — it does not silently apply or dismiss review feedback.

## PR description format

Keep the description **up to date** as new changes land on the branch.

1. **Summary** (required) — 1–3 prose paragraphs describing the problem and the
   change. Do **not** reference code symbols, other PRs, issues, or commits in
   this section. References to *other repositories* are allowed.
2. **Why** (optional) — motivation and background; references are allowed here.
3. **Changes** — a list of the files changed and what changed in each.
4. **Test Plan** (optional) — only extra testing needed **beyond what CI does**.
   Omit if CI fully covers it.
5. **Issues** (optional) — issues this PR resolves or fixes.
