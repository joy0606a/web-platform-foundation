# 0004 — Commit convention & rollback strategy

- Status: accepted
- Date: 2026-06-09

## Context

In a monorepo where many people (and agents) contribute, the git history is shared
infrastructure. It needs to answer two questions cheaply: _what changed and why?_ and
_how do I undo exactly this — and nothing else — if it breaks in production?_ A
convention that only lives in people's heads won't survive growth.

## Decision

**Trunk-based with short-lived branches.** `main` is always releasable. Work happens on
`feature/*` branches and lands via PR. (See [onboarding](../onboarding.md) for the flow.)

**Conventional Commits, enforced.** Every message is `type(scope): subject`, validated by
commitlint in a commit-msg hook (see [commitlint.config.mjs](../../commitlint.config.mjs)).
`scope` is the package/app touched (`web`, `docs`, `ui`, `eslint-config`, …) — so the
scope alone tells you which surface a change affects, which matters in a monorepo where one
history spans many projects.

**Squash-merge, so one PR = one commit on `main`.** This is the core of the rollback
story: each merged PR collapses to a single, atomic, conventional commit. Reverting a
feature is therefore `git revert <sha>` of one commit — no hunting across a range, no
half-reverted state.

**Release tags.** Releases are tagged per app as `web@YYYY.MM.DD` (e.g. `web@2026.06.09`),
giving a named point to roll back _to_ and a stable reference for "what's in production".
A machine-readable history (Conventional Commits) means a changelog can be derived from the
tag range automatically.

### Rollback runbook

- **Revert one feature:** `git revert <merge-commit-sha>`, open as a PR (CI re-runs). Clean
  because the PR was squashed to one commit.
- **Roll back a release:** redeploy the previous `app@date` tag; then `git revert` the
  offending commit(s) forward so `main` reflects reality.

## Consequences

- Positive: history is readable and machine-parseable; rollback is a one-commit operation;
  scope makes monorepo blast-radius obvious at a glance; changelogs are derivable.
- Negative: squash loses intra-PR commit granularity (mitigated by keeping PRs small and
  focused); contributors must learn the convention (mitigated by the hook rejecting bad
  messages with a helpful error).

## Alternatives considered

- **Merge commits / rebase-merge** preserve every commit but make "revert exactly this
  feature" a multi-commit, error-prone operation; rejected in favour of squash.
- **Changesets for versioning** — excellent for published packages and automated changelogs;
  deferred. The tag convention here covers the need at this stage without the extra
  machinery; adopt Changesets when packages are actually published.
