# /risk

Force a focused security/threat review for a specific intent.

## Usage

```
/risk <intent-id>
```

Example: `/risk F-042`

## What It Does

Performs a structured security skim and records findings.

## Inputs

- `intent/**/<intent-id>.md` (commonly `intent/features/<intent-id>.md`)
- `work/workflow-state/02_plan.md`
- `work/workflow-state/03_implementation.md` (if present)
- `_system/architecture/invariants.yml`

## Output

Writes `work/workflow-state/04_verification.md` (Security section within it) with:

- Threat model summary
- Findings (if any)
- Mitigations required
- High-risk check

## Instructions

1. Read the intent and plan to identify high-risk domains.
2. Review for auth/input validation/secrets/PII concerns.
3. Run dependency audit if applicable: `pnpm audit --audit-level=high`.
4. Record findings and required mitigations in `work/workflow-state/04_verification.md`.

## Template

```markdown
# Security Review: <intent-id>

## Threat Model

- Attack vector 1: ...
- Attack vector 2: ...

## Vulnerabilities Found

- [ ] Finding 1
- [ ] Finding 2

## Mitigations Required

- [ ] Mitigation 1
- [ ] Mitigation 2

## High-Risk Check

- [ ] Not high-risk domain
- [ ] High-risk domain (human approval required)
```
