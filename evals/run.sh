#!/usr/bin/env bash
#
# evals/run.sh — On-demand LLM evals for the agentic harness.
#
# Dispatches a harness review agent at each known-bad fixture via headless
# Claude Code (`claude -p`) and greps the verdict for the keyword the fixture
# is expected to surface. Prints PASS/FAIL per fixture.
#
# >>> REQUIRES API CREDITS / AUTH and is NON-DETERMINISTIC. <<<
# This is intentionally NOT part of CI. Run it manually or on a schedule as a
# periodic quality gate on the harness itself. A FAIL means "read the
# transcript" (the model may simply have phrased the verdict differently), not
# necessarily a hard regression. See evals/README.md.

set -uo pipefail

EVAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$EVAL_DIR/.." && pwd)"
OUT_DIR="${TMPDIR:-/tmp}/harness-evals"
mkdir -p "$OUT_DIR"

if ! command -v claude >/dev/null 2>&1; then
  echo "claude CLI not found on PATH. These evals need authenticated Claude Code." >&2
  exit 127
fi

# fixture | agent | grep -E keyword pattern
CASES=(
  "01-hardcoded-color|code-reviewer|token|hardcoded color|var\\(--"
  "02-planted-secret|security-reviewer|secret|api key|credential|gitleaks"
  "03-business-logic-in-component|code-reviewer|loading|error state|business logic|missing state"
  "04-bad-commit-message|code-reviewer|conventional|commitlint|commit message"
  "05-duplicate-component|critic|reuse|duplicat|@repo/ui|already exists"
)

FAILURES=0

for entry in "${CASES[@]}"; do
  fixture="${entry%%|*}"
  rest="${entry#*|}"
  agent="${rest%%|*}"
  pattern="${rest#*|}"            # remaining |-separated alternatives
  pattern="${pattern//|/|}"      # already pipe-separated for grep -E
  target="evals/fixtures/$fixture"
  out="$OUT_DIR/$fixture.out"

  echo "== $fixture  (agent: foundation:$agent) =="

  prompt="Dispatch the foundation:$agent agent to review the change in $target/. \
Read the files in that folder, then give your verdict and list every issue you find. \
Be specific about the convention or rule each issue violates."

  # Run headless. Restrict tools to read-only exploration.
  ( cd "$REPO_DIR" && claude -p "$prompt" --allowedTools "Read,Grep,Glob" ) \
    >"$out" 2>&1

  if grep -iqE "$pattern" "$out"; then
    echo "PASS  $fixture (matched: /$pattern/)  transcript: $out"
  else
    echo "FAIL  $fixture (expected /$pattern/ — read transcript: $out)"
    FAILURES=$((FAILURES + 1))
  fi
  echo
done

if [ "$FAILURES" -eq 0 ]; then
  echo "== ALL EVALS PASSED =="
  exit 0
else
  echo "== $FAILURES EVAL(S) FAILED — inspect transcripts in $OUT_DIR =="
  exit 1
fi
