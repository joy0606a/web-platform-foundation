# Working in this repo

A monorepo foundation (pnpm + Turborepo) for multiple web apps that share one design
system, one set of conventions, and one set of guardrails. These rules are always loaded
so the conventions are enforced by the setup, not by anyone remembering them.

## Before you change something

- **Read the relevant ADR first.** Architecture decisions and their _why_ live in
  [`docs/architecture/`](docs/architecture/). Don't change the stack, the package
  manager, the security setup, or the commit/release flow without reading the ADR that
  covers it (and updating it if the decision changes).
- New to the repo? Start with [`docs/onboarding.md`](docs/onboarding.md).

## Hard rules

- **Write everything in English.** All code, comments, docs, ADRs, commit messages, and
  `.claude/` content are in English, regardless of the language of the conversation.
- **Don't trust stale assumptions about tooling.** Before configuring Claude Code, an SDK, or
  a framework, check the latest official docs rather than relying on memory. Use the
  `claude-docs` skill (it reads the live docs index and the relevant page).
- **Design tokens, never hardcoded values.** All color/spacing/radius/type comes from
  `var(--token)` (defined in `packages/ui/src/tokens.css`). See skill `design-tokens`.
- **Conventional Commits, scope = the package/app touched** (`web`, `docs`, `ui`,
  `eslint-config`, `tsconfig`, `claude`, `repo`). Enforced by commitlint. See ADR 0004.
- **Trunk-based:** branch `feature/*` off `main`, open a PR, **squash-merge** (one PR =
  one revertable commit). Never push to `main` directly; never force-push shared branches.
- **Run the security review before opening a PR.** See skill `security-review`.
- **Before marking work done, invoke the `code-reviewer` agent** (or run the full pipeline
  with `/foundation:goal`). This is not optional: a `Stop` hook blocks the turn from ending
  while there are uncommitted changes the code-reviewer hasn't approved. Human review still
  happens on the PR — the agent is the first pass, not a replacement.

## How enforcement is layered

- **Deterministic + fast → git hook** (pre-commit: format, secret scan).
- **Deterministic + slow → CI** (lint, type-check, build, test, audit, gitleaks).
- **Needs judgement → an agent/skill + a human** (the `code-reviewer` agent; PR review), made
  non-skippable by a `Stop` hook (`plugins/foundation/hooks/require-verify.sh`) that refuses to
  finish a turn with unreviewed uncommitted changes.

Permissions in [`.claude/settings.json`](.claude/settings.json) cap the blast radius (safe dev commands
are pre-approved; destructive ones are denied) so contributors — including non-frontend
ones — can work without either constant prompts or sharp edges.

## The agentic harness (the `foundation` plugin)

The agents, skills, and hooks live in a Claude Code plugin at
[`plugins/foundation/`](plugins/foundation/), enabled for this repo via `.claude/settings.json`.
Start any non-trivial work with the orchestrator:

- **`/foundation:goal <goal>`** — runs explore → plan → critic → executor → code-review →
  (security) → visual-verify, and judges done against the goal.

Skills it provides: `use-design-system`, `code-convention`, `security-review`, `design-tokens`,
`claude-docs` (always answer config questions from the latest official docs), `onboard`,
`new-feature`. Agents (each tuned with its own model + effort): `planner`, `critic`,
`executor`, `code-reviewer`, `security-reviewer`, `visual-verifier`, `onboarding-guide`. See
[ADR 0006](docs/architecture/0006-agentic-harness.md).
