// Performance Test Configuration
// Professional CI/CD environment-aware performance thresholds

/**
 * Performance test thresholds optimized for different environments
 * These values are based on industry best practices and CI/CD environment characteristics
 */

// Environment detection
const isCI = process.env.CI === 'true' || process.env.GITHUB_ACTIONS === 'true'
const isLocal = !isCI

// Base performance multipliers for different environments
const ENVIRONMENT_MULTIPLIERS = {
  local: 1.0,      // Local development (fastest)
  ci: 1.5,         // CI environment (GitHub Actions, slower due to shared resources)
  docker: 1.3,     // Docker containers (slightly slower)
  kubernetes: 1.4  // Kubernetes pods (container orchestration overhead)
}

// Get current environment multiplier
const getCurrentMultiplier = () => {
  if (process.env.KUBERNETES_SERVICE_HOST) return ENVIRONMENT_MULTIPLIERS.kubernetes
  if (process.env.DOCKER_CONTAINER) return ENVIRONMENT_MULTIPLIERS.docker
  if (isCI) return ENVIRONMENT_MULTIPLIERS.ci
  return ENVIRONMENT_MULTIPLIERS.local
}

// Base performance thresholds (optimized for reliable testing across environments)
const BASE_THRESHOLDS = {
  // Utility function performance
  utilityFunction: {
    largeNumbers: 8,        // 8ms for large number processing
    repeatedCalls: 25,      // 25ms for 10k repeated calls (increased for reliability)
    singleCall: 2           // 2ms for single call
  },
  
  // Component rendering performance
  componentRender: {
    largeDataset: 400,      // 400ms for large dataset rendering (increased for reliability)
    rapidReRender: 120,     // 120ms for rapid re-renders (increased for reliability)
    initialRender: 150      // 150ms for initial component render (increased for reliability)
  },
  
  // API call performance
  apiCalls: {
    singleCall: 1000,       // 1s for single API call
    batchCalls: 2000,       // 2s for batch API calls
    debounced: 500          // 500ms for debounced calls
  },
  
  // Memory and resource performance
  memory: {
    componentMount: 50,     // 50ms for component mounting
    cleanup: 25,            // 25ms for cleanup operations
    garbageCollection: 100  // 100ms for GC-related operations
  }
}

// Calculate environment-adjusted thresholds
const calculateThreshold = (baseThreshold) => {
  const multiplier = getCurrentMultiplier()
  return Math.ceil(baseThreshold * multiplier)
}

// Export performance thresholds adjusted for current environment
export const PERFORMANCE_THRESHOLDS = {
  utilityFunction: {
    largeNumbers: calculateThreshold(BASE_THRESHOLDS.utilityFunction.largeNumbers),
    repeatedCalls: calculateThreshold(BASE_THRESHOLDS.utilityFunction.repeatedCalls),
    singleCall: calculateThreshold(BASE_THRESHOLDS.utilityFunction.singleCall)
  },
  
  componentRender: {
    largeDataset: calculateThreshold(BASE_THRESHOLDS.componentRender.largeDataset),
    rapidReRender: calculateThreshold(BASE_THRESHOLDS.componentRender.rapidReRender),
    initialRender: calculateThreshold(BASE_THRESHOLDS.componentRender.initialRender)
  },
  
  apiCalls: {
    singleCall: calculateThreshold(BASE_THRESHOLDS.apiCalls.singleCall),
    batchCalls: calculateThreshold(BASE_THRESHOLDS.apiCalls.batchCalls),
    debounced: calculateThreshold(BASE_THRESHOLDS.apiCalls.debounced)
  },
  
  memory: {
    componentMount: calculateThreshold(BASE_THRESHOLDS.memory.componentMount),
    cleanup: calculateThreshold(BASE_THRESHOLDS.memory.cleanup),
    garbageCollection: calculateThreshold(BASE_THRESHOLDS.memory.garbageCollection)
  }
}

// Environment information for debugging
export const ENVIRONMENT_INFO = {
  isCI,
  isLocal,
  multiplier: getCurrentMultiplier(),
  platform: process.platform,
  nodeVersion: process.version,
  environment: isCI ? 'CI' : 'Local'
}

// Performance test utilities
export const performanceUtils = {
  /**
   * Measure execution time of a function
   * @param {Function} fn - Function to measure
   * @returns {Promise<{result: any, executionTime: number}>}
   */
  measureAsync: async (fn) => {
    const start = performance.now()
    const result = await fn()
    const end = performance.now()
    return {
      result,
      executionTime: end - start
    }
  },
  
  /**
   * Measure execution time of a synchronous function
   * @param {Function} fn - Function to measure
   * @returns {{result: any, executionTime: number}}
   */
  measureSync: (fn) => {
    const start = performance.now()
    const result = fn()
    const end = performance.now()
    return {
      result,
      executionTime: end - start
    }
  },
  
  /**
   * Create a performance assertion with environment context
   * @param {number} actualTime - Actual execution time
   * @param {number} threshold - Performance threshold
   * @param {string} testName - Name of the test for debugging
   */
  assertPerformance: (actualTime, threshold, testName) => {
    if (actualTime > threshold) {
      const envInfo = `Environment: ${ENVIRONMENT_INFO.environment} (${ENVIRONMENT_INFO.multiplier}x multiplier)`
      const message = `Performance test "${testName}" failed. Expected: <${threshold}ms, Actual: ${actualTime}ms. ${envInfo}`
      throw new Error(message)
    }
  }
}

// Export default configuration
export default {
  PERFORMANCE_THRESHOLDS,
  ENVIRONMENT_INFO,
  performanceUtils
}
