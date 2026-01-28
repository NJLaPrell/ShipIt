#!/bin/bash

# Generate Release Plan from Intents
# Produces release/plan.md with ordered intents by release/priority/dependencies

set -euo pipefail

error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

INTENT_DIR="intent"
RELEASE_DIR="release"
PLAN_FILE="$RELEASE_DIR/plan.md"

if [ ! -d "$INTENT_DIR" ]; then
    error_exit "Intent directory not found: $INTENT_DIR" 1
fi

if ! command -v node >/dev/null 2>&1; then
    error_exit "node is required to generate release plan" 1
fi

mkdir -p "$RELEASE_DIR"

# Run validation and show warnings
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/lib/validate-intents.sh" ]; then
    source "$SCRIPT_DIR/lib/validate-intents.sh" || true
    echo "Validating intents..."
    validation_output=$(validate_all_intents 2>&1 || true)
    validation_exit=$?
    if [ $validation_exit -ne 0 ] || [ -n "$validation_output" ]; then
        echo ""
        echo "⚠️  Validation warnings:"
        echo "$validation_output" | while IFS= read -r issue; do
            [ -z "$issue" ] && continue
            issue_type=$(echo "$issue" | cut -d'|' -f1)
            intent_id=$(echo "$issue" | cut -d'|' -f2)
            message=$(echo "$issue" | cut -d'|' -f3)
            echo "  • $intent_id: $message"
        done
        echo ""
        echo "💡 Run './scripts/fix-intents.sh' to auto-fix some issues"
        echo ""
    else
        echo "✓ No validation issues found"
        echo ""
    fi
fi

INTENT_DIR="$INTENT_DIR" PLAN_FILE="$PLAN_FILE" node <<'NODE'
const fs = require('fs');
const path = require('path');

const intentDir = process.env.INTENT_DIR;
const planFile = process.env.PLAN_FILE;

const collectIntentFiles = (dir) => {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...collectIntentFiles(fullPath));
    } else if (entry.isFile()) {
      files.push(fullPath);
    }
  }
  return files;
};

const intentFiles = collectIntentFiles(intentDir)
  .filter((file) => file.endsWith('.md') && path.basename(file) !== '_TEMPLATE.md');

const priorities = ['p0', 'p1', 'p2', 'p3'];
const efforts = ['s', 'm', 'l'];

const priorityToRelease = {
  p0: 'R1',
  p1: 'R1',
  p2: 'R2',
  p3: 'R3'
};

const parseSectionValue = (lines, header) => {
  const headerLine = `## ${header}`;
  const idx = lines.findIndex((line) => line.trim() === headerLine);
  if (idx === -1) return '';
  for (let i = idx + 1; i < lines.length; i++) {
    const line = lines[i].trim();
    if (!line) continue;
    if (line.startsWith('## ')) break;
    return line;
  }
  return '';
};

const normalizeReleaseTarget = (value) => {
  const match = String(value).match(/R\d+/i);
  return match ? match[0].toUpperCase() : '';
};

const parseReleaseTarget = (lines) => {
  const headerLine = '## Release Target';
  const idx = lines.findIndex((line) => line.trim().startsWith(headerLine));
  if (idx === -1) return '';

  // Handle inline "## Release Target: R1"
  const inline = normalizeReleaseTarget(lines[idx]);
  if (inline) return inline;

  for (let i = idx + 1; i < lines.length; i++) {
    const raw = lines[i].trim();
    if (!raw) continue;
    if (raw.startsWith('## ')) break;
    const line = raw.replace(/^[-*]\s*/, '');
    // Skip template option lines like "R1 | R2 | R3 | R4"
    if (/\bR1\b\s*\|\s*\bR2\b/i.test(line)) continue;
    const normalized = normalizeReleaseTarget(line);
    if (normalized) return normalized;
  }
  return '';
};

const parseDependencies = (lines) => {
  const headerLine = '## Dependencies';
  const idx = lines.findIndex((line) => line.trim() === headerLine);
  if (idx === -1) return [];
  const deps = [];
  for (let i = idx + 1; i < lines.length; i++) {
    const line = lines[i].trim();
    if (!line) continue;
    if (line.startsWith('## ')) break;
    if (line.startsWith('- ')) {
      const depLine = line.replace(/^- /, '').trim();
      // Extract just the intent ID (e.g., "F-002" from "F-002 (description)")
      // Skip lines starting with "None", placeholders like "[...]", or "(none)"
      if (!depLine || depLine.toLowerCase().startsWith('none') || depLine.startsWith('[') || depLine === '(none)') {
        continue;
      }
      // Extract ID: first word that looks like F-XXX, B-XXX, T-XXX, etc.
      const idMatch = depLine.match(/^([A-Z]-\d+)/i);
      if (idMatch) {
        deps.push(idMatch[1].toUpperCase());
      }
    }
  }
  return deps.filter(Boolean);
};

const intents = intentFiles.map((file) => {
  const content = fs.readFileSync(file, 'utf8');
  const lines = content.split('\n');
  const titleLine = lines.find((line) => line.startsWith('# ')) || '';
  const title = titleLine.replace(/^#\s*/, '').trim();
  const id = path.basename(file, '.md');

  const status = (parseSectionValue(lines, 'Status') || 'planned').toLowerCase();
  const priority = (parseSectionValue(lines, 'Priority') || 'p2').toLowerCase();
  const effort = (parseSectionValue(lines, 'Effort') || 'm').toLowerCase();
  const releaseTarget =
    parseReleaseTarget(lines) ||
    normalizeReleaseTarget(lines.find((line) => /release target:/i.test(line)) || '');
  const dependencies = parseDependencies(lines);

  return {
    id,
    title,
    status,
    priority: priorities.includes(priority) ? priority : 'p2',
    effort: efforts.includes(effort) ? effort : 'm',
    releaseTarget,
    dependencies
  };
});

const activeStatuses = new Set(['planned', 'active', 'blocked', 'validating']);
const plannedIntents = intents.filter((i) => activeStatuses.has(i.status));
const excludedIntents = intents.filter((i) => !activeStatuses.has(i.status));

const releaseIndex = (release) => {
  const match = String(release).match(/^R(\d+)$/i);
  if (!match) return 0;
  return Number(match[1]);
};

const defaultRelease = (intent) => {
  if (intent.releaseTarget) return intent.releaseTarget.toUpperCase();
  return priorityToRelease[intent.priority] || 'R2';
};

const intentMap = new Map(plannedIntents.map((i) => [i.id, i]));
const missingDeps = new Map();

// First pass: Track missing dependencies for ALL intents (before release assignment)
for (const intent of plannedIntents) {
  for (const dep of intent.dependencies) {
    if (!intentMap.has(dep)) {
      const list = missingDeps.get(intent.id) || [];
      list.push(dep);
      missingDeps.set(intent.id, Array.from(new Set(list)));
    }
  }
}

const releases = new Map();
const explicitReleaseTargets = new Set();
plannedIntents.forEach((intent) => {
  const explicit = intent.releaseTarget ? intent.releaseTarget.toUpperCase() : '';
  if (explicit) {
    releases.set(intent.id, explicit);
    explicitReleaseTargets.add(intent.id);
  } else {
    releases.set(intent.id, defaultRelease(intent));
  }
});

// Second pass: Adjust releases based on dependencies (for non-explicit targets)
let changed = true;
while (changed) {
  changed = false;
  for (const intent of plannedIntents) {
    if (explicitReleaseTargets.has(intent.id)) {
      continue;
    }
    let current = releaseIndex(releases.get(intent.id));
    for (const dep of intent.dependencies) {
      if (!intentMap.has(dep)) {
        continue; // Already tracked in missingDeps
      }
      const depRelease = releaseIndex(releases.get(dep));
      if (depRelease > current) {
        current = depRelease;
      }
    }
    const updated = `R${Math.max(1, current)}`;
    if (releases.get(intent.id) !== updated) {
      releases.set(intent.id, updated);
      changed = true;
    }
  }
}

// Third pass: If an intent has an explicit release target, ensure dependencies are in same or earlier release
// When both have explicit targets, dependencies must come before dependents
// FIX: Respect explicit targets - if dependency is later, move dependency (not dependent) to match
for (const intent of plannedIntents) {
  if (!explicitReleaseTargets.has(intent.id)) continue;
  const targetRelease = releaseIndex(releases.get(intent.id));
  for (const dep of intent.dependencies) {
    if (!intentMap.has(dep)) continue; // Already tracked in missingDeps
    const depRelease = releaseIndex(releases.get(dep));
    if (explicitReleaseTargets.has(dep)) {
      // Both have explicit targets: dependency must be in same or earlier release
      if (depRelease > targetRelease) {
        // Dependency is later than dependent - move dependency to match dependent's release
        // (Dependencies must ship before dependents, so dependency moves earlier)
        releases.set(dep, releases.get(intent.id));
        changed = true;
      }
    } else {
      // Dependency has no explicit target - move it to same or earlier release
      if (depRelease > targetRelease) {
        releases.set(dep, `R${Math.max(1, targetRelease)}`);
        changed = true;
      }
    }
  }
}

// Final pass: Re-adjust non-explicit targets if we moved explicit ones
if (changed) {
  changed = true;
  while (changed) {
    changed = false;
    for (const intent of plannedIntents) {
      if (explicitReleaseTargets.has(intent.id)) continue;
      let current = releaseIndex(releases.get(intent.id));
      for (const dep of intent.dependencies) {
        if (!intentMap.has(dep)) continue;
        const depRelease = releaseIndex(releases.get(dep));
        if (depRelease > current) {
          current = depRelease;
        }
      }
      const updated = `R${Math.max(1, current)}`;
      if (releases.get(intent.id) !== updated) {
        releases.set(intent.id, updated);
        changed = true;
      }
    }
  }
}

const releaseBuckets = new Map();
for (const intent of plannedIntents) {
  const release = releases.get(intent.id) || 'R2';
  const list = releaseBuckets.get(release) || [];
  list.push(intent);
  releaseBuckets.set(release, list);
}

const priorityRank = (priority) => priorities.indexOf(priority);
const effortRank = (effort) => efforts.indexOf(effort);

const topoSort = (items) => {
  const ids = new Set(items.map((i) => i.id));
  const incoming = new Map();
  const outgoing = new Map();

  items.forEach((item) => {
    incoming.set(item.id, new Set());
    outgoing.set(item.id, new Set());
  });

  items.forEach((item) => {
    item.dependencies.forEach((dep) => {
      if (!ids.has(dep)) return;
      incoming.get(item.id).add(dep);
      outgoing.get(dep).add(item.id);
    });
  });

  const queue = [];
  for (const [id, deps] of incoming.entries()) {
    if (deps.size === 0) queue.push(id);
  }

  const sortQueue = () => {
    queue.sort((a, b) => {
      const ia = items.find((i) => i.id === a);
      const ib = items.find((i) => i.id === b);
      const pr = priorityRank(ia.priority) - priorityRank(ib.priority);
      if (pr !== 0) return pr;
      const er = effortRank(ia.effort) - effortRank(ib.effort);
      if (er !== 0) return er;
      return ia.id.localeCompare(ib.id);
    });
  };

  sortQueue();
  const ordered = [];
  while (queue.length) {
    const id = queue.shift();
    ordered.push(id);
    for (const dep of outgoing.get(id)) {
      incoming.get(dep).delete(id);
      if (incoming.get(dep).size === 0) {
        queue.push(dep);
        sortQueue();
      }
    }
  }

  const remaining = items
    .map((i) => i.id)
    .filter((id) => !ordered.includes(id));

  return { ordered, remaining };
};

const baseReleases = ['R1', 'R2', 'R3', 'R4'];
const releaseOrder = Array.from(new Set([...baseReleases, ...releaseBuckets.keys()]))
  .sort((a, b) => releaseIndex(a) - releaseIndex(b));

const now = new Date().toISOString();
let output = `# Release Plan\n\n**Generated:** ${now}\n\n`;
output += `## Summary\n\n`;
output += `- Total intents: ${intents.length}\n`;
output += `- Planned intents: ${plannedIntents.length}\n`;
output += `- Releases: ${releaseOrder.length}\n\n`;

releaseOrder.forEach((release) => {
  const intentsInRelease = releaseBuckets.get(release) || [];
  const { ordered, remaining } = topoSort(intentsInRelease);
  output += `## ${release}\n\n`;
  if (ordered.length === 0) {
    output += `(No intents planned for ${release}.)\n\n`;
    return;
  }
  output += `### Intent Order\n\n`;
  ordered.forEach((id, index) => {
    const intent = intentsInRelease.find((i) => i.id === id);
    output += `${index + 1}. **${intent.id}:** ${intent.title} (priority ${intent.priority}, effort ${intent.effort}, status ${intent.status})\n`;
  });
  if (remaining.length) {
    output += `\n### Dependency Cycles / Unordered\n\n`;
    remaining.forEach((id) => {
      const intent = intentsInRelease.find((i) => i.id === id);
      output += `- **${intent.id}:** ${intent.title}\n`;
    });
  }
  output += `\n`;
});

if (missingDeps.size) {
  output += `## Missing Dependencies\n\n`;
  for (const [id, deps] of missingDeps.entries()) {
    output += `- **${id}:** ${deps.join(', ')}\n`;
  }
  output += `\n`;
}

if (excludedIntents.length) {
  output += `## Excluded (Already Shipped or Killed)\n\n`;
  excludedIntents.forEach((intent) => {
    output += `- **${intent.id}:** ${intent.title} (status ${intent.status})\n`;
  });
  output += `\n`;
}

fs.writeFileSync(planFile, output, 'utf8');
console.log(`✓ Generated release plan: ${planFile}`);
NODE

# Verify output and show summary
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/lib/verify-outputs.sh" ]; then
    source "$SCRIPT_DIR/lib/verify-outputs.sh"
    echo ""
    verify_file_exists "$PLAN_FILE" "Generated release/plan.md"
    
    # Count intents in plan
    if [ -f "$PLAN_FILE" ]; then
        intent_count=$(grep -c "^[0-9]\+\. \*\*" "$PLAN_FILE" 2>/dev/null || echo "0")
        release_count=$(grep -c "^## R[0-9]" "$PLAN_FILE" 2>/dev/null || echo "0")
        echo -e "${GREEN}✓${NC} Release plan contains $intent_count intent(s) across $release_count release(s)"
    fi
    
    # Show next-step suggestions
    if [ -f "$SCRIPT_DIR/lib/suggest-next.sh" ]; then
        source "$SCRIPT_DIR/lib/suggest-next.sh"
        display_suggestions "release-plan"
    fi
fi
