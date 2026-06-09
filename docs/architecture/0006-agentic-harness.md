# 0006 — Agentic harness: the `/goal` pipeline, packaged as a plugin

- Status: accepted
- Date: 2026-06-09

## Context

The repo already had the pieces of an agentic setup — conventions in `CLAUDE.md`, a few
skills, a reviewer agent, and a Stop hook enforcing review. But they were loose parts: a
contributor (or an agent) had to know to invoke them in the right order, every agent ran at
the same model/effort, and nothing packaged the setup so other repos or teammates could reuse
it. For a foundation whose whole point is "shipping stays safe as more people contribute," the
agentic layer should be a single, tuned, distributable harness — not a folder of files you
have to wire up by hand each time.

## Decision

**1. One front door: `/goal`.** A single orchestrator skill runs the pipeline end to end —
explore → plan → critic → executor → code-review → (security, conditional) → visual-verify —
and judges "done" against the goal's acceptance criteria, with reject loops (critic → plan,
review/verify → executor) rather than a straight line. Triage by size: trivial work skips
stages; only large/risky work runs the full course.

**2. Tune each stage by model + effort, not one global setting.** Exploration is cheap
(`haiku`/low), planning is where thinking pays off (`opus`/xhigh), implementation is `high`,
review/verify are mid, security wakes only when the change touches auth/input/dangerous
HTML/secrets/deps. Spending `max` on exploration is waste; planning at `low` is false economy.
Each agent carries its own `model`/`effort` frontmatter.

**3. Three enforcement strengths — pick the weakest that works.**

- **Flow → Skill.** `/goal` is soft orchestration: the main session drives it.
- **Hard gate → Hook.** Things that must not be skipped are hooks (a `Stop` hook refuses to
  finish with unreviewed changes; a `PostToolUse` hook nudges on hardcoded values).
- **Truly deterministic DAG → Workflow.** If a step order ever must be guaranteed regardless
  of the model, promote it to a Workflow script. (Not needed yet.)

**4. Package it as a Claude Code plugin** at [`plugins/foundation/`](../../plugins/foundation/)
(`.claude-plugin/plugin.json` + `skills/` + `agents/` + `hooks/`). The repo's own
`.claude-plugin/marketplace.json` lists it, and `.claude/settings.json` enables it
(`extraKnownMarketplaces` + `enabledPlugins`) so it auto-applies here and is installable
elsewhere. This is the shape a team's shared agentic setup actually takes — versioned,
reusable, distributable — which is exactly what "Claude Code with a custom plugin" means.

**5. Adapt the design to this repo's reality.** The original blueprint assumed Storybook;
this repo has none. So `visual-verifier` verifies against the **Vite apps + Playwright e2e**
(`pnpm test:e2e`, `pnpm --filter web dev`), and `use-design-system` references
`packages/ui/src/tokens.css` and `@repo/ui` rather than `*.stories.tsx`.

## Consequences

- Positive: a single, tuned, enforced, reusable harness; cost/quality controlled per stage;
  the agentic layer is now a real artifact (a plugin) instead of loose files.
- Trade-offs:
  - **Ambition up.** The repo is no longer just a "minimal reference"; it's a working harness.
    Intentional — it answers the feedback that harness engineering was under-shown — but the
    README framing was updated to match.
  - **Plugin enable step.** The full harness applies once the plugin is enabled (contributors
    are prompted on trusting the repo); a bare clone still gets `CLAUDE.md` + permissions, but
    not the agents/hooks until enabled. The plugin is canonical to avoid duplication.
  - **Namespacing.** Plugin skills are namespaced (`/foundation:goal`).
- Verified against the live docs (subagent `effort`/`skills` frontmatter, plugin/marketplace
  schema, `enabledPlugins`/`extraKnownMarketplaces`) per the `claude-docs` discipline, not
  from memory.

## Alternatives considered

- **Keep loose `.claude/` files** — simplest and clone-and-go, but no tuning, no orchestration,
  no reuse; doesn't demonstrate harness engineering.
- **Adopt a third-party orchestration framework** — faster to stand up, but couples the
  foundation to a heavy external dependency and hides the design; the point here is to _build_
  the harness, which is the role this foundation is written for.
- **Make `/goal` a Workflow DAG now** — maximal determinism, but heavier than warranted while
  the pipeline is still evolving; kept as the documented escalation path.
