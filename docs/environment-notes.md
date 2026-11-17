# Environment notes

Facts about the places agents run that have cost a round to rediscover. The
coordinator reads this at the start and copies the notes that apply into each
brief's `Environment:` line. Add a note when a trial report shows an agent
lost time to something that is not about the project. Keep each one short: the
symptom, then what to do.

## GitHub from a Claude cloud session

- **Use REST, not GraphQL.** `gh issue create`, `gh pr create`, `gh pr review`
  and some forms of `gh issue view` and `gh pr view` fail with a GraphQL or
  permission error. Use `gh api repos/{owner}/{repo}/...` for issues, pull
  requests, comments, reviews, labels and merges.
- **`-F` reads a file, `-f` does not.** `gh api -F body=@path` sends the file's
  contents. `gh api -f body=@path` posts the literal text `@path`.
- **Read back what you posted.** After writing an issue, comment or pull
  request body from a file or a script, fetch it and check the first lines.
- **One account for everyone.** Every agent authenticates as the same account,
  and a platform will not let an account approve or request changes on its own
  pull request. Verdicts are carried in text (see the brief templates).
- **Opening a pull request may be refused** by the session's permission layer
  until the owner allows it. If an agent is refused, do not try the same action
  from another agent or from the coordinator: ask the owner once, and record
  the answer on the coordination issue.
- **A footer may be added to pull request bodies** by the host, and may return
  after being removed. It is cosmetic. Try once, note it, move on.
- **Sub-issues** are added with
  `POST /repos/{owner}/{repo}/issues/{parent}/sub_issues` and the child issue's
  `id`, not its number.
- **Pushing:** from a shallow clone, push with `git -c push.negotiate=true push`.
  Never force-push a shared branch.
- **Browser downloads are blocked.** Test tooling that downloads a browser will
  fail; use the one the environment provides, or run that step in CI.

## Squash merges

- A squash merge joins every commit message on the branch, trailers included,
  into the merge commit, and the platform may add co-author lines of its own.
  A trailer the project forbids, on any one commit, ends up on the default
  branch for good. Check commit messages before merging, and set the squash
  commit's title and message explicitly when merging.
