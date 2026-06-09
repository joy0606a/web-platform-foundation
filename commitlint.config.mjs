// Enforces Conventional Commits (type(scope): subject) via the commit-msg hook.
// A consistent, machine-readable history is what makes squash-merged PRs cleanly
// revertable and changelogs derivable — see docs/architecture/0004-commit-and-rollback.md.
export default {
  extends: ["@commitlint/config-conventional"],
  rules: {
    // Scope = the package/app touched. Kept at warning level so it guides
    // contributors toward the convention without blocking edge cases.
    "scope-enum": [
      1,
      "always",
      [
        "web",
        "docs",
        "ui",
        "eslint-config",
        "tsconfig",
        "claude",
        "repo",
        "architecture",
        "release",
      ],
    ],
    // Allow long lines in body/footer (URLs, co-author trailers, etc.).
    "body-max-line-length": [0],
    "footer-max-line-length": [0],
  },
};
