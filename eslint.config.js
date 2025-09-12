import js from '@eslint/js'
import globals from 'globals'
import reactHooks from 'eslint-plugin-react-hooks'
import reactRefresh from 'eslint-plugin-react-refresh'

export default [
  // Global ignores
  {
    ignores: [
      'dist/**',
      'coverage/**',
      'node_modules/**',
      '*.config.js',
      'vite.config.js'
    ]
  },
  
  // Main source files configuration
  {
    files: ['**/*.{js,jsx}'],
    languageOptions: {
      ecmaVersion: 2020,
      globals: {
        ...globals.browser,
        ...globals.es2020,
      },
      parserOptions: {
        ecmaVersion: 'latest',
        ecmaFeatures: { jsx: true },
        sourceType: 'module',
      },
    },
    plugins: {
      'react-hooks': reactHooks,
      'react-refresh': reactRefresh,
    },
    rules: {
      ...js.configs.recommended.rules,
      ...reactHooks.configs.recommended.rules,
      
      // Custom rules
      'no-unused-vars': ['error', { 
        varsIgnorePattern: '^(_|[A-Z_])',
        argsIgnorePattern: '^(_|[A-Z_])',
        ignoreRestSiblings: true
      }],
      
      // React hooks rules - make them warnings instead of errors
      'react-hooks/exhaustive-deps': 'warn',
      'react-hooks/rules-of-hooks': 'error',
      
      // React refresh
      'react-refresh/only-export-components': [
        'warn',
        { allowConstantExport: true },
      ],
    },
  },
  
  // Test files configuration
  {
    files: [
      '**/*.test.{js,jsx}',
      '**/*.spec.{js,jsx}',
      '**/test/**/*.{js,jsx}',
      '**/tests/**/*.{js,jsx}',
      'src/test/**/*.{js,jsx}',
      'test-runner.js',
      '**/setup.js'
    ],
    languageOptions: {
      ecmaVersion: 2020,
      globals: {
        ...globals.browser,
        ...globals.es2020,
        ...globals.node,
        
        // Vitest globals
        vi: 'readonly',
        describe: 'readonly',
        it: 'readonly',
        test: 'readonly',
        expect: 'readonly',
        beforeEach: 'readonly',
        afterEach: 'readonly',
        beforeAll: 'readonly',
        afterAll: 'readonly',
        
        // Node.js globals for test environment
        global: 'readonly',
        process: 'readonly',
        Buffer: 'readonly',
        __dirname: 'readonly',
        __filename: 'readonly',
      },
      parserOptions: {
        ecmaVersion: 'latest',
        ecmaFeatures: { jsx: true },
        sourceType: 'module',
      },
    },
    rules: {
      // Relaxed rules for test files
      'no-unused-vars': ['warn', { 
        varsIgnorePattern: '^(_|[A-Z_]|afterEach|waitFor|date)',
        argsIgnorePattern: '^(_|[A-Z_])',
        ignoreRestSiblings: true
      }],
      'no-undef': 'error',
      'react-hooks/exhaustive-deps': 'off', // Disable for tests
    },
  },
  
  // Node.js configuration files
  {
    files: [
      '*.config.js',
      'vite.config.js',
      'vitest.config.js',
      'test-runner.js'
    ],
    languageOptions: {
      ecmaVersion: 2020,
      globals: {
        ...globals.node,
        process: 'readonly',
        Buffer: 'readonly',
        __dirname: 'readonly',
        __filename: 'readonly',
      },
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
      },
    },
    rules: {
      'no-unused-vars': ['warn', { 
        varsIgnorePattern: '^(_|[A-Z_]|join)',
        argsIgnorePattern: '^(_|[A-Z_])',
        ignoreRestSiblings: true
      }],
    },
  }
]
