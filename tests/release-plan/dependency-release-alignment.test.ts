import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { describe, expect, it } from 'vitest';

function writeFile(filePath: string, contents: string) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, contents, 'utf8');
}

function parseReleaseNumber(release: string): number {
  const m = release.match(/^R(\d+)$/i);
  return m ? Number(m[1]) : Number.NaN;
}

function parsePlanIntentReleaseMap(planMd: string): Map<string, number> {
  const map = new Map<string, number>();
  const lines = planMd.split('\n');

  let currentRelease: number | null = null;
  for (const raw of lines) {
    const line = raw.trim();
    const releaseMatch = line.match(/^##\s+(R\d+)\s*$/i);
    if (releaseMatch) {
      currentRelease = parseReleaseNumber(releaseMatch[1].toUpperCase());
      continue;
    }

    // Lines look like: "1. **F-001:** Title ..."
    const intentMatch = line.match(/^\d+\.\s+\*\*([A-Z]-\d+):\*\*/i);
    if (intentMatch && currentRelease != null) {
      map.set(intentMatch[1].toUpperCase(), currentRelease);
    }
  }

  return map;
}

function runGenerateReleasePlan(cwd: string) {
  const scriptPath = path.join(process.cwd(), 'scripts', 'generate-release-plan.sh');
  execFileSync('bash', [scriptPath], {
    cwd,
    env: process.env,
    stdio: 'pipe',
  });
}

describe('generate-release-plan dependency release alignment', () => {
  it('does not schedule a dependency into a later release than its dependent (explicit targets)', () => {
    const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'shipit-release-plan-'));

    writeFile(
      path.join(tmpDir, 'intent', 'features', 'F-001.md'),
      `# F-001: Dependent\n\n## Status\nplanned\n\n## Priority\np1\n\n## Effort\ns\n\n## Release Target\nR1\n\n## Dependencies\n- F-002\n`
    );
    writeFile(
      path.join(tmpDir, 'intent', 'features', 'F-002.md'),
      `# F-002: Dependency\n\n## Status\nplanned\n\n## Priority\np2\n\n## Effort\ns\n\n## Release Target\nR2\n\n## Dependencies\n- (none)\n`
    );

    runGenerateReleasePlan(tmpDir);

    const planPath = path.join(tmpDir, 'release', 'plan.md');
    const plan = fs.readFileSync(planPath, 'utf8');
    const releases = parsePlanIntentReleaseMap(plan);

    const f001 = releases.get('F-001');
    const f002 = releases.get('F-002');
    expect(f001).toBeTypeOf('number');
    expect(f002).toBeTypeOf('number');
    if (typeof f001 !== 'number' || typeof f002 !== 'number') {
      throw new Error('Expected both F-001 and F-002 to appear in release/plan.md');
    }
    expect(f002).toBeLessThanOrEqual(f001);
  });

  it('does not schedule a dependency into a later release than its dependent (default targets)', () => {
    const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'shipit-release-plan-'));

    // Default release from priorityToRelease: p0 -> R1, p2 -> R2.
    writeFile(
      path.join(tmpDir, 'intent', 'features', 'F-001.md'),
      `# F-001: Dependent\n\n## Status\nplanned\n\n## Priority\np0\n\n## Effort\ns\n\n## Dependencies\n- F-002\n`
    );
    writeFile(
      path.join(tmpDir, 'intent', 'features', 'F-002.md'),
      `# F-002: Dependency\n\n## Status\nplanned\n\n## Priority\np2\n\n## Effort\ns\n\n## Dependencies\n- (none)\n`
    );

    runGenerateReleasePlan(tmpDir);

    const planPath = path.join(tmpDir, 'release', 'plan.md');
    const plan = fs.readFileSync(planPath, 'utf8');
    const releases = parsePlanIntentReleaseMap(plan);

    const f001 = releases.get('F-001');
    const f002 = releases.get('F-002');
    expect(f001).toBeTypeOf('number');
    expect(f002).toBeTypeOf('number');
    if (typeof f001 !== 'number' || typeof f002 !== 'number') {
      throw new Error('Expected both F-001 and F-002 to appear in release/plan.md');
    }
    expect(f002).toBeLessThanOrEqual(f001);
  });
});
