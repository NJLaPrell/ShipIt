/**
 * Stack-specific file creation utilities
 */

import { writeFileSync, existsSync, mkdirSync } from 'fs';
import { join } from 'path';
import fsExtra from 'fs-extra';

const { copySync } = fsExtra;

/**
 * Create TypeScript/Node.js project files
 * @param {string} projectPath - Project directory path
 * @param {string} projectName - Project name
 * @param {string} description - Project description
 * @param {object} shipitScripts - ShipIt scripts to include
 * @param {object} shipitDevDeps - ShipIt devDependencies to include
 */
export function createTypeScriptNodeFiles(projectPath, projectName, description, shipitScripts, shipitDevDeps) {
  const normalizedName = projectName.toLowerCase().replace(/\s+/g, '-');

  // Create package.json
  const packageJson = {
    name: normalizedName,
    version: '0.1.0',
    description: description,
    type: 'module',
    scripts: {
      test: 'vitest run',
      'test:watch': 'vitest',
      'test:coverage': 'vitest run --coverage',
      'test:mutate': 'stryker run',
      lint: 'eslint . --ext .ts',
      typecheck: 'tsc --noEmit',
      build: 'tsc',
      dev: 'tsx watch src/index.ts',
      ...shipitScripts
    },
    keywords: [],
    author: '',
    license: 'MIT',
    devDependencies: {
      '@types/node': '^20.10.0',
      '@typescript-eslint/eslint-plugin': '^6.15.0',
      '@typescript-eslint/parser': '^6.15.0',
      '@stryker-mutator/core': '^8.0.0',
      '@stryker-mutator/vitest-runner': '^8.0.0',
      '@vitest/coverage-v8': '^1.0.4',
      eslint: '^8.56.0',
      prettier: '^3.1.1',
      tsx: '^4.7.0',
      typescript: '^5.3.3',
      vitest: '^1.0.4',
      ...shipitDevDeps
    },
    dependencies: {}
  };

  writeFileSync(
    join(projectPath, 'package.json'),
    JSON.stringify(packageJson, null, 2) + '\n',
    'utf-8'
  );

  // Create tsconfig.json
  const tsconfig = {
    compilerOptions: {
      target: 'ES2022',
      module: 'ESNext',
      lib: ['ES2022'],
      moduleResolution: 'node',
      strict: true,
      esModuleInterop: true,
      skipLibCheck: true,
      forceConsistentCasingInFileNames: true,
      resolveJsonModule: true,
      outDir: './dist',
      rootDir: './src',
      declaration: true,
      declarationMap: true,
      sourceMap: true,
      noUnusedLocals: true,
      noUnusedParameters: true,
      noImplicitReturns: true,
      noFallthroughCasesInSwitch: true
    },
    include: ['src/**/*'],
    exclude: ['node_modules', 'dist', '**/*.test.ts', '**/*.spec.ts']
  };

  writeFileSync(
    join(projectPath, 'tsconfig.json'),
    JSON.stringify(tsconfig, null, 2) + '\n',
    'utf-8'
  );

  // Create tsconfig.eslint.json
  const tsconfigEslint = {
    extends: './tsconfig.json',
    include: ['src/**/*.ts', 'tests/**/*.ts', 'scripts/**/*.ts', '*.config.ts'],
    exclude: ['node_modules', 'dist']
  };

  writeFileSync(
    join(projectPath, 'tsconfig.eslint.json'),
    JSON.stringify(tsconfigEslint, null, 2) + '\n',
    'utf-8'
  );

  // Create .eslintrc.json
  const eslintrc = {
    root: true,
    parser: '@typescript-eslint/parser',
    parserOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
      project: ['./tsconfig.eslint.json'],
      tsconfigRootDir: '.'
    },
    extends: [
      'eslint:recommended',
      'plugin:@typescript-eslint/recommended',
      'plugin:@typescript-eslint/strict-type-checked'
    ],
    plugins: ['@typescript-eslint'],
    rules: {
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/ban-types': 'error',
      'no-eval': 'error',
      'no-console': ['error', { allow: ['warn', 'error'] }]
    },
    overrides: [
      {
        files: ['scripts/**/*.ts', 'tests/**/*.ts', '**/*.config.ts'],
        rules: {
          'no-console': 'off',
          '@typescript-eslint/no-unsafe-assignment': 'off',
          '@typescript-eslint/no-unsafe-call': 'off',
          '@typescript-eslint/no-unsafe-member-access': 'off',
          '@typescript-eslint/no-unsafe-return': 'off',
          '@typescript-eslint/no-unsafe-argument': 'off'
        }
      }
    ],
    ignorePatterns: ['dist', 'node_modules', '*.config.js']
  };

  writeFileSync(
    join(projectPath, '.eslintrc.json'),
    JSON.stringify(eslintrc, null, 2) + '\n',
    'utf-8'
  );

  // Create vitest.config.ts
  const vitestConfig = `import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['tests/**/*.test.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html', 'lcov'],
      exclude: [
        'node_modules/',
        'dist/',
        'tests/',
        '**/*.test.ts',
        '**/*.spec.ts',
        '**/*.config.ts',
      ],
    },
  },
});
`;

  writeFileSync(join(projectPath, 'vitest.config.ts'), vitestConfig, 'utf-8');

  // Create .npmrc
  writeFileSync(join(projectPath, '.npmrc'), 'audit-level=high\n', 'utf-8');

  // Create src/index.ts
  const srcDir = join(projectPath, 'src');
  if (!existsSync(srcDir)) {
    mkdirSync(srcDir, { recursive: true });
  }
  const indexTs = `// ${projectName}
// ${description}

export const projectName = '${projectName}';
export const projectDescription = '${description}';
`;
  writeFileSync(join(srcDir, 'index.ts'), indexTs, 'utf-8');
}

/**
 * Create Python project files
 * @param {string} projectPath - Project directory path
 * @param {string} projectName - Project name
 * @param {string} description - Project description
 */
export function createPythonFiles(projectPath, projectName, description) {
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

  // Create requirements.txt if not exists
  const requirementsPath = join(projectPath, 'requirements.txt');
  if (!existsSync(requirementsPath)) {
    writeFileSync(requirementsPath, '# Project dependencies\n', 'utf-8');
  }
}

/**
 * Create Other stack project files
 * @param {string} projectPath - Project directory path
 */
export function createOtherStackFiles(projectPath) {
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
