# web

The "complex app" surface of the foundation: **React Router v7 in framework mode (SSR)** on
**Vite**, consuming the shared `@repo/ui` design system. See
[ADR 0001](../../docs/architecture/0001-frontend-stack.md) for why this stack.

## Develop

```bash
pnpm --filter web dev      # http://localhost:3000
```

From the repo root: `pnpm dev` (all apps), `pnpm build`, `pnpm check-types`, `pnpm lint`.
End-to-end smoke test: `pnpm test:e2e` (Playwright, starts this app automatically).

## Structure

- `app/root.tsx` — root layout; imports the design tokens (`@repo/ui/tokens.css`).
- `app/routes.ts` + `app/routes/` — route modules.
- `react-router.config.ts` — framework config (`ssr: true`).
- `vite.config.ts` — Vite with the React Router plugin.
