# Brief templates

The coordinator fills in the template for the role and sends it as the whole
brief. Angle-bracket items are facts to fill in; everything else stays. See
[agent-team-playbook.md](agent-team-playbook.md) for which role to launch when.

Every brief ends with the same reporting block:

```
Report: post the full report to <issue or pull request link>, in a collapsed
section if long. Return to me 200 words or less: verdict or outcome first,
blocking items, links.
```

## spec-writer

```
Write the spec for <feature> (<issue link>). Save it to <path or page>.
Read: <standing rules>, <design or docs paths>, <code paths>.
Already decided, do not reopen: <list>.
Out of scope: <list, with issue links>.
```

## test-writer

```
Write failing tests for the approved spec <spec link> (<issue link>).
Branch: <name>. Test locations and style: <paths>.
Run with: <commands>. Existing tests must still pass.
Commit the tests alone, before any production code.
```

## test-reviewer

```
Review the tests in commit <sha> on <branch> against the spec <spec link>.
Run with: <commands>.
Blocking here means: a rule with no test, a wrong expected value, or a test a
wrong implementation would pass.
```

## implementer

```
Make the approved tests pass for <spec link> (<issue link>). Branch: <name>.
You may change: <paths>. Do not touch: <paths>, or the tests in <sha>.
Project rules that apply: <list>.
Must pass before you push: <commands>.
Open a pull request per the project's conventions.
```

## code-reviewer (first pass)

```
Review pull request <link> against the spec <spec link>. You did not write it.
Try to break it: <what to attack, from the spec's risks>.
Check the tests as well as the code:
- Compare the approved tests in <sha> with the head. Were any edited, weakened,
  skipped or deleted?
- Does any code special-case test inputs, hard-code expected values, or detect
  the test environment?
- Are the tests strong enough that a wrong implementation would fail?
Blocking means: a wrong result, data loss, a security problem, a crash, a hang,
or corrupted data or pages. List everything else as follow-ups.
Return each blocking finding with a reproduction and a failing test.
```

## fix-round

```
Fix these findings on <branch>, and only these: <numbered list, with the
reviewer's failing tests>.
You may change: <paths>. Must pass before you push: <commands>.
If a finding needs a new mechanism, stop and tell me before building it.
```

## recheck-reviewer

```
Re-check pull request <link> after fix round <n>. Earlier findings: <list>.
Review only the changes since <sha>. Run with: <commands>.
```

## referee

```
Rule on this dispute for pull request <link>: <one paragraph>.
Author's position: <summary>. Reviewer's position: <summary>.
Spec: <link>. Diff: <range>.
<If called after a second failed re-check:> Your ruling ends the review:
merge with follow-ups, back the approach out, or split the change.
```

## discovery

```
Establish these facts about <service>: <numbered questions>.
Look at: <docs links, endpoints, sample accounts>. Read only.
Save the findings table to <path or issue>.
```

## evaluator

```
Find out whether <approach> works for <problem> (<issue link>) and what it
costs. Questions: <numbered list>. Compare against: <current implementation>.
Branch: <name>, not for merging. Save the evaluation to <path or page>.
```

## clerk

```
Do these items in order: <numbered list, each with its source and target>.
Skip and report anything that needs a judgement call.
```
