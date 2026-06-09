# Working in this repo

A monorepo foundation (pnpm + Turborepo) for multiple web apps that share one design
system, one set of conventions, and one set of guardrails. These rules are always loaded
so the conventions are enforced by the setup, not by anyone remembering them.

## Before you change something

- **Read the relevant ADR first.** Architecture decisions and their _why_ live in
  [`docs/architecture/`](../docs/architecture/). Don't change the stack, the package
  manager, the security setup, or the commit/release flow without reading the ADR that
  covers it (and updating it if the decision changes).
- New to the repo? Start with [`docs/onboarding.md`](../docs/onboarding.md).

## Hard rules

- **Design tokens, never hardcoded values.** All color/spacing/radius/type comes from
  `var(--token)` (defined in `packages/ui/src/tokens.css`). See skill `design-tokens`.
- **Conventional Commits, scope = the package/app touched** (`web`, `docs`, `ui`,
  `eslint-config`, `tsconfig`, `claude`, `repo`). Enforced by commitlint. See ADR 0004.
- **Trunk-based:** branch `feature/*` off `main`, open a PR, **squash-merge** (one PR =
  one revertable commit). Never push to `main` directly; never force-push shared branches.
- **Run the security review before opening a PR.** See skill `security-review`.
- **Before marking work done, invoke the `reviewer` agent.** Human review still happens on
  the PR — the agent is the first pass, not a replacement.

## How enforcement is layered

- **Deterministic + fast → git hook** (pre-commit: format, secret scan).
- **Deterministic + slow → CI** (lint, type-check, build, audit, gitleaks).
- **Needs judgement → an agent/skill + a human** (the `reviewer` agent; PR review).

Permissions in [`settings.json`](settings.json) cap the blast radius (safe dev commands
are pre-approved; destructive ones are denied) so contributors — including non-frontend
ones — can work without either constant prompts or sharp edges.

## Skills available

- `code-convention` — file structure, naming, component/hook patterns, where tests go.
- `security-review` — OWASP Top 10 checklist for this codebase.
- `design-tokens` — how to use and extend the token system.
