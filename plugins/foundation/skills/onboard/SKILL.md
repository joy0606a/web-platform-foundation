---
name: onboard
description: Orient a new contributor to this monorepo — structure, conventions, design system, and workflow — grounded in the repo's own docs.
argument-hint: [optional area to focus on]
disable-model-invocation: true
context: fork
agent: onboarding-guide
---

Onboard a new contributor to this monorepo. Focus on "$ARGUMENTS" if provided; otherwise give
a general orientation.

Read the repo's own documentation and produce a concise, accurate orientation:

- **Structure** — the apps (`apps/web` React Router v7, `apps/docs` Vite SPA) and shared
  packages (`packages/ui` design system, `eslint-config`, `typescript-config`), and how apps
  consume shared config and `@repo/*` components.
- **Conventions** — the load-bearing ones: semantic design tokens only (never hardcoded
  visual values), shared code in packages not duplicated in apps, every async surface handles
  loading/error/empty, no `any`, named exports, accessibility as a baseline. Read the
  `code-convention` and `design-tokens` skills and `packages/ui/src/tokens.css`.
- **Docs** — `docs/onboarding.md` and the ADRs in `docs/architecture/`; the root `README.md`.
- **Workflow** — `pnpm dev | lint | check-types | build | test | test:e2e`, Conventional
  Commits, the code-review/verify gate, and the `/goal` pipeline for non-trivial work.

Point to the exact docs read so the contributor can go deeper, and recommend a first step
(`/foundation:new-feature <name>` for a guided change, or `/foundation:goal <goal>` for the
full pipeline). Keep it tight.
