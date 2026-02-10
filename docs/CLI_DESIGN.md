# ShipIt CLI Design Specification

## CLI Surface

### Commands

#### `create-shipit-app <project-name> [options]`

Creates a new ShipIt-enabled project in a new directory.

**Arguments:**

- `<project-name>` (required): Name of the project directory to create

**Options:**

- `--tech-stack <stack>`: Tech stack (typescript-nodejs | python | other). Default: prompts interactively
- `--description <text>`: Project description. Default: prompts interactively
- `--high-risk <domains>`: Comma-separated high-risk domains. Default: prompts interactively
- `--non-interactive`: Use defaults/CLI args only, no prompts (for CI)
- `--skip-git`: Don't initialize git repo
- `--skip-install`: Don't run `pnpm install` / `pip install` after creation

**Examples:**

```bash
# Interactive mode
create-shipit-app my-app

# Non-interactive with all args
create-shipit-app my-app --tech-stack typescript-nodejs --description "My awesome app" --high-risk auth,payments --non-interactive

# CI-friendly (minimal prompts)
create-shipit-app my-api --tech-stack python --non-interactive --skip-install
```

**Behavior:**

- Creates `<project-name>/` directory
- Scaffolds all framework files per `framework-files-manifest.json`
- Creates stack-specific config files (package.json for Node, pyproject.toml for Python, etc.)
- Initializes git repo (unless `--skip-git`)
- Runs package manager install (unless `--skip-install`)
- Outputs next steps (run `/scope-project`, etc.)

---

#### `shipit init [options]`

Attaches ShipIt to an existing project in the current directory (or specified path).

**Options:**

- `--path <dir>`: Target directory (default: current directory)
- `--tech-stack <stack>`: Tech stack (typescript-nodejs | python | other). Default: auto-detect from existing files
- `--description <text>`: Project description. Default: reads from package.json/pyproject.toml or prompts
- `--high-risk <domains>`: Comma-separated high-risk domains. Default: prompts interactively
- `--non-interactive`: Use defaults/CLI args only, no prompts
- `--force`: Overwrite existing ShipIt files (creates backups)

**Auto-detection:**

- Tech stack: Checks for `package.json` → Node, `pyproject.toml` or `requirements.txt` → Python, else prompts
- Description: Reads from `package.json.description` or `pyproject.toml.project.description`
- Existing ShipIt: If `project.json` or `_system/architecture/CANON.md` exists, prompts "ShipIt already initialized. Upgrade? (y/N)" unless `--force`

**Examples:**

```bash
# In existing project directory
cd my-existing-app
shipit init

# Specify path
shipit init --path /path/to/project

# Non-interactive with auto-detection
shipit init --non-interactive --high-risk auth

# Force re-initialize (creates backups)
shipit init --force
```

**Behavior:**

- Detects if ShipIt already initialized → prompts for upgrade or uses `shipit upgrade`
- Copies framework files per manifest
- Merges ShipIt scripts into existing `package.json` (preserves user scripts)
- Never touches `src/`, `tests/`, user-owned files
- Creates `project.json` if missing
- Outputs next steps

---

#### `shipit upgrade [options]`

Upgrades an existing ShipIt project to the latest framework version.

**Options:**

- `--path <dir>`: Target directory (default: current directory)
- `--backup-dir <dir>`: Backup directory for modified files (default: `._shipit_backup/`)
- `--dry-run`: Show what would be changed without making changes
- `--force`: Skip prompts, overwrite all framework files

**Examples:**

```bash
# Upgrade current project
shipit upgrade

# Dry run to see changes
shipit upgrade --dry-run

# Upgrade specific project
shipit upgrade --path /path/to/project
```

**Behavior:**

- Reads `framework-files-manifest.json` to determine framework-owned files
- For each framework file:
  - If file doesn't exist → create it
  - If file exists and unchanged → replace silently
  - If file exists and modified → backup to `--backup-dir` with timestamp, then replace with warning
- Never touches user-owned files (`src/`, `tests/`, `work/intent/**`, `work/roadmap/**`, etc.)
- Merges `package.json` scripts/devDependencies (preserves user fields)
- Re-runs `scripts/generate-system-state.sh` after upgrade
- Outputs summary of changes

---

#### `shipit check`

Validates that ShipIt is properly initialized and shows project status.

**Options:**

- `--path <dir>`: Target directory (default: current directory)
- `--json`: Output JSON instead of human-readable

**Examples:**

```bash
shipit check
shipit check --json
```

**Output:**

- ShipIt version installed
- Framework files present/missing
- User customizations detected
- Warnings for outdated framework files

---

## Configuration

### Config File: `.shipitrc` (optional)

Located at project root. JSON format.

**Schema:**

```json
{
  "version": "1.0.0",
  "techStack": "typescript-nodejs",
  "highRiskDomains": ["auth", "payments"],
  "settings": {
    "skipGitInit": false,
    "skipPackageInstall": false,
    "backupDir": "._shipit_backup"
  },
  "overrides": {
    "description": "Custom description if different from package.json"
  }
}
```

**Usage:**

- If `.shipitrc` exists, CLI reads it for defaults
- CLI args override config file values
- Config file is **user-owned** (never overwritten by `shipit upgrade`)

### Environment Variables

- `SHIPIT_NON_INTERACTIVE=1`: Equivalent to `--non-interactive`
- `SHIPIT_TECH_STACK=<stack>`: Default tech stack
- `SHIPIT_BACKUP_DIR=<path>`: Default backup directory

### Project Metadata: `project.json`

**Framework-owned** but user can customize:

- `name`, `description`, `version`: User can edit
- `techStack`, `highRiskDomains`: User can edit
- `settings`: Framework may update defaults, user can override
- `created`, `shipitVersion`: Framework-managed

**Upgrade behavior:**

- `shipit upgrade` preserves user edits to `name`, `description`, `version`
- May update `shipitVersion` and `settings` defaults
- Prompts if major version changes detected

---

## Non-Interactive Mode

For CI/CD and automation:

**Flags:**

- `--non-interactive`: No prompts, use defaults/CLI args only
- `SHIPIT_NON_INTERACTIVE=1`: Environment variable equivalent

**Behavior:**

- Missing required args → error (don't prompt)
- Auto-detect what's possible (tech stack, description from package.json)
- Use sensible defaults for optional fields
- Skip git init prompts (assume yes)
- Skip package install prompts (assume yes)

**Example CI usage:**

```bash
# GitHub Actions
create-shipit-app my-app \
  --tech-stack typescript-nodejs \
  --description "${{ github.event.repository.description }}" \
  --high-risk none \
  --non-interactive \
  --skip-install
```

---

## Idempotency

**`create-shipit-app`:**

- If target directory exists → error (don't overwrite)
- Use `--force` to delete and recreate (dangerous)

**`shipit init`:**

- If ShipIt already initialized → prompt for upgrade
- Use `--force` to re-initialize (creates backups)

**`shipit upgrade`:**

- Safe to run multiple times
- Only updates framework files that changed
- Creates backups before overwriting modified files

---

## Error Handling

**Exit codes:**

- `0`: Success
- `1`: User error (invalid args, missing files, etc.)
- `2`: System error (permissions, disk full, etc.)
- `3`: ShipIt already initialized (use `upgrade` instead)

**Error messages:**

- Clear, actionable messages
- Suggest fixes when possible
- Include relevant file paths

**Examples:**

```
ERROR: Directory 'my-app' already exists. Use --force to overwrite or choose a different name.

ERROR: ShipIt already initialized in this project. Run 'shipit upgrade' to update framework files.

WARNING: File 'scripts/workflow-orchestrator.sh' was modified locally. Backed up to ._shipit_backup/workflow-orchestrator.sh.20240210-123456
```
