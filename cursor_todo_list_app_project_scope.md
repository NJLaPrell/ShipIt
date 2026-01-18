# Todo list app project scope
_Exported on 1/17/2026 at 20:28:18 MST from Cursor (2.3.35)_

---

**User**

/scope-project "Build a todo list app with CRUD, tagging, and persistence"

---

**Cursor**

Got it. Before I scope, I need a few clarifications:

1. Target platform: web app (browser UI), CLI, or desktop?
2. Persistence: local-only (e.g., browser localStorage), or backend with a database?
3. User model: single user, or multi-user with accounts/auth?
4. Todo fields: title/description only, or also due date, priority, status, notes?
5. Tagging: free-form tags, or predefined list? Multiple tags per todo?
6. CRUD scope: include bulk actions (bulk delete/tag), or only single-item CRUD?
7. List behavior: sorting/filtering (by tag/status/due date), search?
8. Any required tech constraints (framework, state lib, styling) or tests?

---

**User**

1 API only
2. JSON file
3. Single
4.  All
5. Free form. Multiple
6. Include bulk
7. All
8. No

---

**Cursor**

```markdown
# Project Scope: Todo List API with Tags and JSON Persistence

## Q/A
- Q: Target platform?
  A: API only.
- Q: Persistence?
  A: JSON file.
- Q: User model?
  A: Single user.
- Q: Todo fields?
  A: All (title, description, due date, priority, status, notes).
- Q: Tagging?
  A: Free form, multiple tags per todo.
- Q: CRUD scope?
  A: Include bulk actions.
- Q: List behavior?
  A: Sorting, filtering, and search.
- Q: Tech constraints or tests?
  A: None specified.

```

Captured your answers in `project-scope.md`.

Before I generate intents, I need two things from you:

1) **Auth requirement** (from `architecture/invariants.yml`): all endpoints must require auth except `/health` and `/metrics`. For a single-user API, do you want a simple API key scheme, or should we change the invariant?

2) **Intent selection**: pick **all**, **none**, or a subset by number.

Proposed intents:
1. Core Todo API CRUD (single-item create/read/update/delete with full fields).
2. Tagging + search/filter/sort endpoints (multi-tag, free-form).
3. Bulk operations (bulk delete, bulk tag, bulk status update).
4. JSON file persistence layer (atomic read/write, error handling).

Reply with your auth choice and which intents to pursue.

---

**User**

1 Yes
2. all

---

**Cursor**

Got it on “all.” For auth you just said “Yes” — yes to **API key auth** or yes to **changing the invariant**?  
If API key: confirm header name (e.g., `X-API-Key`) and where the single key lives (env var like `TODO_API_KEY` ok?).

---

**User**

Change to invariant

---

**Cursor**

```markdown
# Project Scope: Todo List API with Tags and JSON Persistence

## Q/A
- Q: Target platform?
  A: API only.
- Q: Persistence?
  A: JSON file.
- Q: User model?
  A: Single user.
- Q: Todo fields?
  A: All (title, description, due date, priority, status, notes).
- Q: Tagging?
  A: Free form, multiple tags per todo.
- Q: CRUD scope?
  A: Include bulk actions.
- Q: List behavior?
  A: Sorting, filtering, and search.
- Q: Tech constraints or tests?
  A: None specified.
- Q: Auth invariant?
  A: Change invariant (remove auth requirement for this API).

```

```markdown
# F-001: Core Todo CRUD API

## Type
feature

## Status
planned

## Motivation
- Provide single-item create/read/update/delete endpoints for todos.
- Support full todo fields (title, description, due date, priority, status, notes).
- Establish base API contract for other features.

## Confidence
Requirements: 0.8  
Domain assumptions: 0.8

## Invariants (Hard Constraints)
Human-readable:
- Single-user API with no authentication requirement.
- Todo items store all defined fields without loss.

Executable (add to architecture/invariants.yml):
```yaml
invariants:
  - todo_single_user_no_auth
  - todo_all_fields_persisted
```

## Acceptance (Executable)
- [ ] Tests: `todo_crud_create_read_update_delete` added; fails before fix, passes after
- [ ] CLI: `pnpm test` green
- [ ] CLI: `pnpm lint && pnpm typecheck` green

## Assumptions (MUST BE EXPLICIT)
- Only one user exists; no per-user scoping is required.
- API surface is JSON over HTTP with standard status codes.

## Risk Level
low

## Kill Criteria
- Unable to meet acceptance tests within two implementation iterations.
- CRUD endpoints exceed p95 latency budget under simple local load test.

## Rollback Plan
- Feature flag: `TODO_API_ENABLED=false`
- Revert commit: `git revert <sha>`

## Dependencies
- F-004 (JSON file persistence)
- F-005 (Remove auth invariant)

## Do Not Repeat Check
- [ ] Checked /do-not-repeat/abandoned-designs.md
- [ ] Checked /do-not-repeat/failed-experiments.md

```

```markdown
# F-002: Tagging + Search/Filter/Sort

## Type
feature

## Status
planned

## Motivation
- Allow free-form tags with multiple tags per todo.
- Provide search, filtering, and sorting over todos.
- Enable efficient list views for large todo sets.

## Confidence
Requirements: 0.8  
Domain assumptions: 0.8

## Invariants (Hard Constraints)
Human-readable:
- Tags are free-form strings; multiple tags per todo are supported.
- Search/filter/sort results are deterministic for the same input.

Executable (add to architecture/invariants.yml):
```yaml
invariants:
  - todo_tags_free_form
  - todo_multi_tag_support
  - todo_list_deterministic
```

## Acceptance (Executable)
- [ ] Tests: `todo_tags_assign_and_query` added; fails before fix, passes after
- [ ] Tests: `todo_list_filter_sort_search` added; fails before fix, passes after
- [ ] CLI: `pnpm test` green
- [ ] CLI: `pnpm lint && pnpm typecheck` green

## Assumptions (MUST BE EXPLICIT)
- Search is case-insensitive on title, description, and notes.
- Sorting supports due date, priority, status, and created time.

## Risk Level
medium

## Kill Criteria
- Filter/sort/search correctness cannot be validated by tests.
- Performance budgets cannot be met for list operations on 1,000 todos.

## Rollback Plan
- Feature flag: `TODO_LIST_FEATURES_ENABLED=false`
- Revert commit: `git revert <sha>`

## Dependencies
- F-001 (Core CRUD API)
- F-004 (JSON file persistence)
- F-005 (Remove auth invariant)

## Do Not Repeat Check
- [ ] Checked /do-not-repeat/abandoned-designs.md
- [ ] Checked /do-not-repeat/failed-experiments.md

```

```markdown
# F-003: Bulk Todo Operations

## Type
feature

## Status
planned

## Motivation
- Support bulk delete, bulk tag, and bulk status updates.
- Reduce round-trips for batch workflows.

## Confidence
Requirements: 0.8  
Domain assumptions: 0.8

## Invariants (Hard Constraints)
Human-readable:
- Bulk operations accept lists of todo IDs and operate only on those IDs.
- Bulk operations are idempotent with repeated requests.

Executable (add to architecture/invariants.yml):
```yaml
invariants:
  - todo_bulk_id_scoped
  - todo_bulk_idempotent
```

## Acceptance (Executable)
- [ ] Tests: `todo_bulk_delete` added; fails before fix, passes after
- [ ] Tests: `todo_bulk_tag_update` added; fails before fix, passes after
- [ ] Tests: `todo_bulk_status_update` added; fails before fix, passes after
- [ ] CLI: `pnpm test` green
- [ ] CLI: `pnpm lint && pnpm typecheck` green

## Assumptions (MUST BE EXPLICIT)
- Bulk requests return per-id results for successes and failures.
- Partial success is allowed when some IDs are missing.

## Risk Level
medium

## Kill Criteria
- Bulk operations cannot be made reliable with JSON file writes.
- Correctness tests are flaky due to ordering or timing issues.

## Rollback Plan
- Feature flag: `TODO_BULK_ENABLED=false`
- Revert commit: `git revert <sha>`

## Dependencies
- F-001 (Core CRUD API)
- F-004 (JSON file persistence)
- F-005 (Remove auth invariant)

## Do Not Repeat Check
- [ ] Checked /do-not-repeat/abandoned-designs.md
- [ ] Checked /do-not-repeat/failed-experiments.md

```

```markdown
# F-004: JSON File Persistence

## Type
feature

## Status
planned

## Motivation
- Persist todos to a JSON file on disk.
- Ensure data survives process restarts.

## Confidence
Requirements: 0.8  
Domain assumptions: 0.75

## Invariants (Hard Constraints)
Human-readable:
- Todos are stored in a single JSON file on local disk.
- Writes are atomic (write temp + rename) to avoid corruption.

Executable (add to architecture/invariants.yml):
```yaml
invariants:
  - todo_json_file_storage
  - todo_atomic_write
```

## Acceptance (Executable)
- [ ] Tests: `todo_persistence_reads_existing_file` added; fails before fix, passes after
- [ ] Tests: `todo_persistence_atomic_write` added; fails before fix, passes after
- [ ] CLI: `pnpm test` green
- [ ] CLI: `pnpm lint && pnpm typecheck` green

## Assumptions (MUST BE EXPLICIT)
- File path is configurable via env var (e.g., `TODO_DB_PATH`).
- JSON file schema is a single object containing an array of todos.

## Risk Level
medium

## Kill Criteria
- Atomic writes cannot be implemented portably on target OS.
- JSON corruption detected under concurrent write tests.

## Rollback Plan
- Feature flag: `TODO_PERSISTENCE_ENABLED=false`
- Revert commit: `git revert <sha>`

## Dependencies
- F-005 (Remove auth invariant)

## Do Not Repeat Check
- [ ] Checked /do-not-repeat/abandoned-designs.md
- [ ] Checked /do-not-repeat/failed-experiments.md

```

```markdown
# F-005: Remove Auth Requirement Invariant

## Type
tech-debt

## Status
planned

## Motivation
- Current invariant requires auth on all endpoints except health/metrics.
- This API is single-user and intended to be unauthenticated.

## Confidence
Requirements: 0.9  
Domain assumptions: 0.8

## Invariants (Hard Constraints)
Human-readable:
- Todo API endpoints do not require authentication.
- Only `/health` and `/metrics` remain explicitly exempted for observability.

Executable (add to architecture/invariants.yml):
```yaml
security:
  # Remove: all_endpoints_authenticated
  - id: todo_api_no_auth_required
    description: Todo API endpoints do not require auth
    enforcement: manual_review
```

## Acceptance (Executable)
- [ ] Tests: `todo_api_allows_unauthenticated_requests` added; fails before fix, passes after
- [ ] CLI: `pnpm test` green
- [ ] CLI: `pnpm lint && pnpm typecheck` green

## Assumptions (MUST BE EXPLICIT)
- API runs only on trusted local or internal networks.
- No user data beyond todo content is stored.

## Risk Level
medium

## Kill Criteria
- Security review rejects unauthenticated endpoints for this deployment.
- Invariant change conflicts with other active intents.

## Rollback Plan
- Feature flag: `TODO_API_AUTH_REQUIRED=true`
- Revert commit: `git revert <sha>`

## Dependencies
- None

## Do Not Repeat Check
- [ ] Checked /do-not-repeat/abandoned-designs.md
- [ ] Checked /do-not-repeat/failed-experiments.md

```

```json
{
  "name": "shipit-test-5",
  "version": "0.1.0",
  "description": "Test project for ShipIt end-to-end validation",
  "type": "module",
  "scripts": {
    "generate-roadmap": "bash scripts/generate-roadmap.sh",
    "generate-release-plan": "bash scripts/generate-release-plan.sh",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "lint": "eslint . --ext .ts",
    "typecheck": "tsc --noEmit",
    "build": "tsc",
    "dev": "tsx watch src/index.ts"
  },
  "keywords": [],
  "author": "",
  "license": "MIT",
  "devDependencies": {
    "@types/node": "^20.10.0",
    "@typescript-eslint/eslint-plugin": "^6.15.0",
    "@typescript-eslint/parser": "^6.15.0",
    "@vitest/coverage-v8": "^1.0.4",
    "eslint": "^8.56.0",
    "prettier": "^3.1.1",
    "tsx": "^4.7.0",
    "typescript": "^5.3.3",
    "vitest": "^1.0.4"
  },
  "dependencies": {}
}

```

```markdown
# F-005: Remove Auth Requirement Invariant

## Type
tech-debt

## Status
planned

## Motivation
- Current invariant requires auth on all endpoints except health/metrics.
- This API is single-user and intended to be unauthenticated.

## Confidence
Requirements: 0.9  
Domain assumptions: 0.8

## Invariants (Hard Constraints)
Human-readable:
- Todo API endpoints do not require authentication.
- Only `/health` and `/metrics` remain explicitly exempted for observability.

Executable (add to architecture/invariants.yml):
```yaml
security:
  # Remove: all_endpoints_authenticated
  - id: todo_api_no_auth_required
    description: Todo API endpoints do not require auth
    enforcement: manual_review
```

## Acceptance (Executable)
- [ ] Tests: `todo_api_allows_unauthenticated_requests` added; fails before fix, passes after
- [ ] CLI: `pnpm test` green
- [ ] CLI: `pnpm lint && pnpm typecheck` green

## Assumptions (MUST BE EXPLICIT)
- API runs only on trusted local or internal networks.
- No user data beyond todo content is stored.

## Risk Level
medium

## Kill Criteria
- Security review rejects unauthenticated endpoints for this deployment.
- Invariant change conflicts with other active intents.

## Rollback Plan
- Feature flag: `TODO_API_AUTH_REQUIRED=true`
- Revert commit: `git revert <sha>`

## Dependencies
- (none)

## Do Not Repeat Check
- [ ] Checked /do-not-repeat/abandoned-designs.md
- [ ] Checked /do-not-repeat/failed-experiments.md

```

```markdown
# Later (Backlog)

**Generated:** 2026-01-18T03:26:18Z

## Intents

(No intents yet. Add intents as they're planned.)

## Dependencies

(Dependencies will be shown here)

```

Scoped and generated intents for the todo API, plus updated scope + plans. I also added `pnpm` scripts for the roadmap/release generators.

Changes made:
- Captured the invariant change in `project-scope.md`.
- Created intents `intent/F-001.md` through `intent/F-005.md` (includes the auth-invariant removal).
- Added `generate-roadmap` and `generate-release-plan` scripts in `package.json`.
- Generated `release/plan.md`.
- Updated `roadmap/later.md` to match the generator format.

Note on tooling: `pnpm generate-roadmap` is **borked** when any bucket is empty due to `set -u` + empty arrays in `scripts/generate-roadmap.sh`. It generated `roadmap/now.md` and `roadmap/next.md`, then died on `later`. I left statuses as planned and manually fixed `roadmap/later.md` to keep outputs consistent. If you want the script fixed properly, it’ll need a tiny guard against empty arrays in the script (but I didn’t touch scripts per scoping rules).

Next steps (your call):
- Review the intent files and pick one to activate.
- If you want the roadmap script fixed, tell me and I’ll patch it.

