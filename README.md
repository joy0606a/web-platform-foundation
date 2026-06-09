# web-platform-foundation

A small, working reference for how I structure and unify web projects: a shared
design system, consistent tooling, security and quality guardrails built into the
shared config, an agentic setup that enforces the conventions, and CI — so a team
(including non-frontend contributors) can ship quickly without things drifting or
breaking.

Built incrementally with AI coding agents (Claude Code), and documented as I went.
Reading the commit history top to bottom tells the story; the _why_ behind each
decision is recorded as an ADR in [`docs/architecture/`](docs/architecture/).

> This is a **v1 reference**, scoped to be readable in a few minutes rather than a
> full production platform. The goal is to show the _shape_ of the foundation and
> the thinking behind it, not to be exhaustive.
>
> **The running apps are intentionally minimal** — they exist to exercise the shared
> layer, not to be a finished product. The substance is in the decisions
> ([`docs/architecture/`](docs/architecture/)), the enforcement
> ([`.claude/`](.claude/), CI, the git hooks), and the commit history — not in the
> screens. (Theming, for instance, is wired through tokens and follows your OS
> light/dark setting; there's deliberately no UI chrome built around it.)

## Why this exists

Web codebases tend to grow organically: a few apps, shared bits copy-pasted between
them, conventions that live in people's heads. That works until more people
contribute and the surface area grows, at which point quality and safety start to
depend on everyone remembering the rules. This repo is a small example of the
foundation I'd put underneath that growth so those properties hold as a team scales.

## What's here

```
apps/
  web/                # React Router v7 (framework mode, SSR) on Vite — the "complex app" end
  docs/               # plain Vite + React SPA — the "static/SPA" end; proves the layer across surfaces
packages/
  ui/                 # design system: tokens (tokens.css) + components that consume them
  eslint-config/      # shared lint config with security rules baked in (secure-by-default)
  typescript-config/  # shared tsconfig used across the monorepo
docs/
  architecture/       # ADRs — the decisions and their why
  onboarding.md       # how to contribute (including non-frontend contributors)
CLAUDE.md             # always-loaded project rules (docs-first, commit + token rules)
.claude/              # settings: permissions + enables the foundation plugin for this repo
.claude-plugin/       # marketplace.json — makes this repo installable as a plugin source
plugins/
  foundation/         # the agentic harness, packaged as a Claude Code plugin
                      #   /goal pipeline, model/effort-tuned agents, skills, review/verify hooks
```

Tooling and guardrails:

- **Turborepo + pnpm** — monorepo with task caching and strict, phantom-dependency-free
  installs (see [ADR 0002](docs/architecture/0002-package-manager-pnpm.md)).
- **Husky + lint-staged** — format and secret-scan (gitleaks) staged files on every commit.
- **commitlint** — Conventional Commits enforced; squash-merge means one revertable commit
  per PR (see [ADR 0004](docs/architecture/0004-commit-and-rollback.md)).
- **eslint-plugin-security in the shared config** — every app and package inherits security
  rules automatically; contributors get them for free.
- **GitHub Actions** — CI (lint, type-check, build, test) and a Security workflow (gitleaks +
  `pnpm audit`) on every push and PR.
- **Vitest + Playwright** — unit tests on business logic and an e2e smoke, both run in CI
  (see [ADR 0005](docs/architecture/0005-testing-strategy.md)).
- **The `foundation` plugin** ([`plugins/foundation/`](plugins/foundation/)) — the agentic
  harness packaged as a Claude Code plugin: a `/goal` orchestrator (explore → plan → critic →
  executor → code-review → security → visual-verify), agents tuned per stage with their own
  model + effort, design-system/security/docs skills, and a Stop hook that won't let a turn
  finish with unreviewed changes. Enabled for the repo via `.claude/settings.json` and
  installable elsewhere via the repo's `marketplace.json`. See
  [ADR 0006](docs/architecture/0006-agentic-harness.md).

## The idea: guardrails so more people can ship safely

The shared config is the point. Security rules, conventions, and types live in one
place that every app and package inherits. A new contributor — even one who isn't a
frontend specialist — gets the guardrails for free: the pre-commit hook catches
formatting and leaked secrets, CI catches lint/type/build and dependency advisories,
security lint rules are on by default, and `.claude/` injects the conventions while a
permission allow/deny list keeps destructive commands out of reach. The aim is for
"shipping stays safe as more people contribute" to be a property of the setup, not
something that depends on everyone remembering.

## What's a sample vs what I'd build next

Working here: the monorepo, a React Router + Vite app and a Vite SPA, a shared
token-driven design system, secure-by-default lint, secret scanning, dependency audit,
pre-commit + commit-msg hooks, unit tests (Vitest) and an e2e smoke (Playwright) in CI, and
the `foundation` agentic plugin (a `/goal` pipeline + agents/skills/hooks) whose code-reviewer
pass is enforced by a Stop hook.
What I'd add next, in roughly this order:

1. Component documentation and visual review (Storybook) + visual regression.
2. Broader test coverage — integration tests and more e2e along the critical paths.
3. Release automation (Changesets) and per-PR preview deployments (Cloudflare / Railway).

## How I'd approach unifying an existing setup

If I joined a codebase that had grown into separate stacks (say Astro, React, and
Next side by side), I wouldn't consolidate blindly:

1. **Understand why things grew the way they did first** — the split may exist for
   good reasons.
2. **Identify what genuinely benefits from a shared foundation** — design system,
   config, tooling, CI — versus what's fine staying separate.
3. **Build that shared layer first, then migrate one project at a time**, so the
   team keeps shipping and nothing breaks all at once.
4. **Put conventions, security rules, and CI guardrails in place from the start**,
   so quality holds as the migration proceeds.

The exact path always depends on the codebase. This repo is the shape of the
foundation I'd start from.

## Running it

```bash
pnpm install
pnpm dev          # run the apps
pnpm lint         # lint all packages
pnpm check-types  # type-check all packages
pnpm build        # build all apps and packages
```
