/**
 * Manifest utilities - Read and parse framework-files-manifest.json
 */

import { readFileSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

/**
 * Get CLI package root directory
 * @returns {string} Path to CLI package root
 */
function getCliPackageRoot() {
  // When installed: node_modules/shipit/
  // When local dev: framework root (where bin/ and cli/ are)
  
  // Try to find node_modules/shipit from current working directory
  let currentPath = process.cwd();
  for (let i = 0; i < 10; i++) { // Limit depth
    const nodeModulesPath = join(currentPath, 'node_modules', 'shipit');
    if (existsSync(nodeModulesPath)) {
      return nodeModulesPath;
    }
    const parent = dirname(currentPath);
    if (parent === currentPath) break; // Reached root
    currentPath = parent;
  }

  // Try relative to CLI source (local dev)
  // cli/src/utils/manifest.js -> framework root
  const localDevPath = join(__dirname, '..', '..', '..');
  if (existsSync(join(localDevPath, '_system', 'artifacts', 'framework-files-manifest.json'))) {
    return localDevPath;
  }

  // Try relative to bin/ (when installed globally)
  // bin/shipit -> framework root
  const binPath = join(__dirname, '..', '..');
  if (existsSync(join(binPath, '_system', 'artifacts', 'framework-files-manifest.json'))) {
    return binPath;
  }

  return null;
}

/**
 * Locate framework-files-manifest.json
 * @returns {string} Path to manifest file
 */
export function locateManifest() {
  const packageRoot = getCliPackageRoot();
  if (!packageRoot) {
    throw new Error('ShipIt framework files not found. Reinstall: npm install -g @njlaprell/shipit');
  }

  const manifestPath = join(packageRoot, '_system', 'artifacts', 'framework-files-manifest.json');
  if (existsSync(manifestPath)) {
    return manifestPath;
  }

  throw new Error('ShipIt framework files not found. Reinstall: npm install -g @njlaprell/shipit');
}

/**
 * Read and parse framework-files-manifest.json
 * @returns {object} Parsed manifest
 */
export function readManifest() {
  const manifestPath = locateManifest();
  
  try {
    const content = readFileSync(manifestPath, 'utf-8');
    const manifest = JSON.parse(content);
    
    // Validate structure
    if (!manifest.frameworkOwned || !manifest.userOwned || !manifest.stackSpecific || !manifest.neverCopied) {
      throw new Error('Invalid manifest structure: missing required sections');
    }
    
    return manifest;
  } catch (error) {
    if (error.code === 'ENOENT') {
      throw new Error('ShipIt framework files not found. Reinstall: npm install -g @njlaprell/shipit');
    }
    if (error instanceof SyntaxError) {
      throw new Error(`Invalid manifest JSON: ${error.message}`);
    }
    throw error;
  }
}

/**
 * Get framework root directory (where manifest is located)
 * @returns {string} Framework root directory
 */
export function getFrameworkRoot() {
  const packageRoot = getCliPackageRoot();
  if (!packageRoot) {
    throw new Error('ShipIt framework files not found. Reinstall: npm install -g @njlaprell/shipit');
  }
  return packageRoot;
}
