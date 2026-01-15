# Architecture Canon

> **This document is the authoritative source for system architecture.**
> Code that violates this canon is illegal. Update this document before implementing violations.

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         ShipIt System                       │
├─────────────────────────────────────────────────────────────┤
│  Intent Layer        │  Execution Layer    │  Verification  │
│  ─────────────────   │  ────────────────   │  ───────────── │
│  /intent/            │  /workflow-state/   │  CI/CD         │
│  /roadmap/           │  .cursor/rules/     │  Tests         │
│  /do-not-repeat/     │  .cursor/commands/  │  Linting       │
└─────────────────────────────────────────────────────────────┘
```

## Boundaries

### Layer Responsibilities

| Layer | Responsibility | Cannot Do |
|-------|----------------|-----------|
| **Intent** | Define WHAT to build | Specify HOW to implement |
| **Architecture** | Define HOW systems connect | Write production code |
| **Implementation** | Write code that passes tests | Change architecture |
| **Verification** | Prove correctness | Weaken acceptance criteria |

### Directory Boundaries

| Directory | Owner | Modification Rules |
|-----------|-------|-------------------|
| `/intent/` | PM, Steward | Anyone can propose; Steward approves |
| `/architecture/` | Architect, Steward | Requires ADR for changes |
| `/workflow-state/` | All agents | Append-only during execution |
| `/do-not-repeat/` | All agents | Append-only; never delete |
| `/src/` | Implementer | Must follow approved plan |
| `/tests/` | QA, Implementer | Tests before implementation |

## Allowed Dependencies

### External Dependencies

| Category | Allowed | Forbidden |
|----------|---------|-----------|
| **Runtime** | Node.js LTS | Experimental Node features |
| **Language** | TypeScript 5.x | JavaScript (must be TS) |
| **Testing** | Vitest, fast-check | Jest (use Vitest instead) |
| **Linting** | ESLint, Prettier | TSLint (deprecated) |
| **Build** | esbuild, tsup | Webpack (too complex) |

### Internal Dependencies

```
┌──────────────┐
│    /src/     │
├──────────────┤
│   domain/    │ ← Pure business logic, no I/O
│   services/  │ ← Orchestration, uses domain
│   adapters/  │ ← External integrations
│   utils/     │ ← Shared utilities
└──────────────┘

Allowed: domain ← services ← adapters
         utils can be used by any layer
Forbidden: domain → services (no upward deps)
           circular dependencies
```

## Forbidden Patterns

### Code Patterns

| Pattern | Reason | Alternative |
|---------|--------|-------------|
| `any` type | Defeats type safety | Use `unknown` + type guards |
| `eval()` | Security risk | Use safe alternatives |
| `innerHTML` | XSS vulnerability | Use textContent or DOM APIs |
| `console.log` in prod | Leaks info | Use structured logger |
| Circular imports | Architectural smell | Refactor dependencies |

### Architectural Patterns

| Pattern | Reason | Alternative |
|---------|--------|-------------|
| God objects | Unmaintainable | Single responsibility |
| Deep inheritance | Fragile | Composition |
| Global mutable state | Race conditions | Dependency injection |
| Magic strings | Typo-prone | Constants/enums |

## Performance Budgets

| Metric | Budget | Measurement |
|--------|--------|-------------|
| p95 latency | < 200ms | API response time |
| p99 latency | < 500ms | API response time |
| Memory | < 512MB | Process RSS |
| Bundle size | < 1MB | Production build |
| Test suite | < 60s | Full test run |

## Security Requirements

### Authentication & Authorization
- All endpoints require authentication except: `/health`, `/metrics`
- Use principle of least privilege
- Session tokens expire after 24h max
- Refresh tokens require re-authentication after 7 days

### Data Handling
- PII must be encrypted at rest
- Secrets never logged
- All user input validated and sanitized
- SQL queries must use parameterized statements

### High-Risk Domains (Require Human Approval)
- 🔐 Authentication changes
- 💰 Payment processing
- 🔑 Permission/RBAC changes
- 🏗️ Infrastructure changes
- 📋 PII handling changes

## Schema Compatibility

- Database migrations must be backward compatible for 3 versions
- API changes must maintain backward compatibility
- Breaking changes require deprecation period (minimum 1 version)

## ADR Log

Architecture Decision Records are stored in `/architecture/ADR-###.md`.

| ADR | Decision | Date |
|-----|----------|------|
| ADR-001 | Use TypeScript + Node.js | 2026-01-12 |
| ADR-002 | Use Vitest over Jest | 2026-01-12 |
| ADR-003 | Prefer config over custom code | 2026-01-12 |

---

*Last updated: 2026-01-12*
*Approved by: Steward*
