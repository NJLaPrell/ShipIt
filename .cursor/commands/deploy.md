# /deploy

Deploy project to production with automated readiness checks and deployment.

## Usage

```
/deploy [environment]
```

Example: `/deploy production`

## What It Does

This command performs production deployment:

1. **Production Readiness Checks:**
   - All tests pass
   - Coverage thresholds met
   - Security audit clean
   - No high-risk issues
   - Documentation complete
   - No blocking drift violations

2. **Deployment Configuration:**
   - Environment setup
   - Configuration validation
   - Secrets management check

3. **Deployment Execution:**
   - Run deployment scripts
   - Health checks
   - Rollback preparation

4. **Post-Deployment:**
   - Validation
   - Monitoring setup
   - Deployment history tracking

## Process

**Switch to Steward role** (read `.cursor/rules/steward.mdc`):

### Step 1: Pre-Deployment Checks

1. **Test Suite:**
   - Run: `pnpm test` (or equivalent)
   - Verify all tests pass
   - Check coverage: `pnpm test:coverage`
   - Verify coverage >= threshold (from `project.json`)

2. **Code Quality:**
   - Run: `pnpm lint && pnpm typecheck`
   - Verify no errors
   - Check for blocking issues

3. **Security Audit:**
   - Run: `pnpm audit` (or equivalent)
   - Check for high/critical vulnerabilities
   - Verify no secrets in code
   - Review high-risk domain changes

4. **Documentation:**
   - Verify README is up to date
   - Check CHANGELOG has entries
   - Verify API docs (if applicable)
   - Check deployment docs exist

5. **Drift Check:**
   - Run: `pnpm drift-check`
   - Review drift metrics
   - Verify no critical drift violations

6. **Invariants:**
   - Verify `_system/architecture/invariants.yml` is valid
   - Check no invariant violations
   - Review architecture canon compliance

### Step 2: Deployment Configuration

1. **Environment Selection:**
   - Determine target environment (dev/staging/prod)
   - Load environment-specific config
   - Validate configuration

2. **Secrets Check:**
   - Verify required secrets are available
   - Check secrets are not in code
   - Validate secret format

3. **Infrastructure:**
   - Check infrastructure is ready
   - Verify resources are available
   - Check quotas/limits

### Step 3: Deployment Execution

1. **Pre-Deployment:**
   - Create deployment backup
   - Tag current version
   - Prepare rollback plan

2. **Deploy:**
   - Run deployment scripts
   - Monitor deployment progress
   - Check for errors

3. **Post-Deployment:**
   - Run health checks
   - Verify endpoints are responding
   - Check logs for errors
   - Validate functionality

### Step 4: Validation & Tracking

1. **Validation:**
   - Run smoke tests
   - Check critical paths
   - Verify metrics are being collected

2. **Documentation:**
   - Update deployment history
   - Record deployment time
   - Note any issues

3. **Monitoring:**
   - Verify monitoring is active
   - Check alerts are configured
   - Validate dashboards

## Output

Creates:

- Deployment log
- Deployment history entry
- Rollback instructions (if needed)

## Rollback

If deployment fails:

1. Run rollback script
2. Restore previous version
3. Verify system is stable
4. Document failure reason

## See Also

- `scripts/deploy.sh` - Deployment script
- `scripts/check-readiness.sh` - Readiness checks
- `project.json` - Project settings
