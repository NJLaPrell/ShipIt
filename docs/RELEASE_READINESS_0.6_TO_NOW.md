# Release readiness: 0.6.0 → current

Summary of changes since v0.6.0 and first-time user impact.

## What changed (user-relevant)

| Area                 | Change                                                                                                                | First-time user impact                                                                                                 |
| -------------------- | --------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| **Install**          | Package name is now **@nlaprell/shipit** (unscoped `shipit` is taken on npm).                                         | User must run `npm install -g @nlaprell/shipit`. If the package isn’t published yet, they get 404 until first publish. |
| **New project**      | Primary path is CLI: `create-shipit-app <name>` or `shipit init`. `/init-project` is deprecated (internal/test only). | Clear: use CLI. No confusion if they only read Quick Start / Installation.                                             |
| **Existing project** | `shipit init` and `shipit upgrade` with backup/restore.                                                               | Positive: upgrade is safe; rollback documented in TROUBLESHOOTING.                                                     |
| **Docs**             | New: LIMITATIONS, TROUBLESHOOTING, CLI_REFERENCE, EXAMPLES, VERSIONING, STABILITY, RELEASE_CHECKLIST, PUBLISHING.     | Better onboarding and recovery.                                                                                        |
| **Tests**            | Framework unit tests exclude `tests/test-project/**` (those are for the generated project).                           | `pnpm test` runs only framework tests; all pass.                                                                       |

## Potential issues for first-time users (and fixes)

1. **Install command wrong in one place**  
   README “Installation > For App Developers” still said `npm install -g shipit`. Fixed to `@nlaprell/shipit`.

2. **404 until first publish**  
   If we haven’t published `@nlaprell/shipit` yet, `npm install -g @nlaprell/shipit` fails. Mitigation: TROUBLESHOOTING explains install; after first publish this goes away. Optional: one line in README “(package available after first release)” or “from source” in CONTRIBUTING.

3. **Deprecated CTA at bottom of README**  
   “Start with `/init-project "My Project"`” pointed at deprecated flow. Fixed to CLI-based start.

4. **Duplicate “Prerequisites” in README**  
   One section had clone/pnpm (contributor), another had Cursor/Node/pnpm/Git. Clarified so Prerequisites is one section (editor, Node, pnpm, Git); contributor path stays under “For Framework Contributors.”

5. **Commands table still lists `/init-project`**  
   Table lists it without saying “deprecated; use CLI.” Added a note so users aren’t led to the old flow.

6. **Workflow diagram**  
   Still shows `/init-project` as first step. Left as-is for now (diagram is conceptual); Quick Start and Installation are the primary paths and now correct.

## Checklist before first release

- [x] Install commands use `@nlaprell/shipit` everywhere in README/docs.
- [x] Deprecated CTA updated; contributor vs app-developer paths clear.
- [ ] Publish `@nlaprell/shipit` so `npm install -g @nlaprell/shipit` works.
- [ ] Bump version (e.g. 0.7.0), CHANGELOG, tag, GitHub release (see RELEASE_CHECKLIST.md).

## Verifying first-time user path

1. **Install** (after publish): `npm install -g @nlaprell/shipit` → success.
2. **New project**: `create-shipit-app my-app` → prompts → project created.
3. **Open in Cursor**: open `my-app`, then `/scope-project "…"` and `/ship F-001`.
4. **Existing project**: `cd other; shipit init` → merged setup.
5. **Upgrade**: `shipit upgrade --dry-run` then `shipit upgrade`; rollback via TROUBLESHOOTING if needed.

No code or workflow changes were made that break these steps; only docs and package name were aligned.
