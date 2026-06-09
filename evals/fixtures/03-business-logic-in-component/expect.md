# Fixture 03 — Business logic in a component + missing loading/error states

## What this is

`UserDashboard.tsx` does three things it should not all do in the view layer:

1. Fetches data directly in the component.
2. Embeds business rules (tax rate, balance, overdue calculation) in the render
   path instead of in a domain/service layer or hook.
3. Has **no loading state and no error state** — it renders incorrect UI while
   the request is pending and silently breaks if the fetch fails.

## What the reviewer SHOULD flag

- **No business logic in components** — the tax/balance/overdue computation and
  the data fetch should live outside the presentational component.
- **Missing loading and error states** for the async data.

## Expected keyword(s) in the verdict

`loading` and/or `error` state; `business logic`
(acceptable: `missing states`, `no-business-logic-in-components`)

## Verdict expectation

REQUEST CHANGES / not approved.
