# ShipIt Multi-Stack Design

## Principle: Stack-Specific Scaffolding

ShipIt only scaffolds files relevant to the detected/selected tech stack. No unnecessary framework components are copied.

## Stack Detection

### Auto-Detection (for `shipit init`)

**TypeScript/Node.js:**

- Detects: `package.json` exists
- Confidence: High if `package.json` has `"type": "module"` or TypeScript deps

**Python:**

- Detects: `pyproject.toml` OR `requirements.txt` OR `setup.py` exists
- Confidence: High if `pyproject.toml` has `[project]` section

**Other:**

- Detects: None of the above
- Behavior: Prompts user to select stack or use `--tech-stack other`

### Manual Selection

User can override detection with `--tech-stack <stack>`:

- `typescript-nodejs`
- `python`
- `other`

---

## Framework Files (Stack-Agnostic)

These files are **always** copied regardless of stack:

### Directories

- `.cursor/commands/` - Cursor slash commands
- `.cursor/rules/` - Agent rules
- `scripts/` - Core ShipIt scripts (shell scripts, stack-agnostic)
- `scripts/lib/` - Shared shell utilities
- `scripts/workflow-templates/` - Workflow phase templates
- `scripts/gh/` - GitHub integration scripts
- `_system/architecture/` - CANON.md, invariants.yml
- `_system/do-not-repeat/` - Ledgers
- `_system/drift/` - Drift baselines
- `_system/behaviors/` - Behavior docs
- `_system/security/` - Security configs
- `_system/artifacts/` - Generated artifacts
- `_system/golden-data/` - Golden data storage
- `_system/reports/` - Generated reports
- `dashboard-app/` - Web dashboard (runs via Node, but works for any stack)
- `work/intent/templates/` - Intent templates

### Files

- `project.json` - Project metadata
- `AGENTS.md` - Framework documentation
- `scripts/command-manifest.yml` - Command manifest
- `scripts/export-dashboard-json.js` - Dashboard exporter (Node script, but works for any project)
- `scripts/create-test-plan-issue.sh` - Test plan helper
- `_system/behaviors/WORK_TEST_PLAN_ISSUES.md` - Test plan runbook
- `.github/workflows/ci.yml` - CI workflow (stack-specific, see below)

### Created on Init (Empty Scaffolds)

- `work/intent/features/`, `bugs/`, `tech-debt/`
- `work/workflow-state/` (all phase files)
- `work/roadmap/` (now.md, next.md, later.md)
- `work/release/`
- `docs/`

---

## Stack-Specific Files

### TypeScript/Node.js Stack

**Created:**

- `package.json` - With ShipIt scripts and devDependencies
- `tsconfig.json` - TypeScript config
- `tsconfig.eslint.json` - ESLint TypeScript config
- `.eslintrc.json` - ESLint rules
- `vitest.config.ts` - Vitest test config
- `stryker.conf.json` - Mutation testing config
- `.npmrc` - NPM config
- `.gitignore` - Node-specific patterns
- `src/index.ts` - Entry point stub

**Not Created for Other Stacks:**

- None of the above files are created for Python or Other stacks

### Python Stack

**Created:**

- `pyproject.toml` - Python project config (if not exists)
- `requirements.txt` - Dependencies (if not exists)
- `.gitignore` - Python-specific patterns (`__pycache__/`, `*.pyc`, `.pytest_cache/`)
- `src/` directory with `__init__.py` stub

**Not Created for Other Stacks:**

- Python-specific configs not created for Node or Other stacks

### Other Stack

**Created:**

- `.gitignore` - Generic patterns (`.DS_Store`, `.env`, etc.)
- `src/` directory (empty, user creates their own structure)

**Not Created:**

- No language-specific config files
- User manually sets up their stack

---

## CI Workflow: Stack-Specific

`.github/workflows/ci.yml` is **stack-specific**:

### TypeScript/Node.js

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint
      - run: pnpm typecheck
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4
      - run: pnpm install --frozen-lockfile
      - run: pnpm test:coverage
```

### Python

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v4
      - run: pip install -r requirements.txt
      - run: ruff check .
      - run: mypy .
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v4
      - run: pip install -r requirements.txt
      - run: pytest --cov
```

### Other

```yaml
jobs:
  # Minimal CI, user customizes
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "Add your build steps here"
```

---

## Package.json Merge (Node Stacks Only)

For TypeScript/Node.js projects, `shipit init` merges ShipIt scripts into existing `package.json`:

**Merge Strategy:**

1. **Scripts:** Add ShipIt scripts with `shipit:` prefix to avoid collisions:
   - `shipit:new-intent` instead of `new-intent`
   - OR merge if no collision, preserve user scripts
2. **devDependencies:** Add ShipIt devDeps if missing
3. **Preserve:** `name`, `version`, `description`, `dependencies`, existing scripts

**Example:**

```json
{
  "name": "my-app",
  "version": "1.0.0",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "shipit:new-intent": "./scripts/new-intent.sh",
    "shipit:scope-project": "./scripts/scope-project.sh"
  },
  "devDependencies": {
    "vite": "^5.0.0",
    "@types/node": "^20.10.0",
    "vitest": "^1.0.4"
  }
}
```

---

## Files Never Copied (Framework-Only)

These files are **never** copied to user projects:

- `tests/` directory (framework test fixtures, templates)
- Framework repo's `package.json` (ShipIt framework dependencies)
- Framework repo's `tsconfig.json` (framework TypeScript config)
- Framework repo's `.eslintrc.json` (framework lint config)
- Framework repo's `vitest.config.ts` (framework test config)
- `tests/TEST_PLAN.md`, `tests/ISSUES.md` (framework test docs)
- `tests/fixtures.json` (framework test fixtures)
- `README.md` (framework README)
- `CHANGELOG.md` (framework changelog)
- `AGENTS.md` in framework root (different from project AGENTS.md)

**Rationale:**

- `tests/` contains framework test fixtures/templates, not user test structure
- User projects have their own `tests/` directory for their tests
- Framework config files are for ShipIt development, not user projects

---

## Stack Detection Logic

```javascript
function detectTechStack(projectPath) {
  if (fs.existsSync(path.join(projectPath, 'package.json'))) {
    return 'typescript-nodejs';
  }
  if (
    fs.existsSync(path.join(projectPath, 'pyproject.toml')) ||
    fs.existsSync(path.join(projectPath, 'requirements.txt')) ||
    fs.existsSync(path.join(projectPath, 'setup.py'))
  ) {
    return 'python';
  }
  return null; // Prompt user
}
```

---

## Update Manifest

Update `framework-files-manifest.json` to include stack-specific sections:

```json
{
  "stackSpecific": {
    "typescript-nodejs": {
      "files": [
        "package.json",
        "tsconfig.json",
        "tsconfig.eslint.json",
        ".eslintrc.json",
        "vitest.config.ts",
        "stryker.conf.json",
        ".npmrc"
      ],
      "directories": []
    },
    "python": {
      "files": ["pyproject.toml", "requirements.txt"],
      "directories": []
    },
    "other": {
      "files": [],
      "directories": []
    }
  }
}
```
