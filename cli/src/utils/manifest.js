/**
 * Manifest utilities - Read and parse framework-files-manifest.json
 */

import { readFileSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

/**
 * Locate framework-files-manifest.json
 * @returns {string} Path to manifest file
 */
export function locateManifest() {
  // Try installed package location first
  const installedPath = join(process.cwd(), 'node_modules', 'shipit', '_system', 'artifacts', 'framework-files-manifest.json');
  if (existsSync(installedPath)) {
    return installedPath;
  }

  // Try local dev (framework repo)
  const localPath = join(__dirname, '..', '..', '..', '_system', 'artifacts', 'framework-files-manifest.json');
  if (existsSync(localPath)) {
    return localPath;
  }

  // Try relative to bin/ (when installed)
  const binRelativePath = join(__dirname, '..', '..', '_system', 'artifacts', 'framework-files-manifest.json');
  if (existsSync(binRelativePath)) {
    return binRelativePath;
  }

  throw new Error('ShipIt framework files not found. Reinstall: npm install -g shipit');
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
      throw new Error('ShipIt framework files not found. Reinstall: npm install -g shipit');
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
  const manifestPath = locateManifest();
  return dirname(dirname(manifestPath)); // Go up from _system/artifacts/ to framework root
}
