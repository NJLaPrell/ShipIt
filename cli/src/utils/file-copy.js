/**
 * File copying utilities
 */

import fsExtra from 'fs-extra';
import { join, dirname, relative } from 'path';
import { createHash } from 'crypto';
import { readFileSync } from 'fs';

const { copySync, mkdirSync, existsSync, statSync } = fsExtra;

/**
 * Copy framework files to target directory
 * @param {string} frameworkRoot - Framework root directory
 * @param {string} targetDir - Target directory
 * @param {string} stack - Tech stack (typescript-nodejs | python | other)
 * @param {object} manifest - Framework files manifest
 * @param {object} options - Options (verbose, dryRun)
 * @returns {object} Summary of copied files
 */
export function copyFrameworkFiles(frameworkRoot, targetDir, stack, manifest, options = {}) {
  const { verbose = false, dryRun = false } = options;
  const copied = [];
  const skipped = [];
  const errors = [];

  // Get stack-specific files
  const stackSpecific = manifest.stackSpecific[stack] || { files: [], directories: [] };
  const stackFiles = new Set(stackSpecific.files || []);
  const stackDirs = new Set(stackSpecific.directories || []);

  // Get never-copied files/directories
  const neverCopied = new Set([
    ...(manifest.neverCopied?.files || []),
    ...(manifest.neverCopied?.directories || []),
    '.override' // Always skip override directory
  ]);

  // Copy framework-owned directories
  for (const dir of manifest.frameworkOwned.directories || []) {
    const sourcePath = join(frameworkRoot, dir);
    const targetPath = join(targetDir, dir);

    // Skip if never copied
    if (neverCopied.has(dir) || dir.startsWith('.override')) {
      skipped.push(dir);
      continue;
    }

    // Skip stack-specific directories for other stacks
    if (stackDirs.has(dir) && stack !== 'typescript-nodejs' && stack !== 'python') {
      skipped.push(dir);
      continue;
    }

    if (!existsSync(sourcePath)) {
      errors.push(`Source directory not found: ${dir}`);
      continue;
    }

    if (!dryRun) {
      try {
        mkdirSync(targetPath, { recursive: true });
        copySync(sourcePath, targetPath, { overwrite: true });
        copied.push(dir);
        if (verbose) {
          console.log(`  Copied directory: ${dir}`);
        }
      } catch (error) {
        errors.push(`Failed to copy ${dir}: ${error.message}`);
      }
    } else {
      copied.push(dir);
    }
  }

  // Copy framework-owned files
  for (const file of manifest.frameworkOwned.files || []) {
    const sourcePath = join(frameworkRoot, file);
    const targetPath = join(targetDir, file);

    // Skip if never copied
    if (neverCopied.has(file)) {
      skipped.push(file);
      continue;
    }

    // Skip stack-specific files for other stacks
    if (stackFiles.has(file) && stack !== 'typescript-nodejs' && stack !== 'python') {
      skipped.push(file);
      continue;
    }

    if (!existsSync(sourcePath)) {
      errors.push(`Source file not found: ${file}`);
      continue;
    }

    if (!dryRun) {
      try {
        mkdirSync(dirname(targetPath), { recursive: true });
        copySync(sourcePath, targetPath, { overwrite: true });
        copied.push(file);
        if (verbose) {
          console.log(`  Copied file: ${file}`);
        }
      } catch (error) {
        errors.push(`Failed to copy ${file}: ${error.message}`);
      }
    } else {
      copied.push(file);
    }
  }

  return { copied, skipped, errors };
}

/**
 * Calculate file hash (SHA-256)
 * @param {string} filePath - Path to file
 * @returns {string} Hex hash
 */
export function calculateFileHash(filePath) {
  if (!existsSync(filePath)) {
    return null;
  }

  const content = readFileSync(filePath);
  return createHash('sha256').update(content).digest('hex');
}
