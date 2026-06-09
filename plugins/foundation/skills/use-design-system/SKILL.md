---
name: use-design-system
description: How to build UI in this monorepo using the design system — reuse @repo/ui components and consume semantic design tokens from packages/ui/src/tokens.css instead of hardcoding visual values. Use whenever editing components, styles, or app UI.
paths: "**/*.tsx, **/*.ts, **/*.css"
user-invocable: false
---

# Use the design system

When you touch UI in this repo, build from the design system, not from raw values.

## Tokens are the single source of visual truth

Visual values are CSS custom properties in **`packages/ui/src/tokens.css`**. Consistency and
theming are properties of the tokens, not of each contributor remembering the right value.

- **Always `var(--token)`. Never a raw hex, rgb, or px** for anything a token exists for —
  color, spacing, radius, font size, shadow. A hardcoded value is a bug, not a shortcut.
- **Prefer semantic tokens over primitives.** Use `--color-primary`, `--color-bg`,
  `--color-danger-*`, `--space-3`, `--radius-md`, `--text-base` in components — never a
  primitive like `--blue-500` directly. Primitives exist only to feed semantic tokens inside
  `tokens.css`.
- The current semantic set includes (see `tokens.css` for the authoritative list):
  `--color-bg`, `--color-fg`, `--color-muted`, `--color-border`, `--color-card`,
  `--color-primary`, `--color-primary-fg`; spacing `--space-1..6`; radius
  `--radius-sm|md|lg`; type `--font-sans`, `--font-mono`, `--text-sm|base|lg|xl`,
  `--leading-normal`; shadow `--shadow-sm|md`.

## Theming is automatic — keep it that way

Dark mode redefines the semantic tokens via `prefers-color-scheme: dark` and
`[data-theme="dark"]`. A component that reads only semantic tokens themes for free. The
contract: **consume semantic tokens only, and your component upholds light/dark
automatically.** If you find yourself adding a per-theme override, you are leaking a
hardcoded value somewhere — fix the token usage instead.

## Reuse components before building new ones

Shared components live in **`@repo/ui`** and are imported via the package's `exports` map —
e.g. `@repo/ui/button`, `@repo/ui/card`, `@repo/ui/code`. Compose existing components plus
layout before re-styling from scratch. A new visual pattern that recurs becomes a shared
component in `packages/ui`, not a one-off in an app. (This repo has **no Storybook** — the
source of truth is the components in `packages/ui/src` and the tokens file, not `*.stories.tsx`.)

## Adding a token (only when one genuinely doesn't exist)

1. Check whether an existing semantic token already fits. Reuse beats adding.
2. If genuinely new: add the primitive if needed, then a **semantic** token naming the _role_,
   not the value (`--color-danger-bg`, not `--red-100`). Define it for **both** themes
   (`:root`, the `prefers-color-scheme: dark` block, and `[data-theme="dark"]`).
3. Use the semantic token in the component. Never reference a primitive outside `tokens.css`.

## Example

```css
/* Don't — hardcoded values and a primitive token in a component */
.alert {
  color: #b91c1c;
  padding: 12px;
  background: var(--red-100);
}

/* Do — semantic tokens that theme automatically */
.alert {
  color: var(--color-danger-fg);
  padding: var(--space-3);
  background: var(--color-danger-bg);
}
```
