# ShipIt Troubleshooting

Common issues, exit codes, rollback procedures, and how to get help.

## Exit Codes

| Code  | Meaning                                                | What to do                                                                                      |
| ----- | ------------------------------------------------------ | ----------------------------------------------------------------------------------------------- |
| **0** | Success                                                | —                                                                                               |
| **1** | User error (invalid args, missing files, wrong state)  | Check command usage (`shipit <cmd> --help`), ensure you're in a ShipIt project or use `--path`. |
| **2** | System / unexpected error (permissions, I/O, internal) | Check permissions, disk space, and error message; retry or report a bug.                        |
| **3** | ShipIt already initialized (use upgrade instead)       | Run `shipit upgrade` to update framework files, not `shipit init`.                              |

Exit codes are consistent across `shipit init`, `shipit upgrade`, `shipit check`, `shipit create`, `shipit list-backups`, and `shipit restore`.

## Common Issues

### CLI command not found

- **Cause:** ShipIt CLI not on PATH (e.g. `shipit` or `create-shipit-app` not found).
- **Fix:** Install globally with `npm install -g @nlaprell/shipit` or use `npx @nlaprell/shipit <command>`. Ensure your npm global bin directory is on PATH.

### npm 404 when installing @nlaprell/shipit

- **Cause:** The package has not been published to npm yet (e.g. before the first release).
- **Fix:** Clone the repository, run `pnpm install`, and use the CLI from the repo root (`node bin/shipit ...`), or wait for the first publish. See [PUBLISHING.md](./PUBLISHING.md).

### Permission denied

- **Cause:** Scripts or files not executable, or directory not writable.
- **Fix:** Run from a directory you own; for framework scripts, ensure execute bits are set (e.g. `chmod +x scripts/*.sh` if you pulled from git and they lost execute permission).

### Package.json merge failed (upgrade)

- **Cause:** Conflicting keys or invalid JSON during `shipit upgrade` when merging `package.json`.
- **Fix:** Restore your `package.json` from `._shipit_backup/` (see Rollback below), resolve conflicts manually, then run `shipit upgrade` again or skip package.json merge if you manage it yourself.

### Framework files missing

- **Cause:** Incomplete init or upgrade, or files removed.
- **Fix:** Run `shipit check` to see missing files. Run `shipit upgrade` to reinstall framework files (backup is created first). If not yet initialized, run `shipit init`.

### "ShipIt already initialized" (exit code 3)

- **Cause:** You ran `shipit init` in a project that already has ShipIt (e.g. `project.json` exists).
- **Fix:** Use `shipit upgrade` to update framework files. Use `--force` only if you intend to overwrite existing ShipIt files.

### create-shipit-app: npm install fails

- **Cause:** Network issues, registry down, or invalid dependency resolution.
- **Fix:** Retry. If using private registry or proxy, configure npm accordingly. You can run with `--skip-install` and then run `npm install` or `pnpm install` yourself.

### GitHub API errors (e.g. when creating issues)

- **Cause:** Rate limits, auth, or API downtime.
- **Fix:** Fail fast is the current behavior; retry later. Ensure `GH_TOKEN` or GitHub CLI auth is set if the workflow needs API access.

## Rollback and Recovery

### After a failed `shipit init`

- **What may exist:** Partial copies of framework files, `project.json`, `AGENTS.md`, `work/`, `scripts/`, `_system/`, `.cursor/`, etc.
- **Cleanup:** Remove the added files/directories. Example (from project root):
  - Remove `project.json`, `AGENTS.md`, and any framework dirs that were created (e.g. `work/`, `_system/`, `.cursor/`, `scripts/` if they were added by init). If in doubt, use `git status` and `git clean` or restore from git.

### After a failed or unwanted `shipit upgrade`

- **Backups:** Upgrade writes backups under `._shipit_backup/` (or `--backup-dir`). Each backup path mirrors the project path.
- **List backups:** `shipit list-backups [--path <dir>]`
- **Restore a file:** `shipit restore <path> [--path <dir>]` where `<path>` is relative to project or backup dir. Use `--remove-backup` to delete the backup after restore.
- **Example:** To restore `package.json`: `shipit restore package.json`

## Partial failure behavior

- **init:** Best effort is used when copying files; if a critical step fails (e.g. writing `project.json`), the CLI exits with an error. There is no automatic rollback; use the cleanup steps above if needed.
- **upgrade:** Files are backed up before overwrite. If copy or merge fails mid-way, you can use `shipit list-backups` and `shipit restore` to recover. No automatic full rollback is performed.

## Getting help

- Run **`shipit check`** to validate installation and see missing framework files.
- Include **error message and exit code** when reporting bugs.
- Include **`shipit check --json`** output (sanitized) when relevant.
- **Docs:** [README](../README.md), [CLI_REFERENCE.md](./CLI_REFERENCE.md), [LIMITATIONS.md](./LIMITATIONS.md).
- **Issues:** [GitHub Issues](https://github.com/NJLaPrell/ShipIt/issues).
