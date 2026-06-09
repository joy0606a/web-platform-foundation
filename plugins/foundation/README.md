# foundation

The agentic frontend harness for the `web-platform-foundation` monorepo, packaged as a Claude
Code plugin. It bundles a goal-driven pipeline, model/effort-tuned agents, the repo's
conventions and design-system knowledge as skills, an always-fresh docs lookup, and hooks that
keep the design system and review gate enforced.

## Install

This repo ships a marketplace at the root (`.claude-plugin/marketplace.json`) and auto-enables
the plugin via `.claude/settings.json` (`extraKnownMarketplaces` + `enabledPlugins`). Cloning
the repo and trusting the workspace is enough.

To use it elsewhere:

```
/plugin marketplace add joy0606a/web-platform-foundation
/plugin install foundation@web-platform-foundation
```

For local development:

```
claude --plugin-dir ./plugins/foundation
```

## Skills

- `/foundation:goal <goal>` — run a goal through the full pipeline
  (explore → plan → critic → executor → code-review → security? → visual-verify).
- `/foundation:new-feature <name>` — guided single feature: branch, conventions, review.
- `/foundation:onboard [area]` — orient a new contributor (forked context, onboarding-guide agent).
- `/foundation:claude-docs <topic>` — fetch and answer from the latest official Claude Code docs.
- `use-design-system` — auto-loads on `*.tsx/*.ts/*.css` edits; reuse `@repo/ui` + semantic tokens.
- `code-convention`, `security-review`, `design-tokens` — the repo's conventions and checklists.

## Agents

| Agent               | Model  | Effort | Role                                                   |
| ------------------- | ------ | ------ | ------------------------------------------------------ |
| `planner`           | opus   | xhigh  | File-level implementation plan (read-only)             |
| `critic`            | opus   | high   | Adversarially stress-tests the plan (read-only)        |
| `executor`          | opus   | high   | Implements the smallest viable diff; runs the gates    |
| `code-reviewer`     | sonnet | medium | First-pass review; writes the APPROVE marker           |
| `security-reviewer` | opus   | high   | OWASP review, run conditionally on trust-boundary work |
| `visual-verifier`   | sonnet | medium | Verifies UI via Playwright + the running app           |
| `onboarding-guide`  | haiku  | low    | Orients new contributors from the repo's docs          |

## Hooks

- `SessionStart` → `session-start.sh` — injects an orientation reminder (design system, /goal).
- `PostToolUse(Write|Edit)` → `guard-ui-tokens.sh` — non-blocking nudge to use tokens on UI files.
- `Stop` → `require-verify.sh` — blocks finishing while uncommitted changes aren't
  code-reviewer-APPROVED (same fingerprint/loop-guard as the original `require-review.sh`).

## Adaptations from the generic blueprint

- **No Storybook.** `visual-verifier` uses Playwright + the running Vite apps
  (`pnpm test:e2e`, `pnpm --filter web dev`), and `use-design-system` references
  `packages/ui/src/tokens.css` and `@repo/ui` components — not `*.stories.tsx`.
- **`permissionMode` is not supported on plugin-shipped agents** (per the Claude Code plugins
  reference), so `planner` omits it; it stays read-only via `tools: Read, Grep, Glob`.
