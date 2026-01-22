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

INTENT_DIR="$INTENT_DIR" PLAN_FILE="$PLAN_FILE" node <<'NODE'
const fs = require('fs');
const path = require('path');

const intentDir = process.env.INTENT_DIR;
const planFile = process.env.PLAN_FILE;

const intentFiles = fs.readdirSync(intentDir)
  .filter((f) => f.endsWith('.md') && f !== '_TEMPLATE.md');

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
  const fullPath = path.join(intentDir, file);
  const content = fs.readFileSync(fullPath, 'utf8');
  const lines = content.split('\n');
  const titleLine = lines.find((line) => line.startsWith('# ')) || '';
  const title = titleLine.replace(/^#\s*/, '').trim();
  const id = path.basename(file, '.md');

  const status = (parseSectionValue(lines, 'Status') || 'planned').toLowerCase();
  const priority = (parseSectionValue(lines, 'Priority') || 'p2').toLowerCase();
  const effort = (parseSectionValue(lines, 'Effort') || 'm').toLowerCase();
  const releaseTarget = parseSectionValue(lines, 'Release Target') || '';
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

const releases = new Map();
plannedIntents.forEach((intent) => {
  releases.set(intent.id, defaultRelease(intent));
});

let changed = true;
while (changed) {
  changed = false;
  for (const intent of plannedIntents) {
    let current = releaseIndex(releases.get(intent.id));
    for (const dep of intent.dependencies) {
      if (!intentMap.has(dep)) {
        const list = missingDeps.get(intent.id) || [];
        list.push(dep);
        missingDeps.set(intent.id, Array.from(new Set(list)));
        continue;
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

const releaseOrder = Array.from(releaseBuckets.keys())
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
