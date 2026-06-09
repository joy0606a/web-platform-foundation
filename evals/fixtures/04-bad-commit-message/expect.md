# Fixture 04 — Non-Conventional-Commit message

## What this is

`commit-message.txt` contains:

> fixed stuff and updated the dashboard plus some other tweaks

This violates the Conventional Commits convention enforced by this repo
(`commitlint.config.mjs` + `@commitlint/config-conventional`). It has no
`type(scope): subject` structure, uses past tense, is vague, and bundles
unrelated changes.

## What the reviewer SHOULD flag

- The message does not follow **Conventional Commits** (`feat:`, `fix:`,
  `chore:`, etc. with an imperative subject).
- It would be rejected by **commitlint** / the commit-msg git hook.

## Expected keyword(s) in the verdict

`conventional` (acceptable: `commit convention`, `commitlint`, `commit message`)

## Verdict expectation

REQUEST CHANGES — rewrite the commit message, e.g.
`feat(dashboard): show outstanding balance per user`.
