/**
 * Stack detection utilities
 */

import { existsSync, readFileSync } from 'fs';
import { join } from 'path';

/**
 * Detect tech stack from existing files
 * @param {string} projectPath - Path to project directory
 * @returns {string|null} Detected stack or null if ambiguous/unknown
 */
export function detectTechStack(projectPath) {
  const packageJsonPath = join(projectPath, 'package.json');
  const pyprojectTomlPath = join(projectPath, 'pyproject.toml');
  const requirementsTxtPath = join(projectPath, 'requirements.txt');
  const setupPyPath = join(projectPath, 'setup.py');

  const hasPackageJson = existsSync(packageJsonPath);
  const hasPyprojectToml = existsSync(pyprojectTomlPath);
  const hasRequirementsTxt = existsSync(requirementsTxtPath);
  const hasSetupPy = existsSync(setupPyPath);

  // Check for ambiguous case (both Node and Python indicators)
  if (hasPackageJson && (hasPyprojectToml || hasRequirementsTxt || hasSetupPy)) {
    return null; // Ambiguous, prompt user
  }

  // Validate package.json if it exists
  if (hasPackageJson) {
    try {
      const content = readFileSync(packageJsonPath, 'utf-8');
      JSON.parse(content); // Validate JSON
      return 'typescript-nodejs';
    } catch (e) {
      return null; // Invalid JSON, prompt user
    }
  }

  // Check for Python indicators
  if (hasPyprojectToml || hasRequirementsTxt || hasSetupPy) {
    return 'python';
  }

  // Empty directory or no indicators
  return null; // Prompt user
}

/**
 * Validate stack value
 * @param {string} stack - Stack value to validate
 * @returns {boolean} True if valid
 */
export function isValidStack(stack) {
  return ['typescript-nodejs', 'python', 'other'].includes(stack);
}
