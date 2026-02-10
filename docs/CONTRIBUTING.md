# Contributing to ShipIt

Thank you for your interest in contributing to ShipIt! This guide will help you understand how to contribute effectively.

## Development Setup

1. **Clone the repository:**

   ```bash
   git clone https://github.com/NJLaPrell/ShipIt.git
   cd ShipIt
   ```

2. **Install dependencies:**

   ```bash
   pnpm install
   ```

3. **Run tests:**
   ```bash
   pnpm test
   pnpm lint
   pnpm typecheck
   ```

## Testing Strategy

ShipIt uses a layered testing approach:

### Framework Tests (Internal)

- **Location:** `tests/test-project/`
- **Purpose:** End-to-end validation of ShipIt framework functionality
- **How to run:** Use `/test_shipit` command from the framework root
- **Creation:** Test project is created automatically by `scripts/init-project.sh` (internal use only)
- **Note:** `tests/test-project/` is gitignored and should not be committed

### CLI Tests (Separate)

- **Location:** `tests/cli/` (to be implemented in issue #83)
- **Purpose:** Test CLI commands (`create-shipit-app`, `shipit init`, `shipit upgrade`)
- **Status:** Planned for issue #83

### Unit Tests

- **Location:** `tests/**/*.test.ts`
- **Purpose:** Test individual functions and modules
- **How to run:** `pnpm test`

## Project Structure

- **`scripts/`** - Framework scripts (copied to user projects)
- **`.cursor/`** - Cursor/VS Code commands and rules (copied to user projects)
- **`_system/`** - Framework architecture and configuration (copied to user projects)
- **`tests/test-project/`** - Internal test project (gitignored, for framework testing only)
- **`docs/`** - Documentation

## User Projects vs Framework Development

**Important distinction:**

- **User projects:** Created using CLI (`create-shipit-app` or `shipit init`) - these are separate repositories
- **Framework development:** Work happens in this repository (ShipIt framework itself)
- **Test project:** `tests/test-project/` is for testing the framework, not for user projects

## Running Framework Tests

1. **From framework root:**

   ```bash
   ./scripts/init-project.sh shipit-test
   ```

   This creates `tests/test-project/` (internal testing only).

2. **Open test project:**

   ```bash
   cd tests/test-project
   # Or open in a new Cursor/VS Code window
   ```

3. **Run test plan:**
   Use `/test_shipit` command from within the test project workspace.

## Workflow

1. Create a branch: `git checkout -b issue-XXX-description`
2. Make changes
3. Run tests: `pnpm test && pnpm lint && pnpm typecheck`
4. Commit changes
5. Push and create PR

## Code Style

- TypeScript strict mode enabled
- ESLint + Prettier enforced via pre-commit hooks
- Follow existing patterns and conventions
- See `AGENTS.md` for detailed conventions

## Questions?

- Check `AGENTS.md` for project conventions
- Check `docs/` for architecture and design docs
- Open an issue for questions or clarifications
