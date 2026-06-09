# 0002 — Package manager: pnpm

- Status: accepted
- Date: 2026-06-09

## Context

A monorepo with multiple apps and shared packages needs a package manager that handles
workspaces well, is fast and disk-efficient at scale, and — importantly for a foundation
meant to "stay safe as more people contribute" — has good dependency-integrity properties.

## Decision

Use **pnpm** (with `pnpm-workspace.yaml`) as the single package manager.

The deciding factors, in order:

1. **Strict, non-flat `node_modules`.** pnpm does not hoist transitive dependencies into a
   place where code can import them by accident. A package can only import what it actually
   declares. This kills "phantom dependencies" — and a phantom dependency is a supply-chain
   liability: code silently relies on a package it never declared, so it can break or be
   swapped under you without the manifest ever showing it.
2. **Content-addressable store.** Packages are stored once on disk and hard-linked into each
   workspace. With many apps that is a large disk and install-time saving.
3. **First-class workspace support.** `workspace:*` protocol, filtered installs/builds
   (`pnpm --filter <pkg>`), and clean interplay with Turborepo.
4. **Lockfile integrity in CI.** `pnpm install --frozen-lockfile` fails the build if the
   lockfile and manifest disagree, so CI installs are reproducible and a tampered or drifted
   lockfile is caught rather than silently accepted.

## Consequences

- Positive: phantom-dependency class of bugs/risks is structurally prevented; faster,
  smaller installs; reproducible CI; strong monorepo ergonomics. Ties directly into the
  security posture (see [0003](0003-security-guardrails.md)).
- Negative: the strict layout occasionally surfaces packages with under-declared peer deps;
  those are fixed by declaring the dependency explicitly (which is the point).

## Alternatives considered

- **npm workspaces** — ubiquitous, but flat `node_modules` allows phantom dependencies and
  installs are slower/larger at monorepo scale.
- **Yarn (Berry/PnP)** — strong integrity story too, but PnP's editor/tooling friction is a
  tax on contributors; classic Yarn shares npm's hoisting downsides.
