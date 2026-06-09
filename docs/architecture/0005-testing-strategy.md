# 0005 — Testing strategy (risk-based)

- Status: accepted
- Date: 2026-06-09

## Context

Tests are a cost as well as a safety net: they take time to write and, worse, time to
maintain — and a brittle test that breaks on every refactor is a tax with no payoff. So the
question isn't "how much coverage?" but "where does a bug actually cost something, and where
would a test just restate the implementation?" A foundation should encode that judgement so
contributors test the right things instead of chasing a coverage number.

## Decision

**Test by risk and logic density, not by a fixed pyramid ratio.** The guiding rule:

> Test _behaviour_ at the boundary where a bug would actually cost something. Don't write
> tests that only re-state the implementation.

Where each kind of test earns its keep:

| Layer                  | Test with          | When it's worth it                                                                                                                           |
| ---------------------- | ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| **Business logic**     | Vitest (unit)      | Pure functions: money/number math, validation, dates/timezones, parsing, reducers, state machines. **Bugs concentrate here** — highest ROI.  |
| **Critical flows**     | Playwright (e2e)   | The few end-to-end paths that must not break (auth, checkout, the "money" path). Catches wiring bugs across units that unit tests can't see. |
| **Logic-bearing UI**   | component test     | Components with real conditional rendering, a11y states, or interaction logic.                                                               |
| **Presentational UI**  | Storybook / visual | A plain Button or Card — assert nothing; verify it _looks_ right with visual review.                                                         |
| **Framework / trivia** | nothing            | Don't test that React renders, that a getter returns its field, or other implementation detail.                                              |

**What this repo ships as the seed:**

- A unit test on real logic — `packages/utils` `formatMoney` (integer-minor-units to avoid
  float drift), the kind of pure function where subtle bugs live. Wired into CI via
  `pnpm test`.
- A single **Playwright smoke test** (`e2e/`) — the app boots and the critical UI renders.
  E2E starts here and grows along the real critical paths, not by inflating a count.
- Deliberately **no tests on the presentational `ui` components** — that would test React,
  not behaviour. Their correctness belongs in Storybook + visual regression (a next step).

This pairs with the convention "no business logic in components" (see
[`.claude/skills/code-convention.md`](../../.claude/skills/code-convention.md)): logic lives
in testable units, so the high-value tests are easy to write.

## Consequences

- Positive: tests target where bugs and cost actually are; the suite stays fast and
  refactor-friendly; contributors have a clear rule for what to test (and what not to).
- Negative: lower raw line-coverage than a "test everything" policy — accepted on purpose;
  coverage percentage is not the goal. E2E is intentionally shallow (smoke only) until the
  critical user paths exist to cover.

## Alternatives considered

- **Coverage-target mandate (e.g. 80%)** — drives tests of trivial code and discourages
  deleting dead tests; optimises a proxy metric instead of risk. Rejected.
- **Heavy E2E from day one** — slow, flaky, expensive to maintain before the critical paths
  are even built. Start with a smoke and grow by risk.
