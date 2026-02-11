/**
 * shipit init command - Attach ShipIt to existing project
 */

import { existsSync, readFileSync, writeFileSync } from 'fs';
import fsExtra from 'fs-extra';

const { mkdirSync } = fsExtra;
import { join, resolve } from 'path';
import { readManifest, getFrameworkRoot } from '../utils/manifest.js';
import { detectTechStack, isValidStack } from '../utils/stack-detection.js';
import { copyFrameworkFiles } from '../utils/file-copy.js';
import { mergePackageJson, getShipitScripts, getShipitDevDependencies } from '../utils/package-json-merge.js';
import { createReadlineInterface, promptUser } from '../utils/prompts.js';
import { readConfig } from '../utils/config.js';
import { createCIWorkflow } from '../utils/stack-files.js';

/**
 * Check if ShipIt is already initialized
 * @param {string} projectPath - Project directory path
 * @returns {boolean} True if ShipIt is initialized
 */
function isShipItInitialized(projectPath) {
  const projectJsonPath = join(projectPath, 'project.json');
  // project.json is the source of truth - if it exists, project is initialized
  // CANON.md alone doesn't mean fully initialized (could be from partial init)
  return existsSync(projectJsonPath);
}

/**
 * Read description from existing project files
 * @param {string} projectPath - Project directory path
 * @param {string} stack - Tech stack
 * @returns {string|null} Description or null
 */
function readDescription(projectPath, stack) {
  if (stack === 'typescript-nodejs') {
    const packageJsonPath = join(projectPath, 'package.json');
    if (existsSync(packageJsonPath)) {
      try {
        const pkg = JSON.parse(readFileSync(packageJsonPath, 'utf-8'));
        return pkg.description || null;
      } catch (e) {
        // Ignore errors
      }
    }
  } else if (stack === 'python') {
    const pyprojectPath = join(projectPath, 'pyproject.toml');
    if (existsSync(pyprojectPath)) {
      // Simple extraction (could use toml parser)
      const content = readFileSync(pyprojectPath, 'utf-8');
      const match = content.match(/description\s*=\s*["']([^"']+)["']/);
      if (match) {
        return match[1];
      }
    }
  }
  return null;
}

/**
 * Create project.json
 * @param {string} projectPath - Project directory path
 * @param {object} metadata - Project metadata
 */
function createProjectJson(projectPath, metadata) {
  const projectJsonPath = join(projectPath, 'project.json');
  
  const projectJson = {
    name: metadata.name,
    description: metadata.description,
    version: metadata.version || '0.1.0',
    techStack: metadata.techStack,
    created: new Date().toISOString(),
    highRiskDomains: metadata.highRiskDomains || [],
    settings: {
      humanResponseTime: 'minutes',
      confidenceThreshold: 0.7,
      testCoverageMinimum: 80
    },
    shipitVersion: metadata.shipitVersion || '1.0.0'
  };

  writeFileSync(projectJsonPath, JSON.stringify(projectJson, null, 2) + '\n', 'utf-8');
}

/**
 * Create .override directory structure
 * @param {string} projectPath - Project directory path
 */
function createOverrideDirectory(projectPath) {
  const overrideDirs = [
    '.override/rules',
    '.override/commands',
    '.override/scripts',
    '.override/config'
  ];

  for (const dir of overrideDirs) {
    const dirPath = join(projectPath, dir);
    if (!existsSync(dirPath)) {
      mkdirSync(dirPath, { recursive: true });
    }
  }
}

/**
 * Init command implementation
 * @param {object} options - Command options
 */
export async function initCommand(options) {
  const projectPath = resolve(options.path || process.cwd());
  const nonInteractive = options.nonInteractive || process.env.SHIPIT_NON_INTERACTIVE === '1';
  const force = options.force || false;

  // Check if ShipIt already initialized
  if (isShipItInitialized(projectPath) && !force) {
    if (nonInteractive) {
      throw new Error('ShipIt already initialized. Use --force to re-initialize or shipit upgrade to update.');
    }
    const rl = createReadlineInterface();
    const answer = await promptUser(rl, 'ShipIt already initialized. Use "shipit upgrade" instead? (y/N): ');
    rl.close();
    if (answer.toLowerCase() !== 'y') {
      console.log('Aborted.');
      process.exit(0);
    }
    // User wants to upgrade instead - this should call upgrade command
    // For now, just exit with message
    console.log('Run "shipit upgrade" to update framework files.');
    process.exit(0);
  }

  // Read config
  const config = readConfig(projectPath);

  // Detect or get tech stack
  let techStack = options.techStack || config.techStack;
  if (!techStack) {
    techStack = detectTechStack(projectPath);
  }

  if (!techStack) {
    if (nonInteractive) {
      techStack = 'other'; // Default for non-interactive
    } else {
      const rl = createReadlineInterface();
      console.log('Tech stack selection:');
      console.log('1) TypeScript/Node.js (recommended)');
      console.log('2) Python');
      console.log('3) Other (manual setup)');
      const choice = await promptUser(rl, 'Select tech stack [1=TS/Node, 2=Python, 3=Other]: ');
      rl.close();
      
      switch (choice.trim()) {
        case '1': techStack = 'typescript-nodejs'; break;
        case '2': techStack = 'python'; break;
        case '3': techStack = 'other'; break;
        default: techStack = 'typescript-nodejs';
      }
    }
  }

  if (!isValidStack(techStack)) {
    throw new Error(`Invalid tech stack: ${techStack}. Must be typescript-nodejs, python, or other.`);
  }

  // Get description
  let description = options.description || config.description;
  if (!description) {
    description = readDescription(projectPath, techStack);
  }
  if (!description && !nonInteractive) {
    const rl = createReadlineInterface();
    description = await promptUser(rl, 'Project description (short): ');
    rl.close();
  }
  description = description || 'ShipIt project';

  // Get high-risk domains
  let highRisk = options.highRisk || config.highRisk;
  if (!highRisk && !nonInteractive) {
    const rl = createReadlineInterface();
    console.log('High-Risk Domains (comma-separated, or "none"):');
    console.log('Examples: auth, payments, permissions, infrastructure, pii');
    highRisk = await promptUser(rl, 'High-risk domains: ');
    rl.close();
  }
  highRisk = highRisk || 'none';
  const highRiskArray = highRisk === 'none' ? [] : highRisk.split(',').map(s => s.trim());

  // Read manifest
  const manifest = readManifest();
  const frameworkRoot = getFrameworkRoot();

  console.log('Initializing ShipIt...');
  console.log(`  Tech stack: ${techStack}`);
  console.log(`  Description: ${description}`);

  // Copy framework files
  const copyResult = copyFrameworkFiles(frameworkRoot, projectPath, techStack, manifest, {
    verbose: !nonInteractive,
    dryRun: false
  });

  if (copyResult.errors.length > 0) {
    console.error('Errors during file copy:');
    copyResult.errors.forEach(err => console.error(`  ${err}`));
    throw new Error('Failed to copy some framework files');
  }

  // Merge package.json if exists
  const packageJsonPath = join(projectPath, 'package.json');
  if (existsSync(packageJsonPath) && techStack === 'typescript-nodejs') {
    console.log('Merging package.json...');
    const shipitScripts = getShipitScripts();
    const shipitDevDeps = getShipitDevDependencies();
    mergePackageJson(packageJsonPath, shipitScripts, shipitDevDeps, {
      verbose: !nonInteractive
    });
  }

  // Create project.json (or update if it exists but is incomplete)
  // This handles the case where init was interrupted previously
  const projectJsonPath = join(projectPath, 'project.json');
  const projectName = readProjectName(projectPath, techStack);
  
  // If project.json exists, merge/update it; otherwise create new
  if (existsSync(projectJsonPath)) {
    try {
      const existing = JSON.parse(readFileSync(projectJsonPath, 'utf-8'));
      // Update with current values, preserving any user customizations
      const updated = {
        ...existing,
        name: projectName,
        description: description || existing.description,
        techStack: techStack || existing.techStack,
        highRiskDomains: highRiskArray.length > 0 ? highRiskArray : existing.highRiskDomains,
        shipitVersion: '1.0.0' // TODO: Get from package.json
      };
      writeFileSync(projectJsonPath, JSON.stringify(updated, null, 2) + '\n', 'utf-8');
      console.log('  Updated project.json');
    } catch (e) {
      // If project.json is invalid, recreate it
      console.log('  Recreating project.json (existing file was invalid)');
      createProjectJson(projectPath, {
        name: projectName,
        description,
        techStack,
        highRiskDomains: highRiskArray,
        shipitVersion: '1.0.0' // TODO: Get from package.json
      });
    }
  } else {
    createProjectJson(projectPath, {
      name: projectName,
      description,
      techStack,
      highRiskDomains: highRiskArray,
      shipitVersion: '1.0.0' // TODO: Get from package.json
    });
  }

  // Create .override directory
  createOverrideDirectory(projectPath);

  // Create stack-specific CI workflow (only if .github/workflows doesn't exist or ci.yml doesn't exist)
  const workflowsDir = join(projectPath, '.github', 'workflows');
  const ciPath = join(workflowsDir, 'ci.yml');
  if (!existsSync(ciPath)) {
    createCIWorkflow(projectPath, techStack);
  }

  console.log('\n✓ ShipIt initialized successfully!');
  console.log('\nNext steps:');
  console.log('1. Run /scope-project to break down into features');
  console.log('2. Review project.json and customize as needed');
  console.log('3. Start creating intents with /new_intent');
}

/**
 * Read project name from existing files
 */
function readProjectName(projectPath, stack) {
  if (stack === 'typescript-nodejs') {
    const packageJsonPath = join(projectPath, 'package.json');
    if (existsSync(packageJsonPath)) {
      try {
        const pkg = JSON.parse(readFileSync(packageJsonPath, 'utf-8'));
        return pkg.name || 'my-project';
      } catch (e) {
        // Ignore
      }
    }
  }
  // Default or extract from directory name
  const dirName = projectPath.split('/').pop() || 'my-project';
  return dirName;
}
