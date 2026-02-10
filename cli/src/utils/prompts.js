/**
 * Prompt utilities for interactive mode
 */

import { createInterface } from 'readline';

/**
 * Create readline interface
 * @returns {object} Readline interface
 */
export function createReadlineInterface() {
  return createInterface({
    input: process.stdin,
    output: process.stdout
  });
}

/**
 * Prompt user for input
 * @param {object} rl - Readline interface
 * @param {string} question - Question to ask
 * @returns {Promise<string>} User input
 */
export function promptUser(rl, question) {
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      resolve(answer);
    });
  });
}
