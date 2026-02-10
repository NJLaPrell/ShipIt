/**
 * shipit check command - Validate ShipIt installation
 */

import { existsSync, readFileSync } from 'fs';
import { join, resolve } from 'path';
import { readManifest } from '../utils/manifest.js';

/**
 * Check command implementation
 * @param {object} options - Command options
 */
export async function checkCommand(options) {
  const projectPath = resolve(options.path || process.cwd());
  const jsonOutput = options.json || false;

  const manifest = readManifest();
  const status = {
    initialized: false,
    projectJsonExists: false,
    frameworkFiles: {
      present: [],
      missing: []
    },
    version: null,
    userCustomizations: []
  };

  // Check project.json
  const projectJsonPath = join(projectPath, 'project.json');
  if (existsSync(projectJsonPath)) {
    status.projectJsonExists = true;
    status.initialized = true;
    
    try {
      const projectJson = JSON.parse(readFileSync(projectJsonPath, 'utf-8'));
      status.version = projectJson.shipitVersion || null;
    } catch (e) {
      // Ignore parse errors
    }
  }

  // Check framework files
  for (const file of manifest.frameworkOwned.files || []) {
    const filePath = join(projectPath, file);
    if (existsSync(filePath)) {
      status.frameworkFiles.present.push(file);
    } else {
      status.frameworkFiles.missing.push(file);
    }
  }

  // Check .override directory
  const overridePath = join(projectPath, '.override');
  if (existsSync(overridePath)) {
    // List files in .override (user customizations)
    // Simplified - just check if directory exists
    status.userCustomizations.push('.override/');
  }

  // Output results
  if (jsonOutput) {
    console.log(JSON.stringify(status, null, 2));
  } else {
    console.log('ShipIt Installation Check');
    console.log('========================');
    console.log(`Initialized: ${status.initialized ? 'Yes' : 'No'}`);
    if (status.version) {
      console.log(`Version: ${status.version}`);
    }
    console.log(`Framework files present: ${status.frameworkFiles.present.length}`);
    console.log(`Framework files missing: ${status.frameworkFiles.missing.length}`);
    if (status.frameworkFiles.missing.length > 0) {
      console.log('\nMissing files:');
      status.frameworkFiles.missing.forEach(file => console.log(`  - ${file}`));
    }
    if (status.userCustomizations.length > 0) {
      console.log('\nUser customizations:');
      status.userCustomizations.forEach(custom => console.log(`  - ${custom}`));
    }
  }
}
