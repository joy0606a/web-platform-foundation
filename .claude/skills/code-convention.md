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
