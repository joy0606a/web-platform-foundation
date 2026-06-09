#!/usr/bin/env bash
# Stop hook — refuse to finish a turn while there are uncommitted changes that the
# `code-reviewer` agent hasn't approved.
#
# The code-reviewer records the reviewed working state in .claude/state/last-review on an
# APPROVE verdict (same fingerprint formula as below). This hook blocks the stop until that
# marker matches the current uncommitted changes. Committing clears the tree, which also lets
# the turn finish (commits are already gated by the git hooks + CI).
#
# Honors stop_hook_active to avoid infinite loops, and fails OPEN (never locks you out) if
# anything unexpected happens.

input="$(cat)"

# Loop guard: if we're already continuing because of a stop hook, allow the stop.
case "$input" in
  *'"stop_hook_active": true'* | *'"stop_hook_active":true'*) exit 0 ;;
esac

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Clean working tree → nothing pending to review.
[ -n "$(git status --porcelain 2>/dev/null)" ] || exit 0

# Fingerprint the current uncommitted changes: tracked diff + staged diff + untracked
# file contents, hashed with git itself (no shasum dependency).
fp="$(
  {
    git diff
    git diff --cached
    git ls-files --others --exclude-standard -z | xargs -0 cat 2>/dev/null
  } 2>/dev/null | git hash-object --stdin 2>/dev/null
)"
[ -n "$fp" ] || exit 0

marker=".claude/state/last-review"
if [ -f "$marker" ] && [ "$(cat "$marker" 2>/dev/null)" = "$fp" ]; then
  exit 0
fi

echo "Uncommitted changes have not been approved by the 'code-reviewer' agent. Invoke the code-reviewer agent (or run the full pipeline with /foundation:goal); on APPROVE it records the review, then you can finish (or commit, which clears the tree)." >&2
exit 2
