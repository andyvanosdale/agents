# Agent team playbook

Which agent does what, on which model, at what effort, when one coordinator
runs a project by delegating to other agent sessions. To use it in a project, link or copy the definitions in [`agents/`](../agents)
into the project, copy the [fragment](#fragment-for-a-projects-claudemd) at the
end into its `CLAUDE.md`, and adjust the rows that differ.

The aim is to spend the most capable model only where judgement decides the
outcome (specs and disputes) and to keep everything else on the cheapest model
that does the job well.

Model names are tiers, not versions: **top** (the most capable model you have,
and the scarcest), **strong**, **standard**, **small**. At the time of writing
these are Fable, Opus, Sonnet and Haiku. Update the mapping here when the
line-up changes; the roles should not need to.

## Roles

Each role is an agent definition in [`agents/`](../agents). Where the model is
the same every time it is set in the definition; where it depends on the work,
the coordinator sets it at launch.

| Role | Agent | Launch when | Model | Effort |
|---|---|---|---|---|
| Coordinator | [`coordinator`](../agents/coordinator.md) | It is the main session, for the whole project | Standard (Sonnet) | Medium |
| Spec writer | [`spec-writer`](../agents/spec-writer.md) | A feature needs a spec before code, a spec needs auditing against the code, or decisions need writing up | Top (Fable) | High |
| Referee | [`referee`](../agents/referee.md) | Author and reviewer disagree, a third review failed, or a merge is borderline | Top (Fable) | Medium, scoped to the dispute |
| Discovery | [`discovery`](../agents/discovery.md) | Facts about a real service or its docs are needed before building | Standard (Sonnet) | Medium |
| Evaluator | [`evaluator`](../agents/evaluator.md) | A design choice would be costly to reverse | Strong (Opus) | High |
| Author, critical | [`tdd-engineer`](../agents/tdd-engineer.md) | Security, credentials, anything that writes to someone's data, migrations, core logic where subtle errors are likely | Strong (Opus) | High |
| Author, ordinary feature | [`tdd-engineer`](../agents/tdd-engineer.md) | Wiring, UI pages, CLI commands, hosting config | Standard (Sonnet) | Medium to high |
| Author, follow-ups and docs | [`tdd-engineer`](../agents/tdd-engineer.md) | Batches of small fixes, test-only and docs-only changes | Standard (Sonnet) | Medium |
| Pull request | [`pr-author`](../agents/pr-author.md) | A change is ready to open, update or merge | Same as the author | Low to medium |
| Reviewer, first pass | [`code-reviewer`](../agents/code-reviewer.md) | A pull request is open; always a fresh session | Strong (Opus) for critical work; otherwise the opposite of the author | High for critical work, medium otherwise |
| Fix round | [`fix-round`](../agents/fix-round.md) | The reviewer listed findings | Same as the author | Medium |
| Reviewer, re-check | [`recheck-reviewer`](../agents/recheck-reviewer.md) | A fix round was pushed | Same reviewer for the first re-check; a fresh session after that | Medium |
| Reviewer, trivial change | [`code-reviewer`](../agents/code-reviewer.md) | Test-only or docs-only change | Small or standard (Haiku or Sonnet) | Low |
| Clerk | [`clerk`](../agents/clerk.md) | A milestone merged and there is bulk mechanical follow-up | Small (Haiku) | Low |
| Project setup | [`project-setup`](../agents/project-setup.md) | A new project starts, or an existing one needs its structure and docs audited | Standard (Sonnet) | Medium |

Effort is given in the launch, not in the definitions: this library does not
assume a frontmatter field for it.

## Rules that keep the cost down

1. **The coordinator never reads full reports.** Every agent writes its full
   report to a file and returns a summary of 200 words or less: verdict,
   blocking items, the file path.
2. **The top model gets small, complete inputs.** A spec writer gets the issue,
   the standing rules and the file paths. A referee gets the diff and both
   sides' summaries. Neither gets the conversation.
3. **Review is capped.** One full review, then at most two scoped re-checks.
   After that, anything that is not a wrong result, data loss or a security
   problem becomes a follow-up issue, and a remaining dispute goes to the
   referee.
4. **Independence comes from a fresh session and an adversarial brief.** Give a
   reviewer the change and the brief, never the author's conclusion. Use a
   different model from the author where that does not mean a weaker reviewer
   on critical work.
5. **A resumed reviewer carries its whole history.** Resume it for the first
   re-check, when that history helps. After that a fresh session with the
   findings list is cheaper.
6. **Two streams at most.** Draft specs one or two at a time, in the order the
   owner will approve them.
7. **The owner hears from the coordinator at decision points only:** a spec
   ready, a merge done, a decision needed.
8. **Reconcile documents once per milestone,** after the code has stopped
   moving, not during review.

## The flow

1. The coordinator picks the next issue. Discovery runs first if facts about an
   outside service are missing.
2. The spec writer drafts the spec, with the owner's decisions listed at the
   top. The owner approves or amends.
3. An author builds it on its own branch, with tests, and opens a pull request.
4. The first-pass reviewer reviews. A fix round addresses the listed findings.
   A re-check confirms.
5. The coordinator merges on the reviewer's approval, or calls the referee.
6. The clerk updates the decision log, the index and the follow-up issues.

## Briefs

A brief is the whole of what an agent knows. Each one states:

- **Goal** and the issue or spec it comes from.
- **Scope:** the files or directories it may change, and what it must not touch.
- **Standing rules** of the project that bear on this task.
- **Done means:** the commands that must pass and the tests that must exist.
- **Report:** where the full report goes and what the short summary contains.

For a reviewer, add what to attack and the bar for blocking. For a fix round,
list the findings and say "these only".

## Tuning per project

- Make the strong model the default author when the project's main risk is
  correctness in intricate logic.
- Skip the evaluator unless a design choice would be costly to undo.
- Drop the first-pass review to the standard model for low-risk changes.
- Fold the clerk into the coordinator when there are only one or two mechanical
  steps at a time.

## Fragment for a project's CLAUDE.md

```md
## Agent team

Roles, models and effort follow the agent team playbook. Differences for this
project:

- Critical work here means: <list the areas>.
- Specs live in: <location>. The owner approves specs.
- The coordinator may merge once the reviewer approves and CI is green.
- <any role whose model or effort differs, and why>
```

## Change log

Record what changed and why, newest first, so the reasoning travels with the
table.

- Initial version. Built from two projects run this way. Lessons behind the
  rules: the top model was being spent on coordination and on reading long
  reports; every delegated session ran on the strong model at high effort
  whether or not the work needed it; reviews ran to four full rounds; and specs
  were revised while the code was still changing.
