// Runs on staged files before each commit (wired up via the Husky pre-commit hook).
// Formatting runs here because it's fast and deterministic; the heavier checks
// (lint, type-check, build across all packages) run in CI so commits stay quick.
export default {
  "**/*.{ts,tsx,js,jsx,mjs,json,md,mdx,css}": ["prettier --write"],
};
