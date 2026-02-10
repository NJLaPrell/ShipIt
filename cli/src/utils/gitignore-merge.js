/**
 * .gitignore merge for upgrade - append ShipIt patterns if missing
 */

import { readFileSync, writeFileSync, existsSync } from 'fs';
import { join } from 'path';

const SHIPIT_PATTERNS = [
  '',
  '# ShipIt',
  '._shipit_backup/',
  '_system/artifacts/usage.json',
  ''
];

/**
 * Merge ShipIt patterns into .gitignore
 * @param {string} projectPath - Project root
 * @param {object} options - { dryRun, verbose }
 * @returns {boolean} True if file was updated
 */
export function mergeGitignore(projectPath, options = {}) {
  const { dryRun = false, verbose = false } = options;
  const gitignorePath = join(projectPath, '.gitignore');

  let existing = '';
  if (existsSync(gitignorePath)) {
    existing = readFileSync(gitignorePath, 'utf-8');
  }

  const hasBackup = existing.includes('._shipit_backup');
  if (hasBackup) {
    if (verbose) console.log('  .gitignore already has ShipIt patterns');
    return false;
  }

  const toAppend = SHIPIT_PATTERNS.join('\n');
  const newContent = existing.trimEnd() ? `${existing.trimEnd()}\n${toAppend}\n` : `${toAppend}\n`;

  if (!dryRun) {
    writeFileSync(gitignorePath, newContent, 'utf-8');
  }
  return true;
}
