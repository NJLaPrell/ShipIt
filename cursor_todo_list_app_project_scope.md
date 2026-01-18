# Todo list app project scope
_Exported on 1/17/2026 at 20:05:03 MST from Cursor (2.3.35)_

---

**User**

/scope-project "Build a todo list app with CRUD, tagging, and persistence"

---

**Cursor**

```markdown
# Project Scope: shipit-test-4

**Generated:** 2026-01-18T03:02:37Z
**Description:** Build a todo list app with CRUD, tagging, and persistence

## AI Analysis

This project is a small, single-user todo list app on a TypeScript/Node.js stack. The core scope can be delivered as a simple HTTP API with file-backed persistence, with tagging as an extension of the base CRUD flow. A UI is not specified, so the initial release assumes API-only with tests validating behavior.

## Follow-Up Questions (with answers)

- Q: Is a UI required for the "app," or is an API-only backend acceptable?  
  A: Assume API-only for initial scope; UI can be added later if requested.
- Q: What persistence should be used (SQLite, JSON file, etc.)?  
  A: Assume JSON file persistence with atomic writes for simplicity.
- Q: Multi-user or single-user?  
  A: Assume single-user, local usage.
- Q: Authentication required?  
  A: Assume a static API key header to satisfy `all_endpoints_authenticated`.

## Open Questions (unanswered)

- Should the first release include a minimal web UI or CLI?
- Is SQLite preferred over JSON file persistence?
- Should tags be case-sensitive and unique per todo?
- Are there any UX expectations (sorting, paging, filtering by completion)?

## Feature Candidates

- F-101: Todo data model + persistence layer (JSON file, atomic writes).
- F-102: CRUD HTTP API for todos (create, list, update, delete).
- F-103: Tagging + filtering by tags in the API.
- F-104 (optional): Minimal UI or CLI for user interaction.

## Dependency Graph

- F-101 → (base)
- F-102 depends on F-101
- F-103 depends on F-101, F-102
- F-104 depends on F-102, F-103

## Architecture Suggestions

- HTTP API server (Express or Fastify) with a small service layer.
- File-backed repository using JSON + atomic write (write temp, rename).
- Validation at API boundary (schema or manual guards).
- Use a static API key header to satisfy auth invariant unless canon changes.

## Risk Assessment

- Persistence corruption risk if writes are not atomic.
- Auth invariant may force adding auth even for a local app.
- Concurrency and file locking could cause lost updates.
- Tags can expand payload size; ensure validation + size limits.

## Intent Selection

Selected for intent generation:
- F-101: Todo data model + persistence layer
- F-102: CRUD HTTP API for todos
- F-103: Tagging + filtering

Deferred:
- F-104: Minimal UI/CLI (await clarification)

## Release Plan

- R1: F-101 → F-102 → F-103 (deliver full CRUD + tagging with persistence)

## Generated Intents

- `intent/F-101.md`
- `intent/F-102.md`
- `intent/F-103.md`

---

*This file is populated by `/scope-project` and should be updated as scope changes.*

```

```markdown
# F-101: Todo data model + persistence layer

## Type
feature

## Status
planned

## Priority
p0

## Effort
m

## Release Target
R1

## Motivation
- Persist todos across restarts
- Establish a consistent data model for downstream features
- Enable CRUD API to rely on a stable repository

## Confidence
Requirements: 0.8  
Domain assumptions: 0.7

## Invariants (Hard Constraints)
Human-readable:
- No explicit `any` types
- No `eval()` usage
- Test coverage remains ≥ 80%

Executable (add to architecture/invariants.yml):
```yaml
invariants:
  - no_explicit_any
  - no_eval
  - code_coverage_minimum: 80
```

## Acceptance (Executable)
- [ ] Tests: `todoRepository_persists_to_disk` added; fails before fix, passes after
- [ ] CLI: `pnpm test` green
- [ ] CLI: `pnpm lint && pnpm typecheck` green

## Assumptions (MUST BE EXPLICIT)
- Persistence uses a JSON file on local disk
- Single-user access; no concurrent writers
- Data set stays small (< 5k todos)

## Risk Level
medium

## Kill Criteria
- Persistence cannot be made atomic without a database
- Data corruption observed in normal save/load cycle

## Rollback Plan
- Feature flag: `TODO_PERSISTENCE_ENABLED=false`
- Revert commit: `git revert <sha>`

## Dependencies
- (none)

## Do Not Repeat Check
- [x] Checked /do-not-repeat/abandoned-designs.md
- [x] Checked /do-not-repeat/failed-experiments.md

```

```markdown
# F-102: Todo CRUD HTTP API

## Type
feature

## Status
planned

## Priority
p0

## Effort
m

## Release Target
R1

## Motivation
- Provide API endpoints for creating, reading, updating, deleting todos
- Enable future UI/CLI to integrate with stable endpoints
- Expose filtering and ordering hooks for the tagging feature

## Confidence
Requirements: 0.75  
Domain assumptions: 0.7

## Invariants (Hard Constraints)
Human-readable:
- All endpoints require auth except `/health` and `/metrics`
- No explicit `any` types
- No `eval()` usage
- Test coverage remains ≥ 80%

Executable (add to architecture/invariants.yml):
```yaml
invariants:
  - all_endpoints_authenticated
  - no_explicit_any
  - no_eval
  - code_coverage_minimum: 80
```

## Acceptance (Executable)
- [ ] Tests: `todoApi_create_list_update_delete` added; fails before fix, passes after
- [ ] Tests: `todoApi_requires_auth` added; fails before fix, passes after
- [ ] CLI: `pnpm test` green
- [ ] CLI: `pnpm lint && pnpm typecheck` green

## Assumptions (MUST BE EXPLICIT)
- API runs on a single Node.js process
- Simple API key header satisfies auth invariant
- Endpoints are JSON over HTTP

## Risk Level
medium

## Kill Criteria
- Auth invariant cannot be satisfied without full auth system
- API framework choice introduces undue complexity

## Rollback Plan
- Feature flag: `TODO_API_ENABLED=false`
- Revert commit: `git revert <sha>`

## Dependencies
- F-101

## Do Not Repeat Check
- [x] Checked /do-not-repeat/abandoned-designs.md
- [x] Checked /do-not-repeat/failed-experiments.md

```

```markdown
# F-103: Tagging + filtering for todos

## Type
feature

## Status
planned

## Priority
p1

## Effort
s

## Release Target
R1

## Motivation
- Allow users to group todos with tags
- Support filtering by tag for improved organization
- Extend the core data model without changing API basics

## Confidence
Requirements: 0.75  
Domain assumptions: 0.7

## Invariants (Hard Constraints)
Human-readable:
- All endpoints require auth except `/health` and `/metrics`
- No explicit `any` types
- No `eval()` usage
- Test coverage remains ≥ 80%

Executable (add to architecture/invariants.yml):
```yaml
invariants:
  - all_endpoints_authenticated
  - no_explicit_any
  - no_eval
  - code_coverage_minimum: 80
```

## Acceptance (Executable)
- [ ] Tests: `todoTags_add_remove_filter` added; fails before fix, passes after
- [ ] CLI: `pnpm test` green
- [ ] CLI: `pnpm lint && pnpm typecheck` green

## Assumptions (MUST BE EXPLICIT)
- Tags are strings stored per todo item
- Duplicate tags on a todo are ignored
- Tag filtering uses exact match (case-sensitive)

## Risk Level
low

## Kill Criteria
- Tag storage significantly complicates persistence format
- Filtering performance degrades beyond expected usage

## Rollback Plan
- Feature flag: `TODO_TAGS_ENABLED=false`
- Revert commit: `git revert <sha>`

## Dependencies
- F-101
- F-102

## Do Not Repeat Check
- [x] Checked /do-not-repeat/abandoned-designs.md
- [x] Checked /do-not-repeat/failed-experiments.md

```

```shellscript
#!/bin/bash

# Generate Project Roadmap from Intents
# Creates roadmap files and dependency visualization

set -euo pipefail

error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

INTENT_DIR="intent"
ROADMAP_DIR="roadmap"

if [ ! -d "$INTENT_DIR" ]; then
    error_exit "Intent directory not found: $INTENT_DIR" 1
fi

echo -e "${BLUE}Generating project roadmap...${NC}"

# Initialize roadmap files
mkdir -p "$ROADMAP_DIR"

# Extract intents and categorize
declare -a NOW_INTENTS=()
declare -a NEXT_INTENTS=()
declare -a LATER_INTENTS=()

for intent_file in "$INTENT_DIR"/*.md; do
    [ -f "$intent_file" ] || continue
    
    INTENT_ID=$(basename "$intent_file" .md)
    
    # Skip template
    if [ "$INTENT_ID" = "_TEMPLATE" ]; then
        continue
    fi
    
    # Extract status and dependencies
    STATUS=$(grep "^## Status" "$intent_file" | head -1 | awk '{print $3}' || echo "planned")
    DEPENDENCIES=$(grep -A 10 "^## Dependencies" "$intent_file" | grep "^-" | sed 's/^- //' || echo "")
    
    # Simple categorization (can be enhanced)
    if [ "$STATUS" = "active" ] || [ "$STATUS" = "planned" ]; then
        if [ -z "$DEPENDENCIES" ]; then
            NOW_INTENTS+=("$INTENT_ID")
        else
            NEXT_INTENTS+=("$INTENT_ID")
        fi
    elif [ "$STATUS" = "blocked" ]; then
        NEXT_INTENTS+=("$INTENT_ID")
    else
        LATER_INTENTS+=("$INTENT_ID")
    fi
done

# Generate roadmap files
generate_roadmap_file() {
    local file="$1"
    local title="$2"
    local intents=("${@:3}")
    
    cat > "$file" << EOF || error_exit "Failed to create $file"
# $title

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Intents

EOF

    if [ ${#intents[@]} -eq 0 ]; then
        echo "(No intents yet. Add intents as they're planned.)" >> "$file"
    else
        for intent_id in "${intents[@]}"; do
            INTENT_FILE="$INTENT_DIR/$intent_id.md"
            if [ -f "$INTENT_FILE" ]; then
                TITLE=$(grep "^# " "$INTENT_FILE" | head -1 | sed 's/^# //' || echo "$intent_id")
                echo "- **$intent_id:** $TITLE" >> "$file"
            fi
        done
    fi
    
    echo "" >> "$file"
    echo "## Dependencies" >> "$file"
    echo "" >> "$file"
    echo "(Dependencies will be shown here)" >> "$file"
}

generate_roadmap_file "$ROADMAP_DIR/now.md" "Now (Current Sprint)" "${NOW_INTENTS[@]-}"
generate_roadmap_file "$ROADMAP_DIR/next.md" "Next (Upcoming)" "${NEXT_INTENTS[@]-}"
generate_roadmap_file "$ROADMAP_DIR/later.md" "Later (Backlog)" "${LATER_INTENTS[@]-}"

echo -e "${GREEN}✓ Generated roadmap files${NC}"

# Generate dependency graph
DEPENDENCY_FILE="dependencies.md"
cat > "$DEPENDENCY_FILE" << EOF || error_exit "Failed to create dependency file"
# Feature Dependency Graph

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Dependency Graph

EOF

for intent_file in "$INTENT_DIR"/*.md; do
    [ -f "$intent_file" ] || continue
    
    INTENT_ID=$(basename "$intent_file" .md)
    [ "$INTENT_ID" = "_TEMPLATE" ] && continue
    
    TITLE=$(grep "^# " "$intent_file" | head -1 | sed 's/^# //' || echo "$intent_id")
    DEPENDENCIES=$(grep -A 10 "^## Dependencies" "$intent_file" | grep "^-" | sed 's/^- //' || echo "")
    
    echo "### $INTENT_ID: $TITLE" >> "$DEPENDENCY_FILE"
    if [ -n "$DEPENDENCIES" ]; then
        echo "$DEPENDENCIES" | while read -r dep; do
            echo "  └─> $dep" >> "$DEPENDENCY_FILE"
        done
    else
        echo "  (no dependencies)" >> "$DEPENDENCY_FILE"
    fi
    echo "" >> "$DEPENDENCY_FILE"
done

echo -e "${GREEN}✓ Generated dependency graph: $DEPENDENCY_FILE${NC}"
echo ""
echo -e "${YELLOW}Roadmap generated:${NC}"
echo "  - $ROADMAP_DIR/now.md (${#NOW_INTENTS[@]} intents)"
echo "  - $ROADMAP_DIR/next.md (${#NEXT_INTENTS[@]} intents)"
echo "  - $ROADMAP_DIR/later.md (${#LATER_INTENTS[@]} intents)"
echo "  - $DEPENDENCY_FILE"

```

Built out the project scope and generated the initial intents/release artifacts. Also fixed the roadmap script that was borked on empty arrays.

What I changed and why:
- Filled `project-scope.md` with assumptions, feature breakdown, dependencies, risks, and a release outline for the todo CRUD + tagging + persistence scope.
- Created intents `intent/F-101.md`, `intent/F-102.md`, `intent/F-103.md` covering persistence, CRUD API, and tagging.
- Regenerated `release/plan.md`, `roadmap/now.md`, `roadmap/next.md`, `roadmap/later.md`, and `dependencies.md`.
- Patched `scripts/generate-roadmap.sh` to avoid `set -u` array errors on macOS bash.

Notes/assumptions baked into scope:
- API-only for initial release (UI/CLI deferred).
- JSON file persistence with atomic writes.
- Single-user and a static API key header for auth (per `all_endpoints_authenticated` invariant).

Next steps (pick what you want):
- Review `project-scope.md` for any mismatched assumptions.
- If UI/CLI is required, I’ll add F-104 and update the scope + intents.
- Approve intents and move into the PM/QA flow for F-101.

If you want me to adjust the scope or split/merge intents, say the word.

