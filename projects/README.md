# projects/

> **⚠️ DEPRECATED:** This directory is deprecated. Test projects are now created in `tests/test-project` for internal framework testing only.
>
> **For user projects:** Use the ShipIt CLI:
>
> - `create-shipit-app <project-name>` - Create a new ShipIt project
> - `shipit init` - Attach ShipIt to an existing project
>
> **For framework testing:** Test projects are created at `tests/test-project` using `scripts/init-project.sh` (internal use only).

## Legacy

This directory previously stored initialized ShipIt projects created via `/init-project`. That functionality has been moved to the CLI (`shipit init` or `create-shipit-app`).

## Gitignore

Contents are ignored (except `.gitkeep`) so any legacy project files are not committed to the framework repo.
