#!/usr/bin/env bash
#
# harness-contract.sh — Deterministic contract tests for the agentic harness
# (the Claude Code plugin at plugins/foundation/).
#
# These tests prove the harness is structurally valid and that its hooks behave
# exactly as specified — WITHOUT calling any LLM. They are fast, hermetic, and
# safe to run in CI. The probabilistic, credit-burning "does the reviewer catch
# real issues" evals live in evals/ and are intentionally NOT run here.
#
# Hermeticity: hook scenarios run inside a throwaway git repo created with
# `mktemp -d`. We copy the hook into that sandbox and run every scenario there,
# so the real repo's working tree, git state, and .claude/state are never
# touched. A trap removes the sandbox on any exit.
#
# Exit code: nonzero if ANY check fails. One PASS/FAIL line is printed per check.

set -uo pipefail

# --- locate the repo root (this script lives in <root>/scripts) -------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGIN_DIR="$ROOT_DIR/plugins/foundation"

# --- result tracking --------------------------------------------------------
FAILURES=0
pass() { printf 'PASS  %s\n' "$1"; }
fail() {
  printf 'FAIL  %s\n' "$1"
  FAILURES=$((FAILURES + 1))
}
# check NAME EXPECTED ACTUAL — assert two values are equal
check_eq() {
  local name="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    pass "$name (got: $actual)"
  else
    fail "$name (expected: $expected, got: $actual)"
  fi
}

echo "== Harness contract tests =="
echo "repo root: $ROOT_DIR"
echo

# ===========================================================================
# Check 1 — `claude plugin validate` accepts the plugin.
# ===========================================================================
if command -v claude >/dev/null 2>&1; then
  if claude plugin validate "$PLUGIN_DIR" >/tmp/harness-validate.log 2>&1; then
    pass "1. claude plugin validate exits 0"
  else
    fail "1. claude plugin validate exits 0"
    sed 's/^/      /' /tmp/harness-validate.log
  fi
else
  # The CLI is the harness itself; without it we cannot prove validity.
  fail "1. claude CLI not found on PATH (cannot run plugin validate)"
fi

# ===========================================================================
# Check 2 — every agent has frontmatter with name:, description:, model:.
# ===========================================================================
agent_ok=1
agent_count=0
for f in "$PLUGIN_DIR"/agents/*.md; do
  [ -e "$f" ] || continue
  agent_count=$((agent_count + 1))
  # Frontmatter is the block between the first two `---` lines.
  fm="$(awk 'NR==1 && $0=="---"{f=1;next} f && $0=="---"{exit} f{print}' "$f")"
  for key in "name:" "description:" "model:"; do
    if ! printf '%s\n' "$fm" | grep -q "^[[:space:]]*$key"; then
      fail "2. agent frontmatter missing '$key' in $(basename "$f")"
      agent_ok=0
    fi
  done
done
if [ "$agent_count" -eq 0 ]; then
  fail "2. no agent .md files found under agents/"
elif [ "$agent_ok" -eq 1 ]; then
  pass "2. all $agent_count agents have name/description/model frontmatter"
fi

# ===========================================================================
# Check 3 — every skill SKILL.md has frontmatter with name: and description:.
# ===========================================================================
skill_ok=1
skill_count=0
for f in "$PLUGIN_DIR"/skills/*/SKILL.md; do
  [ -e "$f" ] || continue
  skill_count=$((skill_count + 1))
  fm="$(awk 'NR==1 && $0=="---"{f=1;next} f && $0=="---"{exit} f{print}' "$f")"
  for key in "name:" "description:"; do
    if ! printf '%s\n' "$fm" | grep -q "^[[:space:]]*$key"; then
      fail "3. skill frontmatter missing '$key' in $(dirname "$f" | xargs basename)/SKILL.md"
      skill_ok=0
    fi
  done
done
if [ "$skill_count" -eq 0 ]; then
  fail "3. no SKILL.md files found under skills/"
elif [ "$skill_ok" -eq 1 ]; then
  pass "3. all $skill_count skills have name/description frontmatter"
fi

# ===========================================================================
# Check 4 — require-verify.sh (Stop gate) behaves correctly in a temp repo.
#
#   (a) clean tree                                   -> exit 0
#   (b) dirty tree, no marker, stop_hook_active:false -> exit 2 (blocks)
#   (c) same dirty tree, stop_hook_active:true        -> exit 0 (loop guard)
#   (d) dirty tree, matching fingerprint in marker    -> exit 0 (approved)
# ===========================================================================
SANDBOX="$(mktemp -d 2>/dev/null || mktemp -d -t harness)"
cleanup() { rm -rf "$SANDBOX"; }
trap cleanup EXIT

run_verify_4=1
(
  set -uo pipefail
  cp "$PLUGIN_DIR/hooks/require-verify.sh" "$SANDBOX/require-verify.sh"
  chmod +x "$SANDBOX/require-verify.sh"

  cd "$SANDBOX"
  git init -q
  git config user.email harness@test.local
  git config user.name "Harness Test"
  # The hook resolves the repo via CLAUDE_PROJECT_DIR.
  export CLAUDE_PROJECT_DIR="$SANDBOX"

  # Seed a commit so the tree starts clean. Ignore the test helper hook and the marker
  # dir, mirroring the real repo where .claude/state/ is gitignored — otherwise these
  # untracked helper files would pollute `git status` and the hook's fingerprint.
  printf '.claude/\nrequire-verify.sh\n' >.gitignore
  printf 'seed\n' >seed.txt
  git add seed.txt .gitignore
  git commit -qm "seed"
) || run_verify_4=0

if [ "$run_verify_4" -eq 0 ]; then
  fail "4. could not set up temp git repo for require-verify.sh"
else
  HOOK="$SANDBOX/require-verify.sh"
  export CLAUDE_PROJECT_DIR="$SANDBOX"

  # (a) clean tree -> exit 0
  ( cd "$SANDBOX" && printf '{"stop_hook_active": false}' | "$HOOK" >/dev/null 2>&1 )
  check_eq "4a. clean tree exits 0" "0" "$?"

  # Make the tree dirty (untracked file participates in the fingerprint).
  printf 'dirty change\n' >"$SANDBOX/work.txt"

  # (b) dirty + no marker + stop_hook_active:false -> exit 2
  rm -f "$SANDBOX/.claude/state/last-review"
  ( cd "$SANDBOX" && printf '{"stop_hook_active": false}' | "$HOOK" >/dev/null 2>&1 )
  check_eq "4b. dirty, no marker, not active -> exit 2 (blocks)" "2" "$?"

  # (c) same dirty tree but stop_hook_active:true -> exit 0 (loop guard)
  ( cd "$SANDBOX" && printf '{"stop_hook_active": true}' | "$HOOK" >/dev/null 2>&1 )
  check_eq "4c. dirty + stop_hook_active:true -> exit 0 (loop guard)" "0" "$?"

  # (d) write matching fingerprint to marker -> exit 0 (approved)
  # Reproduce the hook's exact fingerprint formula for the current dirty state.
  fp="$(
    cd "$SANDBOX" && {
      git diff
      git diff --cached
      git ls-files --others --exclude-standard -z | xargs -0 cat 2>/dev/null
    } 2>/dev/null | git hash-object --stdin 2>/dev/null
  )"
  mkdir -p "$SANDBOX/.claude/state"
  printf '%s' "$fp" >"$SANDBOX/.claude/state/last-review"
  ( cd "$SANDBOX" && printf '{"stop_hook_active": false}' | "$HOOK" >/dev/null 2>&1 )
  check_eq "4d. dirty + matching marker -> exit 0 (approved)" "0" "$?"
fi

# ===========================================================================
# Check 5 — guard-ui-tokens.sh nudges on UI files, stays silent otherwise.
# ===========================================================================
GUARD="$PLUGIN_DIR/hooks/guard-ui-tokens.sh"

# 5a. UI file (.tsx) -> reminder on stderr, exit 0.
guard_out="$(printf '{"tool_input":{"file_path":"x.tsx"}}' | bash "$GUARD" 2>&1)"
guard_exit=$?
if [ "$guard_exit" -eq 0 ] && printf '%s' "$guard_out" | grep -qi "reminder"; then
  pass "5a. .tsx file -> token reminder emitted (exit 0)"
else
  fail "5a. .tsx file -> expected token reminder (exit $guard_exit, out: $guard_out)"
fi

# 5b. non-UI file (.py) -> no reminder, exit 0.
guard_out="$(printf '{"tool_input":{"file_path":"x.py"}}' | bash "$GUARD" 2>&1)"
guard_exit=$?
if [ "$guard_exit" -eq 0 ] && ! printf '%s' "$guard_out" | grep -qi "reminder"; then
  pass "5b. .py file -> no reminder (exit 0)"
else
  fail "5b. .py file -> expected silence (exit $guard_exit, out: $guard_out)"
fi

# ===========================================================================
echo
if [ "$FAILURES" -eq 0 ]; then
  echo "== ALL CHECKS PASSED =="
  exit 0
else
  echo "== $FAILURES CHECK(S) FAILED =="
  exit 1
fi
