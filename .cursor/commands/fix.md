# /fix

Detect and auto-fix common intent issues.

## Usage

```
/fix
```

## What It Does

1. **Scans all intent files** for common issues:
   - Dependency ordering conflicts (dependency in later release than dependent)
   - Whitespace formatting issues in dependency lists
   - Missing dependencies (referenced but don't exist)
   - Circular dependencies

2. **Shows preview** of all issues found with fix suggestions

3. **Prompts for confirmation** before applying fixes

4. **Auto-fixes** issues where possible:
   - Normalizes whitespace in dependency lists
   - Moves dependencies to correct release targets
   - Flags issues requiring manual intervention (missing deps, circular deps)

## Output

Shows:
- List of issues found
- Fix suggestions for each issue
- Confirmation prompt
- Summary of fixes applied

## See Also

- `scripts/fix-intents.sh` - Underlying script
- `scripts/lib/validate-intents.sh` - Validation library
