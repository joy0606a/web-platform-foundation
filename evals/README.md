# Harness LLM evals (on-demand, NOT in default CI)

These evals prove that the **agentic harness actually works** — that its review
agents (`code-reviewer`, `security-reviewer`, `critic`) catch the kinds of
problems they are supposed to catch. They are the LLM-driven complement to the
deterministic contract tests in [`scripts/harness-contract.sh`](../scripts/harness-contract.sh).

> [!IMPORTANT]
> These evals call a real model through headless Claude Code (`claude -p`).
> They **require API credits / auth** and are **non-deterministic** (a model
> may phrase a verdict differently run to run). For that reason they are
> **intentionally NOT part of the default CI pipeline** — putting flaky, paid
> calls in the `validate` job would make CI slow, costly, and unreliable.
> Run them **manually or on a periodic schedule** as a quality gate on the
> harness itself.

## Why this exists

CTO feedback was that the _harness engineering_ was under-demonstrated. The
contract tests prove the harness is **structurally valid and its hooks behave
deterministically**. These evals prove the harness is **effective** — that
dispatching a review agent at a known-bad change yields a verdict that names the
real issue.

## What's here

```
evals/
├── README.md                 <- this file
├── run.sh                    <- best-effort runner (requires auth/credits)
└── fixtures/
    ├── 01-hardcoded-color/        component CSS with hardcoded colors
    ├── 02-planted-secret/         a hardcoded API key (secret)
    ├── 03-business-logic-in-component/  logic + missing loading/error states
    ├── 04-bad-commit-message/     a non-Conventional-Commit message
    └── 05-duplicate-component/    a component duplicating @repo/ui's Button
```

Each fixture folder contains the bad input (a small snippet / file / message)
plus an `expect.md` describing **what the reviewer/critic SHOULD flag** and the
**keyword** the verdict is expected to contain.

| #   | Fixture                     | Best agent          | Expected keyword    |
| --- | --------------------------- | ------------------- | ------------------- |
| 01  | hardcoded-color             | `code-reviewer`     | `token`             |
| 02  | planted-secret              | `security-reviewer` | `secret`            |
| 03  | business-logic-in-component | `code-reviewer`     | `loading` / `error` |
| 04  | bad-commit-message          | `code-reviewer`     | `conventional`      |
| 05  | duplicate-component         | `critic`            | `reuse`             |

## How to run on demand

The harness agents are defined in the `foundation` plugin
(`plugins/foundation/agents/*.md`). To exercise one against a fixture, run
headless Claude Code with a prompt that (a) names the agent to dispatch and
(b) points it at the fixture, then check the output mentions the expected issue.

Prerequisites:

- `claude` CLI on PATH and authenticated (`claude` interactive once, or an
  `ANTHROPIC_API_KEY` in the environment).
- The `foundation` plugin available to Claude Code (it lives in this repo under
  `plugins/foundation/`).

### Single fixture, by hand

```bash
# Example: run the code-reviewer against the hardcoded-color fixture.
claude -p "Dispatch the foundation:code-reviewer agent to review the change in \
evals/fixtures/01-hardcoded-color/. Read the files, then give your verdict and \
list the issues you found." \
  --allowedTools "Read,Grep,Glob" \
  | tee /tmp/eval-01.out

# Then confirm the verdict named the real issue:
grep -iE "token|hardcoded color|var\(--" /tmp/eval-01.out && echo "PASS" || echo "FAIL"
```

Swap the agent and fixture for the other cases (see the table above). For the
commit-message fixture, point the prompt at
`evals/fixtures/04-bad-commit-message/commit-message.txt`; for the secret
fixture prefer `foundation:security-reviewer`; for the duplicate-component
fixture use `foundation:critic`.

### All fixtures at once

```bash
bash evals/run.sh
```

`run.sh` loops over every fixture, dispatches the mapped agent via `claude -p`,
and greps the output for that fixture's expected keyword, printing PASS/FAIL per
fixture. It is **best-effort**: it needs auth/credits and may report a false
FAIL if the model phrases its verdict unusually. Treat a FAIL as "look at the
transcript", not as a hard regression — these are signal, not a deterministic
gate.

## Interpreting results

- **All PASS** → the harness's review agents are catching the canonical
  problem classes. Good.
- **A FAIL** → read the saved transcript under `/tmp/eval-*.out`. Either the
  agent genuinely missed the issue (a real harness regression — tighten the
  agent's prompt/checklist) or it described the issue in words the keyword
  grep didn't match (loosen the keyword in the fixture's `expect.md` and in
  `run.sh`).
