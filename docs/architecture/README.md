# Architecture Decision Records

Short records of the decisions behind this foundation and _why_ they were made — so the
reasoning survives the people who made it. Read these before changing the thing they cover
(this is enforced as a rule in [`.claude/CLAUDE.md`](../../.claude/CLAUDE.md)).

| ADR                                  | Decision                                                 |
| ------------------------------------ | -------------------------------------------------------- |
| [0001](0001-frontend-stack.md)       | Frontend stack: React Router v7 (framework mode) on Vite |
| [0002](0002-package-manager-pnpm.md) | Package manager: pnpm                                    |
| [0003](0003-security-guardrails.md)  | Security guardrails (OWASP-aligned, layered)             |
| [0004](0004-commit-and-rollback.md)  | Commit convention & rollback strategy                    |
| [0005](0005-testing-strategy.md)     | Testing strategy (risk-based)                            |

Format: lightweight [MADR](https://adr.github.io/madr/) — Context, Decision, Consequences,
Alternatives.
