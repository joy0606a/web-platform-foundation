# 0001 — Frontend stack: React Router v7 (framework mode) on Vite

- Status: accepted
- Date: 2026-06-09

## Context

The foundation has to serve a range of surfaces: marketing-style static pages,
internal SPAs, and apps that benefit from server rendering. Picking one stack that
covers that whole range — instead of a different framework per project — is what keeps
a multi-app monorepo coherent as it grows and as more people contribute.

The incumbent was Next.js. It is capable, but for this foundation it brings weight we
don't want to standardise on:

- The App Router + RSC model is a large conceptual surface for contributors (including
  non-frontend ones) and is more than most internal tools need.
- Its happy-path deployment story is coupled to a specific vendor; we deploy to
  Cloudflare/Railway-style targets.
- It pulls its own bundler/runtime conventions, which makes "one bundler across the
  monorepo" harder.

## Decision

- **Bundler: Vite** everywhere. One fast, framework-agnostic build tool across every
  app and package. Instant HMR, a well-understood plugin model, no vendor lock-in.
- **Complex apps: React Router v7 in framework mode** (`apps/web`). Framework mode gives
  routing, data loading, and optional SSR on top of Vite, spanning static → SPA → SSR
  with one mental model. SSR is opt-in per app via `react-router.config.ts` (`ssr: true`).
- **Simple/static surfaces: a plain Vite + React SPA** (`apps/docs`). No router, no SSR —
  the lightest thing that still consumes the shared `@repo/ui` layer. This proves the
  shared layer works across surfaces of different weight.

The rule contributors learn once: **one bundler (Vite); add React Router only when a
surface needs routing/SSR.** Framework weight scales with the surface, not the other way
around.

## Consequences

- Positive: single bundler to learn and maintain; deployment-target agnostic; the
  static→SPA→SSR range is covered without switching frameworks; smaller conceptual
  surface for new contributors.
- Negative: React Router framework mode is younger than Next.js and its ecosystem of
  ready-made integrations is smaller; some patterns (image optimisation, edge middleware)
  we'd wire up ourselves rather than get for free.
- Migration: Next.js is removed from both apps. No `next` dependency remains in the apps.

## Alternatives considered

- **Stay on Next.js** — most batteries-included, but the weight and vendor-coupling above.
- **Astro for static + React for apps** — excellent for content sites, but adds a second
  framework/mental model to standardise on; deferred until a real content-heavy surface
  justifies it.
- **Vite + React Router SPA only (no SSR anywhere)** — simplest, but gives up SSR for the
  surfaces that will eventually need it (SEO, first-paint on public pages).
