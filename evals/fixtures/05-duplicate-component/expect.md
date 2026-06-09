# Fixture 05 — Unnecessary new component duplicating an existing @repo/ui one

## What this is

A new `PrimaryButton` component (plus its CSS module) that re-implements the
primary button already provided by the design system at
`packages/ui/src/button.tsx` — usable as `<Button variant="primary" />` from
`@repo/ui`. The new component duplicates the styling, the variant behavior, and
the public API.

## What the reviewer / critic SHOULD flag

- **Reuse**: this duplicates an existing `@repo/ui` component and should not be
  added. Use the shared `Button` (`variant="primary"`) instead.
- Scope creep / unnecessary new abstraction — the critic's job is to catch this
  before code is written.

## Expected keyword(s) in the verdict

`reuse` (acceptable: `duplicat`, `@repo/ui`, `existing component`, `already exists`)

## Verdict expectation

REQUEST CHANGES / REJECT plan — reuse the existing component.
