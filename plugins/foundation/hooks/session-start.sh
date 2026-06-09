#!/usr/bin/env bash
# SessionStart hook — inject a short orientation reminder for this monorepo so the harness's
# conventions are in context from the first turn. Non-blocking: prints context and exits 0.

cat <<'EOF'
foundation harness active. For UI work, check existing @repo/ui components and the semantic
design tokens in packages/ui/src/tokens.css before writing styles — never hardcode colors,
spacing, radius, font size, or shadow. Keep shared code in packages/, not duplicated in apps,
and handle loading/error/empty states. For any non-trivial or multi-file change, run it
through the pipeline with /foundation:goal <goal>; new contributors can start with
/foundation:onboard. The Stop hook requires the code-reviewer agent to APPROVE uncommitted
changes (or a clean tree) before a turn can finish.
EOF
exit 0
