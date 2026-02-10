/**
 * Version detection and comparison for ShipIt upgrade
 */

import { readFileSync, existsSync } from 'fs';
import { join } from 'path';
import { getFrameworkRoot } from './manifest.js';

/**
 * Get installed ShipIt version from package
 * @returns {string} Version string (e.g. "1.0.0")
 */
export function getInstalledShipItVersion() {
  const root = getFrameworkRoot();
  const pkgPath = join(root, 'package.json');
  if (!existsSync(pkgPath)) {
    throw new Error('ShipIt not found. Install: npm install -g @nlaprell/shipit');
  }
  const pkg = JSON.parse(readFileSync(pkgPath, 'utf-8'));
  return pkg.version || '0.0.0';
}

/**
 * Get project's ShipIt version from project.json
 * @param {string} projectPath - Project root path
 * @returns {string|null} Version or null if missing
 */
export function getProjectShipItVersion(projectPath) {
  const projectJsonPath = join(projectPath, 'project.json');
  if (!existsSync(projectJsonPath)) return null;
  try {
    const data = JSON.parse(readFileSync(projectJsonPath, 'utf-8'));
    return data.shipitVersion ?? null;
  } catch {
    return null;
  }
}

/**
 * Compare two semver strings
 * @param {string} installed - Installed version
 * @param {string} project - Project version
 * @returns {'same'|'newer'|'older'|'unknown'} Comparison result
 */
export function compareVersions(installed, project) {
  if (!installed || !project) return 'unknown';
  const a = parseVersion(installed);
  const b = parseVersion(project);
  if (!a || !b) return 'unknown';
  if (a.major !== b.major) return a.major > b.major ? 'newer' : 'older';
  if (a.minor !== b.minor) return a.minor > b.minor ? 'newer' : 'older';
  if (a.patch !== b.patch) return a.patch > b.patch ? 'newer' : 'older';
  return 'same';
}

function parseVersion(v) {
  const match = String(v).match(/^(\d+)\.(\d+)\.(\d+)/);
  if (!match) return null;
  return {
    major: parseInt(match[1], 10),
    minor: parseInt(match[2], 10),
    patch: parseInt(match[3], 10)
  };
}
