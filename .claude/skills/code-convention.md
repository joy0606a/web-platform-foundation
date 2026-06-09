---
name: code-convention
description: File structure, naming, and component/hook patterns for this monorepo. Use when creating or reviewing code here.
---

# Code conventions

## Where things go

- `apps/<name>/` — a deployable app. Keep app code thin; anything reusable moves to a package.
- `packages/<name>/` — shared code. `ui` (design system), `eslint-config`, `typescript-config`.
- Shared config is consumed, never copy-pasted. An app extends `@repo/eslint-config` and
  `@repo/typescript-config`; it does not redefine rules locally.

## Components

- Function components only. Props interface extends the underlying DOM element's attributes
  (e.g. `extends React.ButtonHTMLAttributes<HTMLButtonElement>`) so native props pass through.
- Styling via CSS Modules (`*.module.css`) reading `var(--token)` — never inline hardcoded
  colors/spacing. See skill `design-tokens`.
- Named exports for components (`export function Button`). One component family per file.
- A shared component lives in `packages/ui` and is exported via the package's `exports` map.

## Hooks

- Custom hooks start with `use`, live next to their feature or in a `hooks/` folder, and own
  one concern (data fetching, a piece of state, a subscription). Keep side effects in hooks,
  not in components.

## Tests

- Co-locate as `*.test.ts(x)` next to the unit under test. Test behaviour, not implementation.

## TypeScript

- No `any`. Prefer precise types and discriminated unions. Let inference work; annotate
  exported/public boundaries.

## Imports

- Use the workspace alias (`@repo/ui/...`) for shared packages, relative paths within a package.

## Specific rules (the load-bearing ones)

These are the few that prevent the bugs that actually cost time. Prefer a small set of
enforced rules over an exhaustive style guide nobody reads.

- **No business logic in components.** Calculations, validation, parsing, and data shaping go
  in hooks or `@repo/utils`, not inside JSX. This keeps logic testable (see
  [ADR 0005](../../docs/architecture/0005-testing-strategy.md)) and components dumb.
- **Every async surface handles all three states: loading, error, and empty** — explicitly,
  not just the happy path. A missing error state is the most common production gap.
- **No raw `fetch` scattered in components.** Data access goes through a typed client/hook so
  caching, errors, and auth are handled in one place.
- **Errors are values you handle, not strings you swallow.** No empty `catch`; either handle
  it or let it propagate to a boundary. User-facing errors never leak internals.
- **Accessibility is a baseline, not a feature:** semantic elements, labels on inputs,
  focus-visible states, and keyboard operability for anything interactive.
- **Server/client boundary is explicit.** Name and locate code so it's obvious what runs
  where; never import server-only modules into client bundles.

## How these conventions evolve

This set is a seed, not the finished rulebook. Real conventions get detailed by _accreting
from real incidents_, not by being invented up front. The process:

1. A pattern of feedback recurs in PR review (or a bug class repeats).
2. It gets written down here as a rule.
3. Where possible it's made mechanical — a lint rule, a commitlint rule, or a check in the
   `reviewer` agent — so it stops depending on memory.

The value of this repo isn't the length of this list; it's that the list is enforced and
that there's a defined path for it to grow.
