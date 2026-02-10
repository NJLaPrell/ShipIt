# ShipIt Limitations

This document describes what ShipIt does **not** do, current limitations, edge cases, and when not to use it.

## What ShipIt Does NOT Do

- **Not a CI/CD replacement** — ShipIt works with your CI/CD; it doesn't replace it. Use CI to run tests and enforce gates.
- **Not a deployment tool** — The `/deploy` command runs readiness checks. Actual deployment is your responsibility (e.g. your pipeline or manual deploy).
- **Not a project management tool** — Intents are technical work items (features, bugs, tech-debt), not user stories or product backlogs.
- **Not a code generator** — Agents write code; ShipIt provides the workflow, state, and rules. It doesn't generate boilerplate for you.

## Current Limitations

- **Single project at a time** — No built-in mono-repo support. One ShipIt project per repo/directory.
- **Requires an editor** — Designed for **Cursor** or **VS Code** (with ShipIt extension) for slash commands and agent workflows.
- **Primary platform** — macOS and Linux. Windows is supported via WSL.
- **Officially supported stacks** — TypeScript/Node.js and Python are well-tested. Other stacks are experimental.

## Edge Cases That Don't Work Well

- **Unusual directory structures** — Non-standard layouts may require manual path configuration or overrides.
- **Conflicting tooling** — Multiple package managers or conflicting configs in the same project can cause confusion; stick to one stack per project.
- **Older ShipIt files** — There is no automatic migration from very old framework layouts. Use `shipit upgrade` to bring framework files up to date; customizations in `.override/` are preserved.

## When NOT to Use ShipIt

- **Very small projects** (e.g. &lt; 5 files) — Overhead may not be worth it.
- **Projects without tests** — The workflow assumes tests exist; ShipIt is test-first.
- **Projects that don't use Git** — Workflow and scripts assume Git (branches, status, etc.).
- **Real-time multi-user collaboration** — ShipIt is file/state-based; it doesn't provide live collaboration features.

## See Also

- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) — Common issues and fixes
- [README.md](../README.md) — Quick start and overview
