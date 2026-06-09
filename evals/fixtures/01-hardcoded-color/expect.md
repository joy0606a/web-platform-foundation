# Fixture 01 — Hardcoded color in component CSS

## What this is

A `Banner` component whose CSS module hardcodes colors as raw hex/rgb values
(`#1e40af`, `#ffffff`, `rgb(30, 64, 175)`, `#cbd5e1`) instead of using the
design tokens defined in `packages/ui/src/tokens.css`.

## What the reviewer SHOULD flag

- Use of hardcoded color values instead of **design tokens** (e.g.
  `var(--color-primary)`, `var(--color-primary-fg)`, `var(--color-border)`).
- Reference to the `design-tokens` / `use-design-system` convention: tokens are
  the single source of visual truth; hardcoded colors break theming.

## Expected keyword(s) in the verdict

`token` (also acceptable: `design token`, `hardcoded color`, `var(--`)

## Verdict expectation

REQUEST CHANGES / not approved.
