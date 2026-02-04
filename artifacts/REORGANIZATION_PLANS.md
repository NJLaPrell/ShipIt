# Reorganization Plans: Intuitive Layout for Users

**Goal:** Organize the repo so users who "don't want to see most things they don't need to view or modify" get a clear, minimal mental model. Reduce root clutter and separate "daily use" from "framework/infra" and "generated."

**Current pain:** ~20+ top-level items (dirs + key files). Mix of human docs, agent docs, generated output, config, code, and "don't touch" ledgers with no obvious grouping.

---

## Plan A: "Clean root — framework under `.shipit/`"

**Idea:** Root shows only what a typical user interacts with daily. Everything that is "framework machinery" or "don't touch" lives under one hidden directory.

**Root after change:**

- **Docs:** `README.md`, `AGENTS.md`, `CHANGELOG.md`, `PILOT_GUIDE.md`
- **Config:** `package.json`, `tsconfig*.json`, `.gitignore`, `.eslintrc.json`, etc.
- **Branding:** `shipit.png`
- **User-facing dirs:** `intent/`, `workflow-state/`, `roadmap/`, `release/`, `src/`, `tests/`, `projects/`
- **Hidden/standard:** `.cursor/`, `.github/`, `.husky/`, `.vscode/`

**Under `.shipit/`:**

- `architecture/` (CANON, invariants, schemas, ADRs)
- `do-not-repeat/` (abandoned-designs, bad-patterns, etc.)
- `drift/` (baselines, metrics)
- `behaviors/` (release procedures, issue tracking)
- `security/` (audit-allowlist)
- `artifacts/` (SYSTEM_STATE, dependencies, confidence-calibration)
- `reports/` (mutation, etc.)
- `golden-data/`
- `scripts/` (all shell scripts + lib)

**Result:** Root has ~7–8 directories a user cares about + docs/config. "Where do I work?" → intent, workflow-state, roadmap, release. "Where's the code?" → src, tests. Framework guts are out of sight under `.shipit/`.

**Risk: HIGH**

- Every script assumes `scripts/`, `architecture/`, `artifacts/`, `workflow-state/`, etc. at repo root.
- All `.cursor/` commands and rules reference those paths.
- `init-project.sh` creates directories at project root and copies scripts; it would need to create `.shipit/` and wire paths.
- `package.json` scripts use `./scripts/...`; would become `./.shipit/scripts/...`.
- High touch count: 20+ scripts, 15+ .cursor files, init-project, CI if it ever paths into these dirs.

**Recommendation:** Strong payoff for "intuitive," but expensive and error-prone. Only do this if you're willing to run a dedicated refactor pass and full regression (e.g. `/test_shipit`, init-project, all slash commands).

---

## Plan B: "Two buckets — `work/` and `_system/`"

**Idea:** Keep path depth low but group by audience. Two new top-level dirs; no hidden dot-dir.

**Root after change:**

- Same docs and config as now (README, AGENTS, CHANGELOG, PILOT_GUIDE, package.json, tsconfig, etc.)
- `src/`, `tests/`, `scripts/`, `.cursor/`, `.github/`, `projects/` unchanged at root.

**New `work/` (what I'm doing):**

- `work/intent/` (features, bugs, tech-debt)
- `work/workflow-state/` (phase files, active, blocked, shipped, etc.)
- `work/roadmap/` (now, next, later)
- `work/release/` (plan.md)

**New `_system/` or `system/` (framework / don't touch):**

- `_system/architecture/`
- `_system/do-not-repeat/`
- `_system/drift/`
- `_system/behaviors/`
- `_system/security/`
- `_system/artifacts/`
- `_system/reports/`
- `_system/golden-data/`

**Result:** "My work" lives under `work/`, "framework and generated stuff" under `_system/`. Root has fewer top-level dirs; scripts stay at root so `pnpm run` and Cursor commands keep working with path updates.

**Risk: MEDIUM**

- Same set of references as Plan A, but scripts stay at root (no package.json script path change). All path strings in scripts and .cursor files need updating: `intent/` → `work/intent/`, `workflow-state/` → `work/workflow-state/`, `architecture/` → `_system/architecture/`, `artifacts/` → `_system/artifacts/`, etc.
- init-project must create `work/` and `_system/` and mirror the new layout. Mechanical but many lines.

**Recommendation:** Good balance. Clear mental model (work vs system) and no dot-dir. Doable in a focused refactor with grep-and-replace plus init-project and test pass.

---

## Plan C: "Minimal moves — `docs/` + `generated/`"

**Idea:** Smallest change that still improves intuition. Only two new top-level dirs; move "long-form docs" and "all generated output" into them.

**Root after change:**

- **New `docs/`:** Move `DIRECTORY_STRUCTURE.md`, `PLAN.md`, `PILOT_GUIDE.md` here. Keep `README.md`, `AGENTS.md`, `CHANGELOG.md` at root (entry points).
- **New `generated/`:** Move **contents** of: `artifacts/`, `release/`, `roadmap/`, `drift/`, `reports/` into a single `generated/` tree, e.g.:
  - `generated/artifacts/` (SYSTEM_STATE.md, dependencies.md, confidence-calibration.json)
  - `generated/release/` (plan.md)
  - `generated/roadmap/` (now.md, next.md, later.md)
  - `generated/drift/` (baselines.md, metrics.md)
  - `generated/reports/` (mutation/, etc.)
- **Unchanged:** `intent/`, `workflow-state/`, `architecture/`, `do-not-repeat/`, `behaviors/`, `security/`, `scripts/`, `src/`, `tests/`, `projects/`, `golden-data/`, `.cursor/`, etc.

**Result:** "Generated" is one place; "extra docs" are in `docs/`. Users can ignore `generated/` unless they care about release plan / roadmap / drift. No change to where intents or workflow state live.

**Risk: LOW**

- Only paths that change: `artifacts/` → `generated/artifacts/`, `release/` → `generated/release/`, `roadmap/` → `generated/roadmap/`, `drift/` → `generated/drift/`, `reports/` → `generated/reports/`. Scripts and .cursor files that reference these need updates; intent/workflow-state/architecture/scripts stay the same.
- init-project creates `generated/` (and optionally `docs/`) and seeds them. Fewer moving parts than A or B.

**Recommendation:** Best first step. Low risk, clear win ("don't look in generated/ unless you need it"). You can do Plan B or A later on top of this if you want a stronger "work vs system" split.

---

## Summary table

| Plan | Risk   | Touch count | Intuition gain                         | Best for                   |
| ---- | ------ | ----------- | -------------------------------------- | -------------------------- |
| A    | High   | Very high   | Highest (clean root, framework hidden) | Greenfield or big refactor |
| B    | Medium | High        | High (work vs system)                  | Willing to refactor once   |
| C    | Low    | Moderate    | Moderate (generated + docs grouped)    | Quick, safe improvement    |

---

## My recommendation

1. **Do Plan C first.** Low risk, moderate payoff, and it doesn’t block a later restructure. Gets "generated" and long-form docs out of the way so the root feels less noisy.
2. **If you want a clearer "what I use daily" story next,** do Plan B: introduce `work/` and `_system/` and migrate paths. That gives you the "work vs system" mental model without hiding scripts in a dot-dir.
3. **Reserve Plan A** for when you’re ready for a full, one-time refactor and regression pass (e.g. dedicated sprint). The result is the cleanest root but the cost is real.

**Bottom line:** Plan C → then consider B. Skip A unless you explicitly want the "everything framework under `.shipit/`" layout and are willing to pay the refactor cost.
