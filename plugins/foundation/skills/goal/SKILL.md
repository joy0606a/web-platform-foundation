---
name: goal
description: Run a goal end-to-end through this repo's agentic pipeline — explore, plan, critic, executor, code-review, (security if needed), visual-verify — producing a reviewed, verified change.
argument-hint: <the goal to accomplish>
disable-model-invocation: true
---

# /goal — the agentic pipeline

Drive the goal **"$ARGUMENTS"** through the pipeline below. You are the orchestrator:
you dispatch each stage to its agent, pass the previous stage's output forward, and stop early
only when a gate fails or a stage tells you to revise. Keep the change as small as the goal
allows.

**Default to the lightest path that fits the task; add a stage only when its risk trigger is
met. Do not run the full pipeline "to be safe" on small work.**

## Triage — pick the path before you start

Size the work first, then run only the stages that path calls for:

- **trivial** (a typo, one prop, a copy or spacing change, a tiny style tweak): the main
  session edits it directly, does a quick self-check, and is done. **No agents, no pipeline.**
- **standard** (one small component or a small feature that does **not** touch a risk
  surface): **explore (light) → executor → code-reviewer.** **Skip critic, security-reviewer,
  and visual-verifier** unless a conditional trigger below fires.
- **large / risky** (a multi-file change, a new package or module boundary, or anything that
  touches a risk surface): run the **full pipeline** below.

**Conditional triggers — add a stage only when its trigger is met:**

- add **critic** (after planner) only when the plan involves a real architectural choice or a
  new shared abstraction;
- add **security-reviewer** only when the change touches auth, user input, secrets, network
  calls, `dangerouslySetInnerHTML`, or new dependencies;
- add **visual-verifier** only when the change alters rendered UI you actually need to confirm
  in the running app.

A **risk surface** is any of: auth/authorization, user input handling, secrets, a new
endpoint/route/action, an external or server-side fetch, `dangerouslySetInnerHTML`, a new
dependency, or a new package/module boundary.

## Pipeline (stages, in order — select per triage above)

1. **Explore** — Understand the request and the relevant code. Map the affected
   `apps/<name>/` and `packages/<name>/`, existing `@repo/ui` components and design tokens
   (`packages/ui/src/tokens.css`), related routes/hooks/tests, and any relevant ADR in
   `docs/architecture/`. (Use parallel read-only exploration where it helps.)

2. **Plan** — Dispatch the **planner** agent with the goal and what exploration found. It
   returns a file-level plan (affected files, approach, tests, risks).

3. **Critic** — Dispatch the **critic** agent with the plan and the goal. If it returns
   **REVISE**, send its findings back to the planner and re-run the critic. Proceed only on
   **PROCEED**.

4. **Executor** — Dispatch the **executor** agent with the approved plan. It implements the
   smallest viable diff using `@repo/ui` and semantic tokens, adds/updates tests, and runs
   `pnpm lint`, `pnpm check-types`, `pnpm build`, `pnpm test`. If a gate fails, it fixes the
   root cause.

5. **Code review** — Dispatch the **code-reviewer** agent. On **CHANGES REQUESTED**, route the
   findings back to the executor and re-review. On **APPROVE**, it records the review marker so
   the Stop verify-gate is satisfied.

6. **Security review (conditional)** — If the change touches auth, user input, a new
   endpoint/route/action, an external/server-side fetch, secrets, or a new dependency,
   dispatch the **security-reviewer** agent and address any **VULNERABILITIES FOUND** before
   continuing.

7. **Visual verify** — If the change affects the UI of `apps/web` or `apps/docs`, dispatch the
   **visual-verifier** agent. It verifies via Playwright and the running app
   (`pnpm test:e2e`) — there is no Storybook here — checking loading/error/empty states and
   both light/dark themes. Address **NOT VERIFIED** before finishing.

## Finishing

Report the result of each stage that ran, the files changed, the gate results, and the
review/verify verdicts. Do not commit unless explicitly asked; the review marker plus the Stop
verify-gate already protect the working tree. If any stage is blocked (e.g. the app or
Playwright can't run in this environment), say so explicitly rather than implying success.
