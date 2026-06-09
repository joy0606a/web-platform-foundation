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
.claude/              # vanilla agentic setup: rules, skills, reviewer agent, /new-feature, permissions
```

Tooling and guardrails:

- **Turborepo + pnpm** — monorepo with task caching and strict, phantom-dependency-free
  installs (see [ADR 0002](docs/architecture/0002-package-manager-pnpm.md)).
- **Husky + lint-staged** — format and secret-scan (gitleaks) staged files on every commit.
- **commitlint** — Conventional Commits enforced; squash-merge means one revertable commit
  per PR (see [ADR 0004](docs/architecture/0004-commit-and-rollback.md)).
- **eslint-plugin-security in the shared config** — every app and package inherits security
  rules automatically; contributors get them for free.
- **GitHub Actions** — CI (lint, type-check, build) and a Security workflow (gitleaks +
  `pnpm audit`) on every push and PR.
- **`.claude/`** — conventions injected automatically, a reviewer agent for the first review
  pass, and a guarded `/new-feature` path so contributors follow the rails by default.

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
pre-commit + commit-msg hooks, CI, and a vanilla agentic convention/reviewer setup.
What I'd add next, in roughly this order:

1. Component documentation and visual review (Storybook) + visual regression.
2. E2E and integration test setup (Playwright / Vitest) wired into CI.
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
