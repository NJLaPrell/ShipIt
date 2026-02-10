/**
 * project.json merge for upgrade - preserve user fields, update shipitVersion
 */

import { readFileSync, writeFileSync, existsSync } from 'fs';
import { join } from 'path';

/**
 * Merge project.json: preserve user fields, update shipitVersion and settings defaults
 * @param {string} projectPath - Project root
 * @param {string} newShipitVersion - Version to set
 * @param {object} options - { dryRun, verbose }
 * @returns {object} Merge result
 */
export function mergeProjectJson(projectPath, newShipitVersion, options = {}) {
  const { dryRun = false, verbose = false } = options;
  const projectJsonPath = join(projectPath, 'project.json');

  if (!existsSync(projectJsonPath)) {
    if (verbose) console.log('  project.json not found, skipping merge');
    return { merged: null, updated: false };
  }

  let existing;
  try {
    existing = JSON.parse(readFileSync(projectJsonPath, 'utf-8'));
  } catch (e) {
    throw new Error(`Invalid JSON in project.json: ${e.message}`);
  }

  const merged = {
    ...existing,
    name: existing.name,
    description: existing.description,
    version: existing.version,
    techStack: existing.techStack,
    created: existing.created,
    highRiskDomains: existing.highRiskDomains ?? [],
    shipitVersion: newShipitVersion,
    settings: {
      humanResponseTime: existing.settings?.humanResponseTime ?? 'minutes',
      confidenceThreshold: existing.settings?.confidenceThreshold ?? 0.7,
      testCoverageMinimum: existing.settings?.testCoverageMinimum ?? 80,
      ...(existing.settings || {})
    }
  };

  if (!dryRun) {
    writeFileSync(
      projectJsonPath,
      JSON.stringify(merged, null, 2) + '\n',
      'utf-8'
    );
  }

  return { merged, updated: true };
}
