/**
 * Config file utilities (.shipitrc)
 */

import { existsSync, readFileSync } from 'fs';
import { join } from 'path';

/**
 * Read .shipitrc config file
 * @param {string} projectPath - Project directory path
 * @returns {object} Config object (empty if no config)
 */
export function readConfig(projectPath) {
  const configPath = join(projectPath, '.shipitrc');
  
  if (!existsSync(configPath)) {
    return {};
  }

  try {
    const content = readFileSync(configPath, 'utf-8');
    return JSON.parse(content);
  } catch (error) {
    console.warn(`Warning: Invalid .shipitrc file: ${error.message}`);
    return {};
  }
}
