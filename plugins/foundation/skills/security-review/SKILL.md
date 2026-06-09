---
name: security-review
description: OWASP Top 10 review checklist for this codebase. Use before opening a PR and when reviewing changes for security.
---

# Security review

The tooling layers catch the mechanical cases (see ADR 0003): `eslint-plugin-security`,
gitleaks, and `pnpm audit`. This checklist is the **judgement** layer — the things tooling
can't decide. Run it against the diff before opening a PR.

## Checklist (OWASP Top 10, 2021)

- **A01 Broken Access Control** — Does every new endpoint/route/action check authorization,
  not just authentication? Are object references validated against the current user (no IDOR)?
- **A02 Cryptographic Failures** — No secrets in code or client bundles (gitleaks backs this
  up). No home-rolled crypto. Secrets come from env, never committed.
- **A03 Injection** — User input is validated/parameterized. No string-built SQL, no `eval`,
  no `dangerouslySetInnerHTML` with untrusted data. (eslint flags many of these.)
- **A04 Insecure Design** — Is there a trust boundary being crossed without a check? Think
  about abuse cases, not just the happy path.
- **A05 Security Misconfiguration** — Security headers / CSP set for new surfaces? Defaults
  not left permissive? No verbose errors leaking internals to clients.
- **A06 Vulnerable Components** — New dependency: is it necessary, maintained, and clean on
  `pnpm audit`? Pin and review transitive additions.
- **A07 Auth Failures** — Session/token handling correct? No credentials in URLs/logs.
- **A08 Integrity Failures** — Lockfile committed and frozen in CI. No loading code from
  untrusted/unpinned sources.
- **A09 Logging Failures** — Security-relevant events logged; logs don't contain secrets/PII.
- **A10 SSRF** — Server-side fetches to user-controlled URLs are validated/allow-listed.

## Output

For each finding: file:line, the risk, the OWASP category, and a concrete fix. If clean,
say which categories were checked and why they don't apply.
