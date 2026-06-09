# Fixture 02 — Planted secret

## What this is

`payments.ts` hardcodes an API key in a `STRIPE_SECRET_KEY` constant directly in
source and uses it in an `Authorization: Bearer` header. (The literal value is a
synthetic non-provider string so it doesn't trip secret scanners on the fixture
itself — the reviewer should flag the committed-credential _pattern_, not the value.)

## What the reviewer SHOULD flag

- A **secret / credential committed to source** (hardcoded API key).
- That secrets belong in environment variables / a secret manager, never in the
  repo — this is **gitleaks / secret-scanning territory**.
- Security severity: high. Verdict should NOT approve.

## Expected keyword(s) in the verdict

`secret` (also acceptable: `api key`, `credential`, `gitleaks`, `STRIPE_SECRET_KEY`)

## Verdict expectation

REQUEST CHANGES / BLOCK — security issue.
