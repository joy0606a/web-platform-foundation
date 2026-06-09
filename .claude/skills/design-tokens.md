---
name: design-tokens
description: How to use and extend the design token system. Use when styling components or adding visual values.
---

# Design tokens

Tokens are the single source of visual truth, defined as CSS custom properties in
`packages/ui/src/tokens.css`. Consistency and theming are properties of the tokens, not of
each contributor remembering the right value.

## Rules

- **Always `var(--token)`. Never a raw hex, rgb, or px** for anything a token exists for
  (color, spacing, radius, font size, shadow). A hardcoded value is a bug, not a shortcut.
- **Prefer semantic tokens over primitives.** Use `--color-primary`, not `--blue-500`, in
  components. Primitives exist only to feed semantic tokens.
- **Theming is automatic.** Dark mode redefines the semantic tokens (via
  `prefers-color-scheme` and `[data-theme="dark"]`). If a component only uses semantic
  tokens, it themes for free — verify your component in both themes.

## Adding a token

1. Check whether an existing semantic token already fits. Reuse beats adding.
2. If genuinely new: add the primitive (if needed), then a **semantic** token that names the
   _role_, not the value (`--color-danger`, not `--red`). Define it for both themes.
3. Use the semantic token in the component. Don't reference primitives outside `tokens.css`.

## Composing

Build components from tokens + layout; combine existing `@repo/ui` components rather than
re-styling from scratch. A new visual pattern that recurs becomes a shared component in
`packages/ui`, not a one-off in an app.
