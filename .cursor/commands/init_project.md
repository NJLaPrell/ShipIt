# /init-project

> **⚠️ DEPRECATED for user projects:** This command is deprecated for creating user projects. Use the ShipIt CLI instead:
>
> - `create-shipit-app <project-name>` - Create a new ShipIt project
> - `shipit init` - Attach ShipIt to an existing project
>
> **Internal use only:** This command is now only used internally by the framework to create `tests/test-project/` for end-to-end testing.

## Internal Use (Framework Testing)

This command is used internally to create the test project at `tests/test-project/` for ShipIt framework validation.

**Usage (internal only):**

```bash
./scripts/init-project.sh shipit-test
```

This creates `tests/test-project/` with test fixtures from `tests/fixtures.json`. The script:

- Only works when run from ShipIt framework repo root
- Reads test values from `tests/fixtures.json` (no prompts)
- Creates test project at `tests/test-project/` (fixed location)

**For user projects:** Use `create-shipit-app` or `shipit init` instead.
