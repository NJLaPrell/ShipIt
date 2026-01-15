# Drift Baselines

Initial thresholds for drift detection. Update these as the system matures.

## Baseline Metrics (Initial)

| Metric | Baseline | Threshold | Action if Exceeded |
|--------|----------|-----------|-------------------|
| **Avg PR size** | < 10 files | > 15 files | Flag for review |
| **Test-to-code ratio** | > 0.5 | < 0.3 | Block merge |
| **Dependency count** | < 50 deps | > 100 deps | Review for bloat |
| **New files w/o intents** | 0 | > 5 | Flag for review |
| **CI time-to-green** | < 5 min | > 15 min | Investigate |

## Drift Indicators

### Vocabulary Drift
- New terms introduced without documentation
- Terms used inconsistently across codebase
- **Detection:** Grep for new domain terms, check consistency

### Dependency Graph Entropy
- Circular dependencies introduced
- Import depth increases
- **Detection:** ESLint `import/no-cycle`, custom depth checker

### Test Coverage Drift
- New code without tests
- Test-to-code ratio decreases
- **Detection:** Coverage reports, ratio calculation

### Architecture Drift
- Violations of CANON.md
- New patterns without ADRs
- **Detection:** ESLint rules, manual review

## Review Schedule

- **Weekly:** Automated drift check (CI)
- **Monthly:** Human review of drift metrics
- **Quarterly:** Baseline recalibration

---

*Last updated: 2026-01-12*
