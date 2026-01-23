# /verify

Run verification phase only (Phase 5 of /ship workflow).

## Usage

```
/verify <intent-id>
```

Example: `/verify F-042`

## What It Does

Runs the verification phase without going through the full /ship workflow:

1. **QA Verification:**
   - Run all tests: `pnpm test`
   - Run mutation testing: `pnpm test:mutate` (Stryker)
   - Try to break the implementation
   - Document findings

2. **Security Verification:**
   - Review for auth/input/secrets/PII issues
   - Run `pnpm audit --audit-level=high` for dependency vulnerabilities
   - Check high-risk domains

3. **Save Results:**
   - Output to `workflow-state/04_verification.md`

## When to Use

- Re-running verification after fixes
- Verifying existing code before changes
- Pre-release validation

## Role Switching

This command uses the same role-switching pattern as `/ship`:
- Switch to QA role for test verification
- Switch to Security role for security review
