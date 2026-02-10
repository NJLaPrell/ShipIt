# ShipIt User Overrides Design

## Principle: Clear Separation of Framework Core vs User Customizations

**Framework Core:** Files owned by ShipIt, replaced on upgrade  
**User Overrides:** Files owned by user, never touched by framework  
**User Customizations:** User edits to framework files, backed up before replacement

---

## Directory Structure

```
project-root/
├── .override/                  # User override directory (NEVER touched by framework)
│   ├── rules/                  # Custom Cursor rules
│   │   └── custom-rule.mdc
│   ├── commands/               # Custom Cursor commands
│   │   └── custom-command.md
│   ├── scripts/                # Custom scripts
│   │   └── my-custom-script.sh
│   └── config/                 # Custom configs
│       └── custom-config.json
│
├── .cursor/                    # Framework-owned (replaced on upgrade)
│   ├── commands/               # Framework commands
│   └── rules/                  # Framework rules
│
├── scripts/                    # Framework-owned (replaced on upgrade)
│   ├── new-intent.sh
│   ├── scope-project.sh
│   └── lib/                    # Framework libs
│
├── _system/                    # Framework-owned (replaced on upgrade)
│   ├── architecture/
│   ├── behaviors/
│   └── ...
│
└── work/                       # User-owned (NEVER touched)
    ├── intent/
    │   └── features/          # User intents
    ├── roadmap/               # User roadmap
    └── workflow-state/        # User workflow state
```

---

## Framework Core (Replaced on Upgrade)

These directories/files are **framework-owned** and get replaced by `shipit upgrade`:

### Directories (Complete Replacement)

- `.cursor/commands/` - Framework commands
- `.cursor/rules/` - Framework rules
- `scripts/` - Framework scripts (except `.override/scripts/`)
- `scripts/lib/` - Framework utilities
- `scripts/workflow-templates/` - Framework templates
- `scripts/gh/` - GitHub integration
- `_system/architecture/` - Architecture docs
- `_system/do-not-repeat/` - Framework ledgers
- `_system/drift/` - Framework drift configs
- `_system/behaviors/` - Framework behaviors
- `_system/security/` - Framework security configs
- `_system/artifacts/` - Framework artifacts (some regenerated)
- `_system/golden-data/` - Framework golden data structure
- `_system/reports/` - Framework reports
- `dashboard-app/` - Dashboard app
- `work/intent/templates/` - Intent templates

### Files (Replaced on Upgrade)

- `AGENTS.md` - Framework documentation
- `scripts/command-manifest.yml` - Command manifest
- `scripts/export-dashboard-json.js` - Dashboard exporter
- `scripts/create-test-plan-issue.sh` - Test plan helper
- `_system/behaviors/WORK_TEST_PLAN_ISSUES.md` - Test plan runbook
- `.github/workflows/ci.yml` - CI workflow (stack-specific)

### Files (Merged, Not Replaced)

- `package.json` - Scripts/devDependencies merged, user fields preserved
- `project.json` - User edits preserved, framework updates version/settings
- `.gitignore` - ShipIt patterns appended, user patterns preserved

---

## User Overrides (Never Touched)

### `.override/` Directory

**Purpose:** User customizations that persist across upgrades

**Structure:**

```
.override/
├── rules/              # Custom Cursor rules (loaded after framework rules)
├── commands/           # Custom Cursor commands (loaded after framework commands)
├── scripts/            # Custom scripts (user can call from package.json)
└── config/             # Custom configs (user-defined)
```

**Behavior:**

- **Never** touched by `shipit upgrade`
- **Never** overwritten by `shipit init`
- User can add/remove files freely
- Cursor loads `.override/rules/` and `.override/commands/` after framework rules/commands

**Example:**

```bash
# User creates custom rule
echo "# Custom Rule" > .override/rules/my-team-rule.mdc

# User creates custom command
echo "# /my-command" > .override/commands/my-command.md

# These persist across upgrades
shipit upgrade  # .override/ untouched
```

### User-Owned Directories

**Never touched by framework:**

- `src/` - User source code
- `tests/` - User tests (different from framework `tests/`)
- `work/intent/features/` - User intents
- `work/intent/bugs/` - User bug intents
- `work/intent/tech-debt/` - User tech-debt intents
- `work/roadmap/` - User roadmap
- `work/release/` - User release plans
- `work/workflow-state/` - User workflow state files

### User-Owned Files

**Never touched by framework:**

- `README.md` - User project README
- `package.json` (user fields: name, version, description, dependencies)
- `pyproject.toml` (user fields)
- `requirements.txt` (user dependencies)
- User's `tsconfig.json`, `.eslintrc.json`, etc. (if customized)
- `.gitignore` (user patterns preserved)

---

## User Customizations (Backed Up Before Replacement)

When user modifies a **framework-owned** file, `shipit upgrade` backs it up before replacing:

### Backup Strategy

**Location:** `._shipit_backup/` (or `--backup-dir`)

**Format:** `._shipit_backup/<relative-path>/<filename>.<timestamp>`

**Example:**

```
._shipit_backup/
├── scripts/
│   └── workflow-orchestrator.sh.20240210-143022
└── .cursor/
    └── rules/
        └── implementer.mdc.20240210-143022
```

**Behavior:**

1. Before replacing modified framework file, copy to backup
2. Replace with latest framework version
3. Warn user: `"File 'scripts/workflow-orchestrator.sh' was modified locally. Backed up to ._shipit_backup/..."`

### Detection of Modifications

**Method:** Compare file hash/size/timestamp with framework version

**Heuristic:** If file differs from framework version → consider modified

**Edge Cases:**

- User adds comments → considered modified, backed up
- User changes whitespace → considered modified, backed up
- Framework updates file → not considered modified (it's the new version)

---

## Merge Strategy for Special Files

### `package.json`

**Framework merges:**

- Adds ShipIt scripts (with `shipit:` prefix if collision)
- Adds ShipIt devDependencies if missing

**User preserves:**

- `name`, `version`, `description`
- `dependencies` (runtime deps)
- Existing scripts (unless ShipIt script with same name)
- Custom fields (`author`, `license`, `repository`, etc.)

**Example:**

```json
// User's package.json
{
  "name": "my-app",
  "version": "1.0.0",
  "scripts": {
    "dev": "vite",
    "build": "vite build"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}

// After shipit init
{
  "name": "my-app",                    // Preserved
  "version": "1.0.0",                  // Preserved
  "scripts": {
    "dev": "vite",                     // Preserved
    "build": "vite build",             // Preserved
    "shipit:new-intent": "./scripts/new-intent.sh",  // Added
    "shipit:scope-project": "./scripts/scope-project.sh"  // Added
  },
  "dependencies": {
    "express": "^4.18.0"               // Preserved
  },
  "devDependencies": {
    "@types/node": "^20.10.0",         // Added
    "vitest": "^1.0.4"                 // Added
  }
}
```

### `project.json`

**Framework updates:**

- `shipitVersion` - Updated to current version
- `settings` defaults - Updated if framework changes defaults

**User preserves:**

- `name`, `description`, `version` - User can edit
- `techStack`, `highRiskDomains` - User can edit
- Custom fields - User can add

**Upgrade behavior:**

- If `project.json` exists → preserve user edits, update framework fields
- If major version change → warn user, show diff

### `.gitignore`

**Framework appends:**

- ShipIt-specific patterns if not present:
  - `._shipit_backup/`
  - `_system/artifacts/usage.json` (optional, user can commit)
  - `_system/reports/`

**User preserves:**

- All existing patterns
- User-added patterns

---

## Cursor Rules/Commands Loading Order

**Priority (highest to lowest):**

1. `.override/rules/` - User overrides (loaded last, wins)
2. `.cursor/rules/` - Framework rules
3. `.override/commands/` - User commands (loaded last, wins)
4. `.cursor/commands/` - Framework commands

**Rationale:**

- User overrides should take precedence
- Framework provides defaults
- User can extend or replace framework behavior

---

## Upgrade Process

### Step 1: Detect Modified Files

```bash
# For each framework-owned file:
if file exists and differs from framework version:
    mark as modified
```

### Step 2: Backup Modified Files

```bash
# Create backup directory
mkdir -p ._shipit_backup

# Copy modified files with timestamp
cp scripts/workflow-orchestrator.sh \
   ._shipit_backup/scripts/workflow-orchestrator.sh.$(date +%Y%m%d-%H%M%S)
```

### Step 3: Replace Framework Files

```bash
# Replace with latest framework version
cp framework/scripts/workflow-orchestrator.sh \
   scripts/workflow-orchestrator.sh
```

### Step 4: Merge Special Files

```bash
# Merge package.json (preserve user fields)
# Merge project.json (preserve user fields)
# Append .gitignore (preserve user patterns)
```

### Step 5: Never Touch User Files

```bash
# Skip:
# - src/
# - tests/
# - work/intent/features/
# - work/roadmap/
# - .override/
```

---

## User Guide: Customizing ShipIt

### Adding Custom Cursor Rules

```bash
# Create custom rule
cat > .override/rules/my-team-rule.mdc << 'EOF'
# My Team Rule

Our team prefers X pattern over Y pattern.
EOF
```

### Adding Custom Commands

```bash
# Create custom command
cat > .override/commands/my-command.md << 'EOF'
# /my-command

Does something custom for my team.
EOF
```

### Modifying Framework Scripts

**Not recommended**, but if needed:

1. Copy framework script to `.override/scripts/`
2. Modify `.override/scripts/my-script.sh`
3. Update `package.json` to call `.override/scripts/my-script.sh` instead

**Better approach:**

- Fork framework script
- Add your logic to `.override/scripts/`
- Call framework script from your script if needed

### Preserving Customizations Across Upgrades

**Safe (persists):**

- `.override/` directory
- `src/`, `tests/`, `work/` directories
- User fields in `package.json`, `project.json`

**Backed up (then replaced):**

- Modified framework files → backed up to `._shipit_backup/`

**Merged (preserves user changes):**

- `package.json` scripts/deps
- `project.json` user fields
- `.gitignore` patterns

---

## Manifest Update

Update `framework-files-manifest.json`:

```json
{
  "userOverrides": {
    "directory": ".override/",
    "description": "User customizations that persist across upgrades",
    "neverTouched": true
  },
  "backupStrategy": {
    "directory": "._shipit_backup/",
    "format": "<relative-path>/<filename>.<timestamp>",
    "description": "Backups of modified framework files before upgrade"
  }
}
```
