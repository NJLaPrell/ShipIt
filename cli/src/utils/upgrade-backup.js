/**
 * Upgrade backup and file-modification detection
 */

import { readFileSync, existsSync, readdirSync, statSync } from 'fs';
import { join, dirname } from 'path';
import { createHash } from 'crypto';
import fsExtra from 'fs-extra';

const { copySync, mkdirSync } = fsExtra;

const BACKUP_DIR = '._shipit_backup';
const TIMESTAMP_FORMAT = (d) => d.toISOString().replace(/[-:]/g, '').slice(0, 15); // YYYYMMDDTHHMMSS

/**
 * Calculate SHA-256 hash of file
 * @param {string} filePath - Absolute path
 * @returns {string|null} Hex hash or null if not found
 */
export function calculateFileHash(filePath) {
  if (!existsSync(filePath)) return null;
  try {
    const content = readFileSync(filePath);
    return createHash('sha256').update(content).digest('hex');
  } catch {
    return null;
  }
}

/**
 * Check if project file differs from framework file
 * @param {string} projectPath - Project root
 * @param {string} frameworkRoot - Framework root
 * @param {string} relativeFilePath - Path relative to root (e.g. 'scripts/verify.sh')
 * @returns {boolean} True if file is modified (different from framework)
 */
export function isFileModified(projectPath, frameworkRoot, relativeFilePath) {
  const projectFile = join(projectPath, relativeFilePath);
  const frameworkFile = join(frameworkRoot, relativeFilePath);
  if (!existsSync(projectFile)) return false;
  if (!existsSync(frameworkFile)) return false;
  const projectHash = calculateFileHash(projectFile);
  const frameworkHash = calculateFileHash(frameworkFile);
  return projectHash !== frameworkHash;
}

/**
 * Backup a file to ._shipit_backup/
 * @param {string} projectPath - Project root
 * @param {string} relativeFilePath - Path relative to project (e.g. 'scripts/verify.sh')
 * @param {string} backupDir - Backup directory name (default ._shipit_backup)
 * @returns {string} Path to backup file
 */
export function backupFile(projectPath, relativeFilePath, backupDir = BACKUP_DIR) {
  const src = join(projectPath, relativeFilePath);
  if (!existsSync(src)) throw new Error(`File not found: ${relativeFilePath}`);
  const timestamp = TIMESTAMP_FORMAT(new Date());
  const backupRelative = `${relativeFilePath}.${timestamp}`;
  const backupFull = join(projectPath, backupDir, backupRelative);
  const backupParent = join(backupFull, '..');
  mkdirSync(backupParent, { recursive: true });
  copySync(src, backupFull, { overwrite: true });
  return backupFull;
}

/**
 * List backups in project's backup directory
 * @param {string} projectPath - Project root
 * @param {string} backupDir - Backup directory name
 * @returns {Array<{path: string, original: string, timestamp: string}>}
 */
export function listBackups(projectPath, backupDir = BACKUP_DIR) {
  const dir = join(projectPath, backupDir);
  if (!existsSync(dir)) return [];
  const out = [];
  function walk(current, prefix = '') {
    const entries = readdirSync(current, { withFileTypes: true });
    for (const e of entries) {
      const rel = prefix ? `${prefix}/${e.name}` : e.name;
      const full = join(current, e.name);
      if (e.isDirectory()) walk(full, rel);
      else if (e.isFile() && /\.\d{8}T\d{6}$/.test(e.name)) {
        const original = rel.replace(/\.\d{8}T\d{6}$/, '');
        const timestamp = e.name.slice(-15);
        out.push({ path: full, original: join(projectPath, original), timestamp, relative: rel });
      }
    }
  }
  walk(dir);
  return out.sort((a, b) => b.timestamp.localeCompare(a.timestamp));
}

/**
 * Restore a file from backup
 * @param {string} backupFilePath - Full path to backup file
 * @param {string|null} targetPath - Full path to restore to (if null, derived from backup path: remove backup dir and timestamp)
 * @param {string} projectPath - Project root (required when targetPath is null)
 * @param {string} backupDir - Backup directory name (required when targetPath is null)
 * @param {boolean} removeBackup - Remove backup after restore
 */
export function restoreFromBackup(backupFilePath, targetPath, projectPath = null, backupDir = BACKUP_DIR, removeBackup = false) {
  if (!existsSync(backupFilePath)) throw new Error(`Backup not found: ${backupFilePath}`);
  let target = targetPath;
  if (!target && projectPath) {
    const backupPrefix = join(projectPath, backupDir);
    const rel = backupFilePath.startsWith(backupPrefix)
      ? backupFilePath.slice(backupPrefix.length + 1).replace(/\.\d{8}T\d{6}$/, '')
      : backupFilePath.replace(/\.\d{8}T\d{6}$/, '');
    target = join(projectPath, rel);
  } else if (!target) {
    target = backupFilePath.replace(/\.\d{8}T\d{6}$/, '');
  }
  mkdirSync(dirname(target), { recursive: true });
  copySync(backupFilePath, target, { overwrite: true });
  if (removeBackup) fsExtra.removeSync(backupFilePath);
}

/**
 * Collect all framework-owned file paths (relative) for upgrade
 * @param {string} frameworkRoot - Framework root
 * @param {object} manifest - Parsed framework-files-manifest
 * @param {Set<string>} neverCopied - Set of paths to skip
 * @returns {string[]} Relative file paths
 */
export function getFrameworkFileList(frameworkRoot, manifest, neverCopied) {
  const files = new Set();

  function addFile(rel) {
    if (neverCopied.has(rel) || rel.startsWith('.override')) return;
    const full = join(frameworkRoot, rel);
    if (existsSync(full) && statSync(full).isFile()) files.add(rel);
  }

  for (const dir of manifest.frameworkOwned?.directories || []) {
    const fullDir = join(frameworkRoot, dir);
    if (!existsSync(fullDir)) continue;
    walkDir(fullDir, dir, (rel) => addFile(rel));
  }
  for (const file of manifest.frameworkOwned?.files || []) {
    if (file === 'project.json') continue; // merged, not replaced
    addFile(file);
  }

  return [...files];
}

const SKIP_DIRS = new Set(['node_modules', '.git', 'dist', 'coverage', '.turbo']);

function walkDir(fullDir, prefix, add) {
  const entries = readdirSync(fullDir, { withFileTypes: true });
  for (const e of entries) {
    const rel = prefix ? `${prefix}/${e.name}` : e.name;
    const full = join(fullDir, e.name);
    if (e.isDirectory()) {
      if (SKIP_DIRS.has(e.name)) continue;
      walkDir(full, rel, add);
    } else if (e.isFile()) add(rel);
  }
}
