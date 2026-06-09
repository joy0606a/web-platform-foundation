---
name: new-feature
description: Scaffold a new feature the right way — branch, conventions, and a review pass — so anyone (including non-frontend contributors) follows the guardrails by default.
argument-hint: <short-feature-name>
disable-model-invocation: true
---

Set up and guide a new feature called "$ARGUMENTS", following this repo's conventions end
to end. Do this:

1. **Branch.** From an up-to-date `main`, create `feature/$ARGUMENTS`
   (`git switch -c feature/$ARGUMENTS`). Never work on `main` directly.
2. **Orient.** Read `docs/onboarding.md` and any ADR in `docs/architecture/` relevant to
   what "$ARGUMENTS" touches. Skim the `code-convention` and `design-tokens` skills.
3. **Implement** the smallest working version. Reuse `@repo/ui` components and design
   tokens — no hardcoded colors/spacing, shared code goes in packages, not apps.
4. **Commit** in Conventional Commits form with the right scope, e.g.
   `feat(<scope>): ...`. Keep it a focused, squash-able unit.
5. **Review.** Run the `code-reviewer` agent and address its findings. Run `pnpm lint`,
   `pnpm check-types`, `pnpm build`.
6. **Open a PR** for human review. Summarize what changed and why, and link any ADR.

If "$ARGUMENTS" implies a decision that changes architecture (a new framework, a new shared
package boundary, a security-relevant choice), pause and propose an ADR first. For a larger or
multi-file goal, prefer the full pipeline: `/foundation:goal <goal>`.
