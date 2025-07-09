#!/usr/bin/env node

/**
 * Test Runner Script for YouTube Clone
 * Provides different testing modes and utilities
 */

import { spawn } from 'child_process'
import { fileURLToPath } from 'url'
import { dirname, join } from 'path'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
}

function log(message, color = colors.reset) {
  console.log(`${color}${message}${colors.reset}`)
}

function runCommand(command, args = [], options = {}) {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      stdio: 'inherit',
      shell: true,
      ...options
    })

    child.on('close', (code) => {
      if (code === 0) {
        resolve(code)
      } else {
        reject(new Error(`Command failed with exit code ${code}`))
      }
    })

    child.on('error', (error) => {
      reject(error)
    })
  })
}

async function runTests(mode = 'watch') {
  log(`\n${colors.cyan}🧪 Running YouTube Clone Tests${colors.reset}`)
  log(`${colors.yellow}Mode: ${mode}${colors.reset}\n`)

  try {
    switch (mode) {
      case 'watch':
        await runCommand('npm', ['test'])
        break
      case 'run':
        await runCommand('npm', ['run', 'test:run'])
        break
      case 'coverage':
        await runCommand('npm', ['run', 'test:coverage'])
        break
      case 'ui':
        log(`${colors.green}Opening Vitest UI...${colors.reset}`)
        await runCommand('npm', ['run', 'test:ui'])
        break
      default:
        throw new Error(`Unknown mode: ${mode}`)
    }
    
    log(`\n${colors.green}✅ Tests completed successfully!${colors.reset}`)
  } catch (error) {
    log(`\n${colors.red}❌ Tests failed: ${error.message}${colors.reset}`)
    process.exit(1)
  }
}

function showHelp() {
  log(`${colors.bright}YouTube Clone Test Runner${colors.reset}`)
  log(`${colors.cyan}Usage: node test-runner.js [mode]${colors.reset}\n`)
  log(`${colors.yellow}Available modes:${colors.reset}`)
  log(`  watch     - Run tests in watch mode (default)`)
  log(`  run       - Run tests once and exit`)
  log(`  coverage  - Run tests with coverage report`)
  log(`  ui        - Open Vitest UI`)
  log(`  help      - Show this help message`)
  log(`\n${colors.green}Examples:${colors.reset}`)
  log(`  node test-runner.js`)
  log(`  node test-runner.js run`)
  log(`  node test-runner.js coverage`)
  log(`  node test-runner.js ui`)
}

// Main execution
const mode = process.argv[2] || 'watch'

if (mode === 'help' || mode === '--help' || mode === '-h') {
  showHelp()
} else {
  runTests(mode)
}
