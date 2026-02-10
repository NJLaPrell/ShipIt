/**
 * shipit upgrade command - Upgrade ShipIt framework files
 * shipit restore / shipit list-backups - Backup management
 */

import { existsSync, readFileSync } from 'fs';
import { join, resolve } from 'path';
import { readManifest, getFrameworkRoot } from '../utils/manifest.js';
import { getInstalledShipItVersion, getProjectShipItVersion, compareVersions } from '../utils/version.js';
import {
  isFileModified,
  backupFile,
  listBackups,
  restoreFromBackup,
  getFrameworkFileList
} from '../utils/upgrade-backup.js';
import { mergeProjectJson } from '../utils/project-json-merge.js';
import { mergeGitignore } from '../utils/gitignore-merge.js';
import { mergePackageJson, getShipitScripts, getShipitDevDependencies } from '../utils/package-json-merge.js';
import { createReadlineInterface, promptUser } from '../utils/prompts.js';
import fsExtra from 'fs-extra';

const { copySync, mkdirSync } = fsExtra;

const BACKUP_DIR = '._shipit_backup';

function isShipItInitialized(projectPath) {
  return (
    existsSync(join(projectPath, 'project.json')) ||
    existsSync(join(projectPath, '_system', 'architecture', 'CANON.md'))
  );
}

function getNeverCopiedSet(manifest) {
  return new Set([
    ...(manifest.neverCopied?.files || []),
    ...(manifest.neverCopied?.directories || []),
    '.override'
  ]);
}

/**
 * Upgrade command implementation
 */
export async function upgradeCommand(options) {
  const projectPath = resolve(options.path || process.cwd());
  const backupDir = options.backupDir || BACKUP_DIR;
  const dryRun = options.dryRun || false;
  const force = options.force || false;

  if (!existsSync(projectPath)) {
    const err = new Error(`Directory not found: ${projectPath}`);
    err.exitCode = 1;
    throw err;
  }

  if (!isShipItInitialized(projectPath)) {
    const err = new Error('ShipIt is not initialized in this project. Run "shipit init" first.');
    err.exitCode = 3;
    throw err;
  }

  const installedVersion = getInstalledShipItVersion();
  const projectVersion = getProjectShipItVersion(projectPath);
  const comparison = compareVersions(installedVersion, projectVersion || '0.0.0');

  if (comparison === 'same') {
    console.log(`Already up to date (ShipIt ${installedVersion}).`);
    return;
  }

  if (comparison === 'older') {
    console.warn(
      `Warning: Project has ShipIt ${projectVersion || 'unknown'}, installed is ${installedVersion}. Project may be ahead.`
    );
    if (!force && !dryRun) {
      const rl = createReadlineInterface();
      const answer = await promptUser(rl, 'Continue anyway? (y/N): ');
      rl.close();
      if (answer.toLowerCase() !== 'y') {
        console.log('Aborted.');
        process.exit(0);
      }
    }
  }

  const manifest = readManifest();
  const frameworkRoot = getFrameworkRoot();
  const neverCopied = getNeverCopiedSet(manifest);
  const frameworkFiles = getFrameworkFileList(frameworkRoot, manifest, neverCopied);

  const modified = [];
  for (const rel of frameworkFiles) {
    if (isFileModified(projectPath, frameworkRoot, rel)) {
      modified.push(rel);
    }
  }

  if (modified.length > 0 && !force && !dryRun) {
    console.log('The following framework files have been modified and will be backed up before replacement:');
    modified.slice(0, 20).forEach((f) => console.log(`  - ${f}`));
    if (modified.length > 20) console.log(`  ... and ${modified.length - 20} more`);
    const rl = createReadlineInterface();
    const answer = await promptUser(rl, 'Continue? (y/N): ');
    rl.close();
    if (answer.toLowerCase() !== 'y') {
      console.log('Aborted.');
      process.exit(0);
    }
  }

  if (dryRun) {
    console.log('\nDry run - would perform:');
    console.log(`  Backup ${modified.length} modified file(s)`);
    console.log(`  Replace ${frameworkFiles.length} framework file(s)`);
    console.log(`  Merge project.json (shipitVersion → ${installedVersion})`);
    console.log('  Merge package.json if present');
    console.log('  Merge .gitignore if present');
    return;
  }

  // Backup modified files
  for (const rel of modified) {
    backupFile(projectPath, rel, backupDir);
    if (options.verbose) console.log(`  Backed up: ${rel}`);
  }

  // Replace all framework files
  for (const rel of frameworkFiles) {
    const src = join(frameworkRoot, rel);
    const dest = join(projectPath, rel);
    if (!existsSync(src)) continue;
    mkdirSync(join(dest, '..'), { recursive: true });
    copySync(src, dest, { overwrite: true });
  }

  // Merge project.json
  mergeProjectJson(projectPath, installedVersion, { verbose: options.verbose });

  // Merge package.json if present (use project's tech stack from project.json)
  const projectJsonPath = join(projectPath, 'project.json');
  let techStack = 'typescript-nodejs';
  if (existsSync(projectJsonPath)) {
    try {
      const pj = JSON.parse(readFileSync(projectJsonPath, 'utf-8'));
      techStack = pj.techStack || techStack;
    } catch (_) {}
  }
  const packageJsonPath = join(projectPath, 'package.json');
  if (existsSync(packageJsonPath) && techStack === 'typescript-nodejs') {
    const shipitScripts = getShipitScripts();
    const shipitDevDeps = getShipitDevDependencies();
    mergePackageJson(packageJsonPath, shipitScripts, shipitDevDeps, { verbose: options.verbose });
  }

  // Merge .gitignore
  mergeGitignore(projectPath, { verbose: options.verbose });

  console.log(`\n✓ ShipIt upgraded to ${installedVersion}`);
  if (modified.length > 0) {
    console.log(`  ${modified.length} modified file(s) backed up to ${backupDir}/`);
  }
}

/**
 * List backups command
 */
export async function listBackupsCommand(options) {
  const projectPath = resolve(options.path || process.cwd());
  const backupDir = options.backupDir || BACKUP_DIR;
  const backups = listBackups(projectPath, backupDir);
  if (backups.length === 0) {
    console.log('No backups found.');
    return;
  }
  console.log(`Backups in ${backupDir}/:\n`);
  for (const b of backups) {
    console.log(`  ${b.relative}  (${b.timestamp}) → ${b.original}`);
  }
}

/**
 * Restore from backup
 */
export async function restoreCommand(backupPath, options) {
  const projectPath = resolve(options.path || process.cwd());
  const backupDir = options.backupDir || BACKUP_DIR;
  const fullBackupPath = backupPath.startsWith('/') ? backupPath : resolve(projectPath, backupPath);
  if (!existsSync(fullBackupPath)) {
    const err = new Error(`Backup not found: ${backupPath}`);
    err.exitCode = 1;
    throw err;
  }
  restoreFromBackup(fullBackupPath, null, projectPath, backupDir, options.removeBackup || false);
  console.log(`Restored: ${backupPath}`);
}
