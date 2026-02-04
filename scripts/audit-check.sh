#!/bin/bash

# Audit guard with allowlist and expiry checks.

set -euo pipefail

AUDIT_LEVEL="${1:-moderate}"
ALLOWLIST_FILE="_system/security/audit-allowlist.json"

if ! command -v pnpm >/dev/null 2>&1; then
    echo "ERROR: pnpm is required to run audit checks" >&2
    exit 1
fi

if [ -f "$ALLOWLIST_FILE" ]; then
    ALLOWLIST_JSON="$(cat "$ALLOWLIST_FILE")"
else
    ALLOWLIST_JSON='{"advisories":[]}'
fi

AUDIT_JSON="$(pnpm audit --json || true)"
if [ -z "$AUDIT_JSON" ]; then
    echo "ERROR: pnpm audit returned no output" >&2
    exit 1
fi

printf "%s" "$AUDIT_JSON" | AUDIT_LEVEL="$AUDIT_LEVEL" AUDIT_ALLOWLIST_JSON="$ALLOWLIST_JSON" node <<'NODE'
const fs = require('fs');

const input = fs.readFileSync(0, 'utf8');
const audit = JSON.parse(input || '{}');
const allowlist = JSON.parse(process.env.AUDIT_ALLOWLIST_JSON || '{"advisories":[]}');
const level = process.env.AUDIT_LEVEL || 'moderate';

const levels = { info: 0, low: 1, moderate: 2, high: 3, critical: 4 };
if (!(level in levels)) {
  console.error(`ERROR: Invalid audit level "${level}"`);
  process.exit(2);
}

const threshold = levels[level];
const advisories = audit.advisories || {};
const findings = Object.values(advisories).map((a) => ({
  id: String(a.id),
  severity: a.severity || 'info',
  title: a.title || '',
  url: a.url || '',
  recommendation: a.recommendation || '',
}));

const scoped = findings.filter((f) => (levels[f.severity] ?? 0) >= threshold);
const allow = new Map((allowlist.advisories || []).map((a) => [String(a.id), a]));
const today = new Date().toISOString().slice(0, 10);

const unlisted = [];
const expired = [];
const invalid = [];
const allowed = [];

for (const f of scoped) {
  const entry = allow.get(String(f.id));
  if (!entry) {
    unlisted.push(f);
    continue;
  }

  if (!entry.reason || !entry.expires) {
    invalid.push({
      ...f,
      missingReason: !entry.reason,
      missingExpires: !entry.expires,
    });
    continue;
  }

  if (entry.expires < today) {
    expired.push({ ...f, expires: entry.expires, reason: entry.reason || '' });
    continue;
  }

  allowed.push({ ...f, expires: entry.expires || '', reason: entry.reason || '' });
}

if (scoped.length === 0) {
  console.log(`✓ pnpm audit: no ${level}+ vulnerabilities`);
  process.exit(0);
}

if (unlisted.length || expired.length || invalid.length) {
  console.error(
    `✗ pnpm audit: ${unlisted.length} unlisted, ${expired.length} expired, ${invalid.length} invalid allowlist entries`
  );

  if (unlisted.length) {
    console.error('Unlisted advisories:');
    for (const f of unlisted) {
      console.error(`- ${f.id} ${f.severity} ${f.title}`);
    }
  }

  if (expired.length) {
    console.error('Expired advisories:');
    for (const f of expired) {
      console.error(`- ${f.id} ${f.severity} ${f.title} (expired ${f.expires})`);
    }
  }

  if (invalid.length) {
    console.error('Invalid allowlist entries (missing reason/expires):');
    for (const f of invalid) {
      const missing = [];
      if (f.missingReason) missing.push('reason');
      if (f.missingExpires) missing.push('expires');
      console.error(`- ${f.id} ${f.severity} ${f.title} (missing ${missing.join(', ')})`);
    }
  }

  process.exit(1);
}

console.log(`✓ pnpm audit: ${scoped.length} ${level}+ advisories allowlisted`);
for (const f of allowed) {
  console.log(`- ${f.id} ${f.severity} ${f.title}`);
}
NODE
