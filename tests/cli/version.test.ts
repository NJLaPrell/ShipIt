/**
 * Unit tests for CLI version comparison (pure logic)
 * E2E CLI tests are in tests/cli/*.sh and run via tests/cli/run-tests.sh
 */

import { describe, it, expect } from 'vitest';

// Version comparison is in cli/src/utils/version.js (ESM)
// We test the semver comparison logic via dynamic import
async function getCompareVersions() {
  const mod = await import('../../cli/src/utils/version.js');
  return mod.compareVersions;
}

describe('compareVersions', () => {
  it('returns same for identical versions', async () => {
    const compare = await getCompareVersions();
    expect(compare('0.6.0', '0.6.0')).toBe('same');
  });

  it('returns newer when installed is higher', async () => {
    const compare = await getCompareVersions();
    expect(compare('0.7.0', '0.6.0')).toBe('newer');
    expect(compare('0.6.1', '0.6.0')).toBe('newer');
    expect(compare('1.0.0', '0.9.9')).toBe('newer');
  });

  it('returns older when project is higher', async () => {
    const compare = await getCompareVersions();
    expect(compare('0.6.0', '0.7.0')).toBe('older');
    expect(compare('0.6.0', '0.6.1')).toBe('older');
  });

  it('returns unknown for empty or invalid', async () => {
    const compare = await getCompareVersions();
    expect(compare('', '0.6.0')).toBe('unknown');
    expect(compare('0.6.0', '')).toBe('unknown');
    expect(compare('x.y.z', '0.6.0')).toBe('unknown');
  });
});
