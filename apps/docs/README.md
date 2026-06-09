# docs

The "static / SPA" surface of the foundation: a plain **Vite + React SPA** (no router) that
consumes the shared `@repo/ui` design system — proof the shared layer works across surfaces of
different weight. See [ADR 0001](../../docs/architecture/0001-frontend-stack.md).

## Develop

```bash
pnpm --filter docs dev     # http://localhost:3001
```

From the repo root: `pnpm dev` (all apps), `pnpm build`, `pnpm check-types`, `pnpm lint`.

## Structure

- `index.html` — Vite entry.
- `src/main.tsx` — mounts the app; imports the design tokens (`@repo/ui/tokens.css`).
- `src/App.tsx` — the page.
