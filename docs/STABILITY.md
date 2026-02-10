# API and surface stability

What we consider **stable** (won’t change without a major version) vs **experimental** (may change in minor/patch releases).

## Stable (public contract)

- **Intent file format** — `work/intent/**/*.md` structure and required fields (Type, Status, Motivation, Acceptance, etc.). See work/intent/templates/ and \_TEMPLATE.md.
- **Workflow state layout** — `work/workflow-state/` (flat for single intent; per-intent dirs when multiple). See \_system/architecture/workflow-state-layout.md.
- **CLI command surface** — Commands: `init`, `upgrade`, `check`, `create`, `list-backups`, `restore`. Names and primary options are stable.
- **CLI flags/options** — Existing flags (e.g. `--path`, `--dry-run`, `--json`) keep the same meaning.
- **Framework directory layout** — Top-level dirs: `work/`, `_system/`, `.cursor/`, `scripts/` (and project-level `project.json`, `AGENTS.md`). Purpose of these dirs is stable.
- **Framework file manifest** — `_system/artifacts/framework-files-manifest.json` structure used by the CLI for upgrade/copy. Additions are backward compatible; removals are breaking.

## Experimental or internal

- **Internal script APIs** — Functions and patterns inside `scripts/*.sh` and `scripts/lib/*.sh` are not a public API. They may change without a major bump.
- **\_system/ internals** — Files and structure under `_system/` may evolve (new files, renames) for framework maintenance. Canon and invariants are more stable; other artifacts can change.
- **Experimental features** — Any feature or doc explicitly marked “experimental” may change or be removed.
- **CLI implementation details** — How the CLI discovers paths, reads manifest, or copies files is internal. Only the documented CLI behavior and exit codes are stable.

## Feedback

If you rely on something not listed as stable, open an issue so we can consider documenting or stabilizing it.
