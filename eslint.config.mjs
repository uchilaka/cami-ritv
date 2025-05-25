/* eslint-disable @typescript-eslint/no-unsafe-assignment */
import { globalIgnores } from 'eslint/config';
import { fixupConfigRules, fixupPluginRules } from '@eslint/compat';
import react from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';
import typescriptEslint from '@typescript-eslint/eslint-plugin';
import tseslint from 'typescript-eslint';
import prettier from 'eslint-plugin-prettier';
import globals from 'globals';
import tsParser from '@typescript-eslint/parser';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import js from '@eslint/js';
import { FlatCompat } from '@eslint/eslintrc';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
  allConfig: js.configs.all,
});

export default tseslint.config(
  globalIgnores([
    '**/tailwind.config.js',
    'postcss.config.mjs',
    'vite.config.ts',
    'vitest.config.ts',
    'eslint.config.mjs',
    'config/**/*',
    'lib/**/*',
    'node_modules/**/*',
    'public/**/*',
    'vendor/**/*',
  ]),
  tseslint.configs.recommendedTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
  },
  {
    extends: fixupConfigRules(
      compat.extends(
        'eslint:recommended',
        'plugin:react/recommended',
        'plugin:react-hooks/recommended',
        'plugin:prettier/recommended'
      )
    ),

    settings: {
      react: {
        version: 'detect',
      },
    },

    // plugins: {
    //   react: fixupPluginRules(react),
    //   'react-hooks': fixupPluginRules(reactHooks),
    //   '@typescript-eslint': typescriptEslint,
    //   prettier: fixupPluginRules(prettier),
    // },

    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.jest,
      },

      parser: tsParser,
      ecmaVersion: 13,
      sourceType: 'module',

      parserOptions: {
        ecmaFeatures: {
          jsx: true,
        },
      },
    },

    rules: {
      // semi: ['warn', 'never'],
      'react/react-in-jsx-scope': 1,
      'no-mixed-spaces-and-tabs': 0,
      camelcase: 'off',
      // 'comma-dangle': ['warn', 'always-multiline'],
      'react/prop-types': 'off',
      'react/forbid-prop-types': 0,
      'react/require-default-props': 0,
      'react/jsx-filename-extension': 0,
      'jsx-a11y/click-events-have-key-events': 0,

      'react/default-props-match-prop-types': [
        0,
        {
          allowRequiredDefaults: true,
        },
      ],

      'no-param-reassign': 0,
      'react/no-array-index-key': 0,
      'react/jsx-props-no-spreading': 0,
      'no-console': 0,
      'jsx-a11y/anchor-is-valid': 0,
      'no-shadow': 0,
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn',

      'no-use-before-define': [
        'error',
        {
          functions: false,
          classes: true,
          variables: false,
        },
      ],

      'no-unused-vars': 'off',

      '@typescript-eslint/no-unused-vars': [
        'warn',
        {
          args: 'all',
          argsIgnorePattern: '^_',
          caughtErrors: 'all',
          caughtErrorsIgnorePattern: '^_',
          destructuredArrayIgnorePattern: '^_',
          varsIgnorePattern: '^_',
          ignoreRestSiblings: true,
        },
      ],
    },
  }
);
