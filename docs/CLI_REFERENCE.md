# ShipIt CLI Reference

All CLI commands, options, and usage. Entry points: **`shipit`** (main CLI) and **`create-shipit-app`** (create new project).

## shipit

Main CLI. Run `shipit --help` or `shipit <command> --help` for usage.

### shipit init

Attach ShipIt to an existing project (creates `project.json`, copies framework files, merges into existing layout).

| Option                  | Description                                   |
| ----------------------- | --------------------------------------------- |
| `--path <dir>`          | Target directory (default: current directory) |
| `--tech-stack <stack>`  | `typescript-nodejs` \| `python` \| `other`    |
| `--description <text>`  | Project description                           |
| `--high-risk <domains>` | Comma-separated high-risk domains             |
| `--non-interactive`     | Use defaults/CLI args only, no prompts        |
| `--force`               | Overwrite existing ShipIt files               |

**Examples:**

```bash
shipit init
shipit init --path ./my-app --tech-stack typescript-nodejs --non-interactive
```

### shipit upgrade

Upgrade ShipIt framework files to the version bundled with the CLI. Backs up modified files to `._shipit_backup/` by default.

| Option               | Description                                       |
| -------------------- | ------------------------------------------------- |
| `--path <dir>`       | Target directory (default: current directory)     |
| `--backup-dir <dir>` | Backup directory (default: `._shipit_backup/`)    |
| `--dry-run`          | Show what would be changed without making changes |
| `--force`            | Skip prompts, overwrite all framework files       |

**Examples:**

```bash
shipit upgrade
shipit upgrade --dry-run
shipit upgrade --force
```

### shipit check

Validate ShipIt installation and show project status (initialized or not, framework files present/missing, version).

| Option         | Description                                   |
| -------------- | --------------------------------------------- |
| `--path <dir>` | Target directory (default: current directory) |
| `--json`       | Output JSON instead of human-readable         |

**Examples:**

```bash
shipit check
shipit check --json
shipit check --path ./my-app
```

### shipit create &lt;project-name&gt;

Create a new ShipIt project (same as `create-shipit-app`). Creates directory, copies framework files, optional git init and package install.

| Option                  | Description                                |
| ----------------------- | ------------------------------------------ |
| `--tech-stack <stack>`  | `typescript-nodejs` \| `python` \| `other` |
| `--description <text>`  | Project description                        |
| `--high-risk <domains>` | Comma-separated high-risk domains          |
| `--non-interactive`     | Use defaults/CLI args only, no prompts     |
| `--skip-git`            | Don't initialize git repo                  |
| `--skip-install`        | Don't run package manager install          |

**Examples:**

```bash
shipit create my-app
shipit create my-app --tech-stack typescript-nodejs --skip-install
```

### shipit list-backups

List backup files from the last upgrade.

| Option               | Description                                    |
| -------------------- | ---------------------------------------------- |
| `--path <dir>`       | Target directory (default: current directory)  |
| `--backup-dir <dir>` | Backup directory (default: `._shipit_backup/`) |

**Example:** `shipit list-backups`

### shipit restore &lt;backup-path&gt;

Restore a file from backup (path relative to project or backup dir).

| Option               | Description                                    |
| -------------------- | ---------------------------------------------- |
| `--path <dir>`       | Target directory (default: current directory)  |
| `--backup-dir <dir>` | Backup directory (default: `._shipit_backup/`) |
| `--remove-backup`    | Remove backup file after restore               |

**Examples:**

```bash
shipit restore package.json
shipit restore scripts/verify.sh --remove-backup
```

---

## create-shipit-app

Standalone entry point to create a new ShipIt project. Same behavior as `shipit create <name>`.

```bash
create-shipit-app <project-name> [options]
```

Options match `shipit create` (e.g. `--tech-stack`, `--description`, `--high-risk`, `--non-interactive`, `--skip-git`, `--skip-install`).

---

## Exit codes

- **0** — Success
- **1** — User error (invalid args, wrong state)
- **2** — System/unexpected error
- **3** — Already initialized (use upgrade instead)

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for details and recovery.
