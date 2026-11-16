# Agent team playbook

How one coordinating agent runs a project by delegating: which agents exist,
when each is launched, on which model and at what effort, and why. The
procedure the coordinator follows is in
[`agents/coordinator.md`](../agents/coordinator.md); the briefs it sends are in
[brief-templates.md](brief-templates.md). This document holds the table and the
reasoning, and is the one to edit as experience comes in.

To use it in a project: link or copy the definitions in [`agents/`](../agents)
into the project, copy the [fragment](#fragment-for-a-projects-claudemd) at the
end into its `CLAUDE.md`, and start a session as the coordinator.

**Status: untested as written.** The roles and rules come from two projects run
by hand in roughly this way. The model and effort choices are judgement, not
measurement. The [trial section](#trial-what-to-watch) says what to record so
the table can be tuned.

## Principles

1. **Spend the most capable model only where judgement decides the outcome:**
   specs and disputes. Everything else runs on the cheapest model that does the
   job well.
2. **Tests come first and define done.** One agent writes the tests from the
   approved spec, another checks them, and only then does a third write code to
   pass them. The code reviewer checks the code did not cheat the tests.
3. **Every loop has an end.** Reviews are capped, and a referee's ruling closes
   a review that has not converged.
4. **State lives in issues,** so any coordinator, on any model, can take over.

Model names are tiers, not versions: **top** (the most capable, and the
scarcest), **strong**, **standard**, **small**. At the time of writing these are
Fable, Opus, Sonnet and Haiku. Update the mapping here when the line-up
changes.

## Roles

Where a role's model is the same every time, it is set in the definition. Where
it depends on the work, the coordinator sets it at launch. Effort is always
given at launch.

| Role | Agent | Launch when | Model | Effort |
|---|---|---|---|---|
| Coordinator | [`coordinator`](../agents/coordinator.md) | It is the main session for the project | Standard | Medium |
| Spec writer | [`spec-writer`](../agents/spec-writer.md) | A feature needs a spec, or a spec needs auditing against the code | Top | High |
| Referee | [`referee`](../agents/referee.md) | A second re-check failed, author and reviewer disagree, or a merge is borderline | Top | Medium, scoped to the dispute |
| Discovery | [`discovery`](../agents/discovery.md) | Facts about a real service are needed before a spec | Standard | Medium |
| Evaluator | [`evaluator`](../agents/evaluator.md) | A design choice would be costly to reverse | Strong | High |
| Test writer | [`test-writer`](../agents/test-writer.md) | A spec is approved | Critical: strong. Otherwise standard | High for critical, medium otherwise |
| Test reviewer | [`test-reviewer`](../agents/test-reviewer.md) | The tests are committed and failing | Critical: strong. Otherwise the opposite of the test writer | Medium |
| Implementer | [`implementer`](../agents/implementer.md) | The tests are approved | Critical: strong. Otherwise standard | High for critical, medium otherwise |
| Small change | [`tdd-engineer`](../agents/tdd-engineer.md) | A small fix, or a test-only or docs-only change, where splitting tests from code is not worth three launches | Standard | Medium |
| Pull request | [`pr-author`](../agents/pr-author.md) | A change is ready to open, update or merge | Same as the implementer | Low to medium |
| Code reviewer | [`code-reviewer`](../agents/code-reviewer.md) | A pull request is open; always a fresh session | Critical: strong. Otherwise the opposite of the implementer | High for critical, medium otherwise |
| Fix round | [`fix-round`](../agents/fix-round.md) | The reviewer listed blocking findings | Same as the implementer | Medium |
| Re-check | [`recheck-reviewer`](../agents/recheck-reviewer.md) | A fix round was pushed | Same reviewer session for the first re-check; a fresh session for the second | Medium |
| Trivial review | [`code-reviewer`](../agents/code-reviewer.md) | Test-only or docs-only change | Small or standard | Low |
| Clerk | [`clerk`](../agents/clerk.md) | A milestone merged and there is bulk mechanical follow-up | Small | Low |
| Project setup | [`project-setup`](../agents/project-setup.md) | A project starts, or its structure and docs need auditing | Standard | Medium |

"Critical" is declared by the project, by area or path, in its `CLAUDE.md`. The
coordinator looks it up and does not decide it.

## The pipeline

```
spec ──owner approves──▶ tests ──▶ test review ──▶ code ──▶ code review ──▶ merge
(top)                    (failing)   (1 fix round)          (2 fix rounds, then referee)
```

1. **Spec.** The spec writer drafts it with the owner's decisions at the top.
   Nothing proceeds until the owner approves.
2. **Tests.** The test writer turns every rule, "left alone" case and edge case
   into a failing test and commits them alone.
3. **Test review.** A different agent checks coverage, expected values and
   whether a wrong implementation could pass. One round of fixes.
4. **Code.** The implementer makes the tests pass. It may add tests. It may not
   change the approved ones; if it thinks one is wrong it stops and says so.
5. **Code review.** A fresh reviewer tries to break the change, and compares
   the approved tests with the head to check none was edited, weakened or
   skipped and that no code special-cases a test.
6. **Fix and re-check,** twice at most.
7. **Merge** on the reviewer's approval with CI green, where the project allows
   the coordinator to merge.

### Why tests are split from code

An agent that writes both the tests and the code tends to test what it built.
Splitting them means the tests are written from the spec by someone who has not
seen an implementation, and the implementer cannot move the goalposts. It also
moves the finding of missing cases to before the code exists, where it costs one
small launch and not a review round.

The split costs two extra launches per unit of work. That is why small changes
use a single test-first agent.

### Why reviews are capped

Each fix round adds code, and new code is where new defects come from. On one
project the third and fourth review rounds found real defects, and both were in
machinery added by earlier fix rounds. So:

- **Blocking** is defined narrowly: a wrong result, data loss, a security
  problem, a crash, a hang, or corrupted data or pages. Everything else becomes
  a follow-up issue.
- A fix round fixes the listed findings only, with the smallest change, and
  goes back to the coordinator before adding a new mechanism.
- After a **second failed re-check** the referee rules once: merge with
  follow-ups, back the approach out, or split the change. There is no third
  round.
- Everything a reviewer writes to reproduce a problem (cases, corpora, fuzz
  harnesses) is committed to the suite, so the build catches the regression
  next time and a reviewer does not have to.

## State lives in issues

- One **coordination issue** per project holds the order of work, what is in
  flight, the decisions waiting on the owner and which coordinator is active.
- Each **work issue** starts with a status block: stage, links, the next action.
- **Comments** record what changed and why, plus one fixed-format line per agent
  launch (role, model, effort, tokens, minutes, round, outcome).
- **Labels** carry the stage, so one query shows the project's state.
- The **owner answers decisions on the issue.** The coordinator does not send
  long reports in chat.

A file in the repository would need a pull request for every status change, and
a coordinator's conversation is lost when the session ends. Issues avoid both,
and the owner can read and answer them from anywhere. The exact formats are in
the coordinator definition.

Two cautions: issues on a public repository are public, so nothing private goes
in them; and two coordinators on one project must not run at once, which is
what the "active" line is for.

## Rules that keep the cost down

1. The coordinator reads summaries of 200 words or less. Full reports go on the
   issue or pull request.
2. The top model gets small, complete inputs: the issue, the standing rules and
   the paths for a spec; the diff and both positions for a dispute. Never the
   conversation.
3. Independence comes from a fresh session and an adversarial brief. Use a
   different model from the author where that does not put a weaker reviewer on
   critical work.
4. A resumed reviewer carries its whole history. Resume it once, then start
   fresh with the findings list.
5. Two units of work in flight at most.
6. Briefs are filled-in templates, not compositions.
7. Documents are brought in line once per milestone, after the code has stopped
   moving.

## Tuning per project

- Make the strong model the default for tests and code when the project's main
  risk is correctness in intricate logic.
- Skip the evaluator unless a design choice would be costly to undo.
- Fold the clerk into the coordinator when there are only one or two mechanical
  steps at a time.
- Widen what counts as a "small change" for projects where most work is wiring.

## Trial: what to watch

Collect from the `agent-run` lines and the issues, per project:

| Measure | Why |
|---|---|
| Tokens per merged unit of work, by role | Shows where the spend goes and which rows of the table to change |
| Review rounds per pull request, and how often the referee is called | Whether test-first is shortening review |
| Blocking findings in code review that a test should have caught | Whether the test writer and test reviewer are earning their launches |
| Times the owner corrected a brief, a stage or a decision | Whether a standard-model coordinator is good enough |
| Defects found after merge | Whether the caps are letting too much through |
| Units of work stalled on `needs-owner`, and for how long | Whether decisions are reaching the owner clearly |

The coordinator posts a **playbook trial report** on the coordination issue
after each merged unit of work: every agent launched, where it departed from
the playbook, what each prompt got wrong, and proposed edits. The format is in
the coordinator definition. Changes to this playbook are made from those
reports, by pull request, not by the coordinator during the trial.

### Running a trial before the definitions are installed

A coordinator can follow the playbook from a checkout of this repository
without installing anything: it reads the definition for a role, launches a
general-purpose agent on the model and effort the table gives, and passes the
definition's text followed by the filled-in brief as the prompt.

## Fragment for a project's CLAUDE.md

```md
## Agent team

This project is run by a coordinator following the agent team playbook.

- Coordination issue: <link>
- Specs live in: <location>. The owner approves specs.
- Critical areas (strong model for tests, code and review): <paths or topics>
- The coordinator may merge once the reviewer approves and CI is green: <yes/no>
- Commands: <install, typecheck, test, build, end-to-end>
- Differences from the playbook: <any role whose model or effort differs, and why>
```

## Open questions

- The best way to start a session as the coordinator (an agent definition, a
  `CLAUDE.md` fragment or a command) has not been settled.
- The `model` values in the definitions, and whether effort can be set in a
  definition's frontmatter, have not been checked against the documentation.

## Change log

Newest first. Record what changed and why, so the reasoning travels with the
table.

- **Test-first pipeline, issues as state, capped loops.** Added the test
  writer, test reviewer and implementer so tests are written and checked before
  code. Moved the coordinator's state and run log into issues so another
  coordinator can take over. Narrowed "blocking", capped fix rounds at two with
  a final referee ruling, and required reviewer reproductions to be committed.
  Added brief templates, project-declared critical areas, and the trial
  measures. Moved the procedure into the coordinator definition so it is stated
  once.
- **Initial version.** Built from two projects. Lessons behind the rules: the
  top model was spent on coordination and on reading long reports; every
  delegated session ran on the strong model at high effort whether or not the
  work needed it; reviews ran to four full rounds; and specs were revised while
  the code was still changing.
