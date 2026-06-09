# 0007 — Evaluating the agentic harness

- Status: accepted
- Date: 2026-06-09

## Context

A harness that orchestrates agents (ADR [0006](0006-agentic-harness.md)) is only worth trusting
if it actually does what it claims — the hooks really block, the agents really catch the
problems they're meant to. Without evaluation that's just assertion. But agent behavior is
partly deterministic (a hook's exit code) and partly probabilistic (whether an LLM reviewer
phrases a finding a certain way), and those two need different treatment: one belongs in CI,
the other does not.

## Decision

**Split evals by determinism, and only gate CI on the deterministic half.**

**1. Deterministic "harness contract" tests — in CI.**
[`scripts/harness-contract.sh`](../../scripts/harness-contract.sh) (`pnpm test:harness`, run in
the `validate` job) asserts the structural and behavioral contract with no LLM calls:

- `claude plugin validate` passes;
- every agent has `name`/`description`/`model` frontmatter and every skill has
  `name`/`description`;
- the `require-verify` Stop hook returns the right exit code across its four scenarios
  (clean → 0, dirty+unreviewed → 2, `stop_hook_active` → 0, matching marker → 0), exercised in a
  hermetic throwaway git repo so it never touches the real tree;
- the `guard-ui-tokens` hook fires on `.tsx`/`.ts`/`.css` and is silent otherwise.

These are fast, free, and reproducible, so they're a hard CI gate. (Building them already paid
off — they caught a sandbox-setup bug in the test itself.)

**2. Probabilistic LLM evals — on-demand, NOT in default CI.**
[`evals/`](../../evals/) holds five planted-defect fixtures — hardcoded color, a committed
secret, business logic + missing states in a component, a non-Conventional-Commit message, and
a needless component that duplicates `@repo/ui` — each with an `expect.md` of what the
`code-reviewer`/`critic`/`security-reviewer` should flag. [`evals/run.sh`](../../evals/run.sh)
drives each fixture through headless Claude Code (`claude -p`) and checks the verdict mentions
the expected issue.

These call a real model: they cost credits and are non-deterministic. Putting flaky, paid calls
in `validate` would make CI slow, expensive, and unreliable, so they run **manually or on a
schedule** as a quality gate on the harness itself — not on every push.

## Consequences

- Positive: the harness's mechanical guarantees are continuously enforced for free; its
  judgement quality is measurable on demand against concrete regressions; adding a new agent or
  hook comes with an obvious place to add a check.
- Negative: the LLM evals aren't enforced automatically, so a regression in review _quality_
  (as opposed to structure) is only caught when someone runs them — an accepted trade-off given
  the cost/flakiness of gating CI on model output.

## Alternatives considered

- **Gate CI on the LLM evals too** — strongest guarantee, but slow, costly, and flaky on every
  push; rejected in favor of running them out of band.
- **Coverage-style metric for the harness** — a percentage would optimize a proxy; concrete
  planted-defect fixtures map directly to "does it catch this real class of problem?".
- **No evals, trust the design** — the thing this ADR exists to reject.
