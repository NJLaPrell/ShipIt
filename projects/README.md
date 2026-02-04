# projects/

Stores initialized ShipIt projects created via `/init-project`.

## Structure

Each subdirectory is a separate project (e.g. `projects/my-app/`). The framework's `init-project` command creates projects here.

## Gitignore

Contents are ignored (except `.gitkeep`) so project files are not committed to the framework repo. Only `.gitkeep` and this README are versioned.

## Usage

Run `/init-project` (or `pnpm init-project` via the init-project script) to create a new project. Open the created directory as its own Cursor workspace to work on it.
