# web-platform-foundation

A small, working reference for how I structure and unify web projects: a shared
design system, consistent tooling, security and quality guardrails built into the
shared config, and CI — so a team (including non-frontend contributors) can ship
quickly without things drifting or breaking.

Built incrementally with AI coding agents (Claude Code), and documented as I went.

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
  web/                # sample Next.js app consuming the shared packages
  docs/               # a second app — proves the shared layer works across surfaces
packages/
  ui/                 # design system: shared components + a place for tokens
  eslint-config/      # shared lint config with security rules baked in (secure-by-default)
  typescript-config/  # shared tsconfig used across the monorepo
```

Tooling and guardrails:

- **Turborepo** for the monorepo structure and task caching.
- **Husky + lint-staged** — format staged files on every commit, so unformatted
  code never lands.
- **eslint-plugin-security in the shared config** — every app and package inherits
  security rules automatically; contributors get them for free.
- **GitHub Actions CI** — lint, type-check, and build on every push and PR.
- **Prettier + shared ESLint / TS config** — one consistent style across all packages.

## The idea: guardrails so more people can ship safely

The shared config is the point. Security rules, conventions, and types live in one
place that every app and package inherits. A new contributor — even one who isn't a
frontend specialist — gets the guardrails for free: the pre-commit hook catches
formatting, CI catches lint/type/build, and security lint rules are on by default.
The aim is for "shipping stays safe as more people contribute" to be a property of
the setup, not something that depends on everyone remembering.

## What's a sample vs what I'd build next

Working here: the monorepo, shared design system, secure-by-default lint, pre-commit
hooks, and CI. What I'd add next, in roughly this order:

1. Component documentation and visual review (Storybook) + visual regression.
2. E2E and integration test setup (Playwright / Vitest) wired into CI.
3. Release/versioning automation and per-PR preview deployments.
4. A "paved path" generator so non-frontend contributors can scaffold compliant code.

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
