# Onboarding

Welcome. This repo is built so you can contribute safely whether or not you're a frontend
specialist — the guardrails live in the setup, so most of the time you just follow the path.

## One-time setup

- Node 20+ and pnpm. Run `pnpm install` at the root.
- Optional but recommended: install [gitleaks](https://github.com/gitleaks/gitleaks) so the
  pre-commit secret scan runs locally too (CI runs it regardless).

## Everyday flow

1. **Branch off `main`:** `git switch -c feature/<name>`. (Or, in Claude Code, run
   `/foundation:new-feature <name>` — it creates the branch and walks you through the
   conventions. For non-trivial work, run `/foundation:goal <goal>` to drive the full
   explore → plan → critic → executor → review → verify pipeline.)
2. **Make your change.** Reuse `@repo/ui` components and design tokens — don't hardcode
   colors/spacing (see [`plugins/foundation/skills/design-tokens`](../plugins/foundation/skills/design-tokens)).
3. **Commit** in Conventional Commits form: `type(scope): subject`, where scope is the
   app/package you touched. The commit-msg hook validates this; the pre-commit hook formats
   and secret-scans.
4. **Push and open a PR.** CI runs lint, type-check, build, gitleaks, and `pnpm audit`.
5. **Squash-merge.** One PR = one revertable commit on `main`.

## If you're not a frontend developer

- Use `/foundation:new-feature` — it scaffolds the branch and tells you what to read and how
  to commit.
- The shared design tokens and components mean you get consistent UI without making visual
  decisions from scratch.
- The `code-reviewer` agent gives you a first review pass before a human looks at the PR.
- You can't easily do something destructive: [`.claude/settings.json`](../.claude/settings.json)
  denies dangerous commands, and nothing reaches `main` without passing CI and human review.

## Where to look

- [`docs/architecture/`](architecture/) — why the stack and tools are what they are. Read the
  relevant ADR before changing the thing it covers.
- [`plugins/foundation/`](../plugins/foundation/) — the agentic harness (agents, skills,
  hooks): code conventions, the security checklist, the design-token rules, and the `/goal`
  pipeline.

## Rolling back

See [ADR 0004](architecture/0004-commit-and-rollback.md). Short version: `git revert <sha>`
of the PR's squashed commit; for a release, redeploy the previous `app@YYYY.MM.DD` tag and
revert forward.
