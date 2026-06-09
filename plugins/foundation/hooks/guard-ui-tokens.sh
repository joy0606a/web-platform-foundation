#!/usr/bin/env bash
# PostToolUse(Write|Edit) hook — when a UI file (*.tsx, *.ts, *.css) is written or edited,
# emit a non-blocking reminder to use the design system. This never blocks the edit; it only
# nudges. The code-reviewer agent and lint are the enforcing layers.

input="$(cat)"

# Extract the edited file path from the hook payload without requiring jq.
path="$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
[ -n "$path" ] || exit 0

case "$path" in
  *.tsx | *.ts | *.css)
    # Skip non-UI TypeScript like config/build files; still fine to nudge — keep it light.
    echo "Reminder: ${path##*/} is a UI file — use @repo/ui components and semantic tokens from packages/ui/src/tokens.css (var(--token)); avoid hardcoded colors/spacing/radius. See the use-design-system skill." >&2
    ;;
esac

exit 0
