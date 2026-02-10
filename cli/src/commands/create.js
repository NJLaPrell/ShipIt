/**
 * shipit create command - Create new ShipIt project
 */

import { existsSync, writeFileSync } from 'fs';
import fsExtra from 'fs-extra';

const { mkdirSync } = fsExtra;
import { join, resolve } from 'path';
import { readManifest, getFrameworkRoot } from '../utils/manifest.js';
import { isValidStack } from '../utils/stack-detection.js';
import { copyFrameworkFiles } from '../utils/file-copy.js';
import { createReadlineInterface, promptUser } from '../utils/prompts.js';
import { execSync } from 'child_process';

/**
 * Create command implementation
 * @param {string} projectName - Project name
 * @param {object} options - Command options
 */
export async function createCommand(projectName, options) {
  const nonInteractive = options.nonInteractive || process.env.SHIPIT_NON_INTERACTIVE === '1';
  const skipGit = options.skipGit || false;
  const skipInstall = options.skipInstall || false;

  // Validate project name
  if (!/^[a-zA-Z0-9_-]+$/.test(projectName)) {
    throw new Error('Project name must be alphanumeric with hyphens/underscores only');
  }

  const projectPath = resolve(projectName);

  // Check if directory exists
  if (existsSync(projectPath)) {
    if (!options.force && !nonInteractive) {
      const rl = createReadlineInterface();
      const answer = await promptUser(rl, `Directory ${projectName} already exists. Continue? (y/N): `);
      rl.close();
      if (answer.toLowerCase() !== 'y') {
        console.log('Aborted.');
        process.exit(0);
      }
    }
  } else {
    mkdirSync(projectPath, { recursive: true });
  }

  // Get tech stack
  let techStack = options.techStack;
  if (!techStack && !nonInteractive) {
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
  techStack = techStack || 'typescript-nodejs';

  if (!isValidStack(techStack)) {
    throw new Error(`Invalid tech stack: ${techStack}. Must be typescript-nodejs, python, or other.`);
  }

  // Get description
  let description = options.description;
  if (!description && !nonInteractive) {
    const rl = createReadlineInterface();
    description = await promptUser(rl, 'Project description (short): ');
    rl.close();
  }
  description = description || projectName;

  // Get high-risk domains
  let highRisk = options.highRisk;
  if (!highRisk && !nonInteractive) {
    const rl = createReadlineInterface();
    console.log('High-Risk Domains (comma-separated, or "none"):');
    console.log('Examples: auth, payments, permissions, infrastructure, pii');
    highRisk = await promptUser(rl, 'High-risk domains: ');
    rl.close();
  }
  highRisk = highRisk || 'none';
  const highRiskArray = highRisk === 'none' ? [] : highRisk.split(',').map(s => s.trim());

  console.log(`Creating ShipIt project: ${projectName}`);
  console.log(`  Tech stack: ${techStack}`);
  console.log(`  Description: ${description}`);

  // Read manifest
  const manifest = readManifest();
  const frameworkRoot = getFrameworkRoot();

  // Copy framework files
  console.log('Copying framework files...');
  const copyResult = copyFrameworkFiles(frameworkRoot, projectPath, techStack, manifest, {
    verbose: !nonInteractive
  });

  if (copyResult.errors.length > 0) {
    console.error('Errors during file copy:');
    copyResult.errors.forEach(err => console.error(`  ${err}`));
    throw new Error('Failed to copy some framework files');
  }

  // Create stack-specific files (package.json, tsconfig.json, etc.)
  if (techStack === 'typescript-nodejs') {
    createNodeProjectFiles(projectPath, projectName, description, highRiskArray);
  } else if (techStack === 'python') {
    createPythonProjectFiles(projectPath, projectName, description, highRiskArray);
  } else {
    createOtherProjectFiles(projectPath, projectName, description, highRiskArray);
  }

  // Initialize git
  if (!skipGit) {
    const gitPath = join(projectPath, '.git');
    if (!existsSync(gitPath)) {
      console.log('Initializing git repository...');
      try {
        execSync('git init', { cwd: projectPath, stdio: 'inherit' });
        execSync('git add .', { cwd: projectPath, stdio: 'inherit' });
        execSync('git commit -m "Initial commit: ' + projectName + '"', { cwd: projectPath, stdio: 'inherit' });
      } catch (error) {
        console.warn('Warning: Git initialization failed (git may not be installed)');
      }
    }
  }

  // Run package manager install
  if (!skipInstall && techStack === 'typescript-nodejs') {
    console.log('Installing dependencies...');
    try {
      execSync('pnpm install', { cwd: projectPath, stdio: 'inherit' });
    } catch (error) {
      console.warn('Warning: Package installation failed');
    }
  }

  console.log('\n✓ Project created successfully!');
  console.log(`\nNext steps:`);
  console.log(`1. cd ${projectName}`);
  console.log('2. Run /scope-project to break down into features');
  console.log('3. Start creating intents with /new_intent');
}

/**
 * Create Node.js project files
 */
function createNodeProjectFiles(projectPath, projectName, description, highRiskArray) {
  // This will be handled by copying framework files which includes package.json template
  // Additional stack-specific files are created by init-project.sh logic
  // For now, we rely on the framework files being copied
}

/**
 * Create Python project files
 */
function createPythonProjectFiles(projectPath, projectName, description, highRiskArray) {
  // Create pyproject.toml if not exists
  const pyprojectPath = join(projectPath, 'pyproject.toml');
  if (!existsSync(pyprojectPath)) {
    const pyprojectContent = `[project]
name = "${projectName}"
description = "${description}"
version = "0.1.0"
requires-python = ">=3.10"

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "ruff>=0.1.0",
    "mypy>=1.0.0",
]
`;
    writeFileSync(pyprojectPath, pyprojectContent, 'utf-8');
  }
}

/**
 * Create Other stack project files
 */
function createOtherProjectFiles(projectPath, projectName, description, highRiskArray) {
  // Create minimal .gitignore
  const gitignorePath = join(projectPath, '.gitignore');
  if (!existsSync(gitignorePath)) {
    writeFileSync(gitignorePath, '*.log\n.DS_Store\n.env\n', 'utf-8');
  }

  // Create src directory
  const srcPath = join(projectPath, 'src');
  if (!existsSync(srcPath)) {
    mkdirSync(srcPath, { recursive: true });
  }
}
