# ShipIt CLI Implementation Plan

## Overview

This document summarizes the three design specs and provides implementation guidance:

1. **CLI Design** (`CLI_DESIGN.md`) - Command surface, config, non-interactive mode
2. **Multi-Stack Design** (`MULTI_STACK_DESIGN.md`) - Stack-specific scaffolding
3. **User Overrides Design** (`USER_OVERRIDES_DESIGN.md`) - Framework core vs user customizations

---

## Implementation Checklist

### Phase 1: Core CLI Structure

- [ ] Create npm package structure (`package.json` with `bin` entry point)
- [ ] Implement CLI entry point (`bin/shipit` or `bin/create-shipit-app`)
- [ ] Set up argument parsing (use `commander.js` or similar)
- [ ] Implement stack detection logic
- [ ] Create config file reader (`.shipitrc`)

### Phase 2: File Manifest System

- [ ] Read `framework-files-manifest.json` from npm package
- [ ] Implement file copying logic (respect stack-specific files)
- [ ] Implement directory creation logic
- [ ] Add stack-specific file filtering

### Phase 3: Commands

#### `create-shipit-app`

- [ ] Create new directory
- [ ] Scaffold framework files (stack-agnostic)
- [ ] Scaffold stack-specific files
- [ ] Initialize git repo (unless `--skip-git`)
- [ ] Run package manager install (unless `--skip-install`)
- [ ] Output next steps

#### `shipit init`

- [ ] Detect existing ShipIt installation
- [ ] Auto-detect tech stack
- [ ] Merge into existing `package.json` (if exists)
- [ ] Copy framework files (skip if already exist, unless `--force`)
- [ ] Create `project.json` if missing
- [ ] Handle `.shipit/` directory (never touch)

#### `shipit upgrade`

- [ ] Read framework manifest
- [ ] Detect modified framework files (compare hashes)
- [ ] Backup modified files to `._shipit_backup/`
- [ ] Replace framework files with latest
- [ ] Merge `package.json` (preserve user fields)
- [ ] Update `project.json` (preserve user fields)
- [ ] Re-run `scripts/generate-system-state.sh`
- [ ] Output summary

#### `shipit check`

- [ ] Validate ShipIt installation
- [ ] Check framework files present/missing
- [ ] Detect outdated framework files
- [ ] Show user customizations
- [ ] Output status (JSON or human-readable)

### Phase 4: Stack-Specific Logic

- [ ] TypeScript/Node.js: Create `package.json`, `tsconfig.json`, `.eslintrc.json`, `vitest.config.ts`, `stryker.conf.json`
- [ ] Python: Create `pyproject.toml`, `requirements.txt` (if not exist)
- [ ] Other: Create minimal `.gitignore`, `src/` directory
- [ ] Stack-specific CI workflow (`.github/workflows/ci.yml`)

### Phase 5: User Overrides

- [ ] Create `.override/` directory structure on init
- [ ] Ensure `.override/` never touched by upgrade
- [ ] Implement backup strategy (`._shipit_backup/`)
- [ ] Implement file modification detection
- [ ] Update Cursor rules/commands loading order (documentation)

### Phase 6: Package.json Merge

- [ ] Detect script collisions
- [ ] Add `shipit:` prefix to ShipIt scripts if collision
- [ ] Merge devDependencies (add if missing)
- [ ] Preserve user fields (name, version, description, dependencies)

### Phase 7: Testing

- [ ] CLI test infrastructure (`tests/cli/`)
- [ ] Test fixtures for different project states
- [ ] Test `create-shipit-app` (greenfield)
- [ ] Test `shipit init` (attach to existing)
- [ ] Test `shipit upgrade` (with modified files)
- [ ] Test stack detection
- [ ] Test package.json merge
- [ ] Test user overrides persistence

### Phase 8: Documentation

- [ ] Update README.md with CLI installation/usage
- [ ] Update docs/PILOT_GUIDE.md with CLI commands
- [ ] Document `.override/` directory usage
- [ ] Document upgrade process
- [ ] Document stack-specific behavior

---

## Key Implementation Details

### File Copying

```javascript
// Pseudo-code
function copyFrameworkFiles(targetDir, stack) {
  const manifest = readManifest();

  // Copy stack-agnostic files
  for (const dir of manifest.frameworkOwned.directories) {
    if (shouldCopy(dir, stack)) {
      copyDirectory(dir, targetDir);
    }
  }

  // Copy stack-specific files
  const stackFiles = manifest.stackSpecific[stack].files;
  for (const file of stackFiles) {
    copyFile(file, targetDir);
  }
}
```

### Package.json Merge

```javascript
// Pseudo-code
function mergePackageJson(existing, shipitScripts, shipitDevDeps) {
  const merged = { ...existing };

  // Merge scripts (avoid collisions)
  merged.scripts = { ...existing.scripts };
  for (const [name, script] of Object.entries(shipitScripts)) {
    if (merged.scripts[name]) {
      // Collision: prefix with shipit:
      merged.scripts[`shipit:${name}`] = script;
    } else {
      merged.scripts[name] = script;
    }
  }

  // Merge devDependencies
  merged.devDependencies = {
    ...existing.devDependencies,
    ...shipitDevDeps,
  };

  return merged;
}
```

### Stack Detection

```javascript
function detectTechStack(projectPath) {
  if (fs.existsSync(path.join(projectPath, 'package.json'))) {
    return 'typescript-nodejs';
  }
  if (
    fs.existsSync(path.join(projectPath, 'pyproject.toml')) ||
    fs.existsSync(path.join(projectPath, 'requirements.txt'))
  ) {
    return 'python';
  }
  return null; // Prompt user
}
```

### File Modification Detection

```javascript
function isFileModified(filePath, frameworkVersion) {
  if (!fs.existsSync(filePath)) {
    return false; // File doesn't exist, not modified
  }

  const currentHash = hashFile(filePath);
  const frameworkHash = hashFile(frameworkVersion);

  return currentHash !== frameworkHash;
}
```

---

## Testing Strategy

### Unit Tests

- Stack detection logic
- Package.json merge logic
- File modification detection
- Config file parsing

### Integration Tests

- Full `create-shipit-app` flow (each stack)
- Full `shipit init` flow (attach to existing)
- Full `shipit upgrade` flow (with backups)
- User overrides persistence

### E2E Tests

- Create project → init → upgrade cycle
- Multiple stacks in separate test projects
- CI/CD integration (non-interactive mode)

---

## Migration Notes

### For Existing Users

**Breaking Changes:**

- `/init-project` command deprecated (only for test project creation)
- Must use CLI instead: `create-shipit-app` or `shipit init`

**Migration Path:**

- Install CLI: `npm install -g @nlaprell/shipit`
- For existing projects: `shipit init` (attaches ShipIt)
- For new projects: `create-shipit-app <name>`

**No Backward Compatibility:**

- Projects created with old `/init-project` won't be upgraded automatically
- Users must manually migrate or start fresh with CLI

---

## Open Questions / Future Work

1. **CLI Distribution:**
   - Publish to npm as `shipit`?
   - Separate packages: `create-shipit-app` and `shipit`?
   - Single package with multiple binaries?

2. **Versioning:**
   - CLI version matches framework version?
   - Independent versioning?
   - How to handle CLI updates vs framework updates?

3. **Telemetry:**
   - Track CLI usage (anonymized)?
   - Error reporting?
   - Usage analytics?

4. **Plugin System:**
   - Allow third-party Cursor rules/commands?
   - Plugin registry?
   - Extension points?

---

## References

- `docs/CLI_DESIGN.md` - CLI command surface and config
- `docs/MULTI_STACK_DESIGN.md` - Stack-specific scaffolding
- `docs/USER_OVERRIDES_DESIGN.md` - User customizations vs framework core
- `_system/artifacts/framework-files-manifest.json` - File manifest
