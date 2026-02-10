/**
 * Package.json merge utilities
 */

import { readFileSync, writeFileSync, existsSync } from 'fs';
import { join } from 'path';

/**
 * Merge ShipIt scripts into existing package.json
 * @param {string} existingPath - Path to existing package.json
 * @param {object} shipitScripts - ShipIt scripts to merge
 * @param {object} shipitDevDeps - ShipIt devDependencies to merge
 * @param {object} options - Options (dryRun, verbose)
 * @returns {object} Merge result
 */
export function mergePackageJson(existingPath, shipitScripts, shipitDevDeps, options = {}) {
  const { dryRun = false, verbose = false } = options;

  if (!existsSync(existingPath)) {
    throw new Error(`package.json not found: ${existingPath}`);
  }

  // Read existing package.json
  let existing;
  try {
    const content = readFileSync(existingPath, 'utf-8');
    existing = JSON.parse(content);
  } catch (error) {
    if (error instanceof SyntaxError) {
      throw new Error(`Invalid JSON in ${existingPath}: ${error.message}`);
    }
    throw error;
  }

  // Preserve user fields
  const merged = {
    ...existing,
    // Preserve these fields from existing
    name: existing.name,
    version: existing.version,
    description: existing.description,
    author: existing.author,
    license: existing.license,
    repository: existing.repository,
    homepage: existing.homepage,
    bugs: existing.bugs,
    dependencies: existing.dependencies || {},
    peerDependencies: existing.peerDependencies || {},
    optionalDependencies: existing.optionalDependencies || {},
  };

  // Merge scripts
  const existingScripts = existing.scripts || {};
  const mergedScripts = { ...existingScripts };

  for (const [scriptName, scriptCommand] of Object.entries(shipitScripts)) {
    if (existingScripts[scriptName]) {
      // Collision detected - prefix ShipIt script
      const prefixedName = `shipit:${scriptName}`;
      if (!existingScripts[prefixedName] && !existingScripts[`shipit:${scriptName}`]) {
        mergedScripts[prefixedName] = scriptCommand;
        if (verbose) {
          console.log(`  Script collision: ${scriptName} → ${prefixedName}`);
        }
      } else {
        // Already prefixed or user has shipit: prefix, skip
        if (verbose) {
          console.log(`  Skipping ${scriptName} (already customized)`);
        }
      }
    } else {
      // No collision, add directly
      mergedScripts[scriptName] = scriptCommand;
    }
  }

  merged.scripts = mergedScripts;

  // Merge devDependencies
  const existingDevDeps = existing.devDependencies || {};
  const mergedDevDeps = { ...existingDevDeps };

  for (const [depName, depVersion] of Object.entries(shipitDevDeps)) {
    if (!existingDevDeps[depName]) {
      // Add if missing
      mergedDevDeps[depName] = depVersion;
    } else {
      // Keep existing version (user may have customized)
      if (verbose) {
        console.log(`  Keeping existing devDependency: ${depName}@${existingDevDeps[depName]}`);
      }
    }
  }

  merged.devDependencies = mergedDevDeps;

  // Write merged package.json
  if (!dryRun) {
    const formatted = JSON.stringify(merged, null, 2);
    writeFileSync(existingPath, formatted + '\n', 'utf-8');
  }

  return {
    merged,
    collisions: Object.keys(shipitScripts).filter(name => existingScripts[name]),
    addedScripts: Object.keys(shipitScripts).filter(name => !existingScripts[name]),
    addedDevDeps: Object.keys(shipitDevDeps).filter(name => !existingDevDeps[name])
  };
}

/**
 * Get ShipIt scripts template
 * @returns {object} ShipIt scripts object
 */
export function getShipitScripts() {
  // These are the scripts that ShipIt adds to package.json
  // Based on scripts/init-project.sh package.json template
  return {
    'new-intent': './scripts/new-intent.sh',
    'scope-project': './scripts/scope-project.sh',
    'generate-roadmap': './scripts/generate-roadmap.sh',
    'generate-release-plan': './scripts/generate-release-plan.sh',
    'drift-check': './scripts/drift-check.sh',
    'deploy': './scripts/deploy.sh',
    'check-readiness': './scripts/check-readiness.sh',
    'workflow-orchestrator': './scripts/workflow-orchestrator.sh',
    'kill-intent': './scripts/kill-intent.sh',
    'verify': './scripts/verify.sh',
    'fix': './scripts/fix-intents.sh',
    'gh-create-issue': './scripts/gh/create-issue-from-intent.sh',
    'gh-link-issue': './scripts/gh/link-issue.sh',
    'gh-create-pr': './scripts/gh/create-pr.sh',
    'on-ship-update-issue': './scripts/gh/on-ship-update-issue.sh',
    'create-intent-from-issue': './scripts/gh/create-intent-from-issue.sh',
    'help': './scripts/help.sh',
    'status': './scripts/status.sh',
    'suggest': './scripts/suggest.sh',
    'dashboard': './scripts/dashboard-start.sh',
    'execute-rollback': './scripts/execute-rollback.sh',
    'export-dashboard-json': 'node scripts/export-dashboard-json.js'
  };
}

/**
 * Get ShipIt devDependencies template
 * @returns {object} ShipIt devDependencies object
 */
export function getShipitDevDependencies() {
  // Based on scripts/init-project.sh package.json template
  return {
    '@types/node': '^20.10.0',
    '@typescript-eslint/eslint-plugin': '^6.15.0',
    '@typescript-eslint/parser': '^6.15.0',
    '@stryker-mutator/core': '^8.0.0',
    '@stryker-mutator/vitest-runner': '^8.0.0',
    '@vitest/coverage-v8': '^1.0.4',
    'eslint': '^8.56.0',
    'prettier': '^3.1.1',
    'tsx': '^4.7.0',
    'typescript': '^5.3.3',
    'vitest': '^1.0.4'
  };
}
