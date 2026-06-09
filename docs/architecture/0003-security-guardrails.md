# 0003 — Security guardrails (OWASP-aligned, layered)

- Status: accepted
- Date: 2026-06-09

## Context

The foundation's promise is that "shipping stays safe as more people contribute" —
including contributors who aren't security specialists. That only holds if safety is a
property of the setup, not something each person has to remember. Guardrails should fire
automatically, as early as possible, and be layered so no single miss is fatal.

## Decision

Security is enforced in four layers, ordered by how early they catch a problem:

1. **Static analysis (every file, automatically).** `eslint-plugin-security` lives in the
   shared ESLint config ([packages/eslint-config](../../packages/eslint-config/base.js)), so
   every app and package inherits it. It flags dangerous patterns that map to OWASP
   categories — e.g. `detect-object-injection` and `detect-eval-with-expression`
   (A03 Injection), `detect-non-literal-fs-filename` / `detect-child-process`
   (A03 / path & command injection), `detect-unsafe-regex` (ReDoS / A05).
2. **Secret hygiene (pre-merge, and pre-commit when available).** gitleaks scans for
   committed credentials. CI runs it over history and PR diffs as the hard gate; the
   pre-commit hook runs it locally when installed for fast feedback. Targets the "leaked
   keys" failure mode directly (A02 / A07).
3. **Supply chain (every install / CI).** pnpm's strict, non-hoisted store prevents
   phantom dependencies (see [0002](0002-package-manager-pnpm.md)); CI installs with
   `--frozen-lockfile` for reproducibility, and `pnpm audit --prod --audit-level=high`
   fails the build on known high-severity advisories (A06 Vulnerable Components,
   A08 Integrity).
4. **Judgement (review time).** Some risks aren't mechanical — broken access control,
   missing input validation, logic-level authz. Those can't be a reliable blocking hook,
   so they live in a **reviewer pass**: the `security-review` skill in
   [`.claude/skills`](../../.claude/skills) gives the agent an OWASP Top 10 checklist to
   run, alongside human PR review.

The split that makes this maintainable: \*\*deterministic + fast → git hook; deterministic

- slow → CI; needs judgement → agent/skill + human.\*\*

## Consequences

- Positive: new contributors inherit the first three layers for free; the dangerous-by-
  default cases are caught before merge; the judgement layer covers what tooling can't.
- Negative: `pnpm audit` can surface advisories in transitive deps we don't control and
  occasionally block CI until a bump/override lands — an accepted cost. `eslint-plugin-
security` has false positives; they're suppressed inline with a justification, which is
  itself reviewable.

## Alternatives considered

- **Rely on review only** — doesn't scale and depends on memory; rejected.
- **One heavyweight SAST/DAST platform** — more coverage but heavy to run on every commit
  and overkill for this foundation's stage; the layered lightweight tools give most of the
  value at a fraction of the friction.
