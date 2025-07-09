# Testing Guide for YouTube Clone

This document provides comprehensive information about testing the YouTube Clone application using Vitest.

## 🧪 Testing Stack

- **Vitest**: Fast unit test framework
- **@testing-library/react**: React component testing utilities
- **@testing-library/jest-dom**: Custom Jest matchers for DOM elements
- **@testing-library/user-event**: User interaction simulation
- **jsdom**: DOM environment for testing

## 📁 Test Structure

```
src/test/
├── setup.js                 # Test environment setup
├── data.test.js             # Utility functions tests
├── App.test.jsx             # Main App component tests
├── Navbar.test.jsx          # Navbar component tests
├── Home.test.jsx            # Home page tests
├── routing.test.jsx         # Routing integration tests
└── state-management.test.jsx # State management tests
```

## 🚀 Running Tests

### Basic Commands

```bash
# Run tests in watch mode (recommended for development)
npm test

# Run tests once and exit
npm run test:run

# Run tests with coverage report
npm run test:coverage

# Open Vitest UI (interactive testing)
npm run test:ui
```

### Using the Test Runner Script

```bash
# Watch mode (default)
node test-runner.js

# Run once
node test-runner.js run

# Coverage report
node test-runner.js coverage

# Interactive UI
node test-runner.js ui

# Help
node test-runner.js help
```

## 📊 Test Coverage

The project is configured to generate coverage reports in multiple formats:
- **Text**: Console output
- **HTML**: Interactive web report in `coverage/` directory
- **JSON**: Machine-readable format

### Coverage Exclusions

- `node_modules/`
- `src/test/` (test files themselves)
- `src/assets/` (static assets)
- Configuration files
- Build output (`dist/`)

## 🧩 Test Categories

### 1. Unit Tests

#### Utility Functions (`data.test.js`)
- Tests the `value_converter` function
- Covers number formatting (K, M, B suffixes)
- Edge cases and boundary conditions

#### Component Tests
- **App Component**: Routing and state management
- **Navbar Component**: User interactions and prop handling
- **Home Component**: Component composition and state passing

### 2. Integration Tests

#### Routing Tests (`routing.test.jsx`)
- Route navigation
- Component rendering based on routes
- Invalid route handling

#### State Management Tests (`state-management.test.jsx`)
- State initialization
- State updates through user interactions
- State propagation between components

## 🎯 Testing Best Practices

### Component Testing Patterns

```javascript
// 1. Mock external dependencies
vi.mock('../Components/SomeComponent', () => ({
  default: ({ prop }) => <div data-testid="mock-component">{prop}</div>
}))

// 2. Use data-testid for reliable element selection
<div data-testid="component-name">Content</div>

// 3. Test user interactions
fireEvent.click(screen.getByTestId('button'))

// 4. Assert on behavior, not implementation
expect(screen.getByText('Expected Text')).toBeInTheDocument()
```

### Mocking Strategies

#### Image Assets
```javascript
vi.mock('../../assets/image.png', () => ({ default: 'image.png' }))
```

#### React Router
```javascript
const renderWithRouter = (component) => {
  return render(
    <BrowserRouter>
      {component}
    </BrowserRouter>
  )
}
```

#### Component Dependencies
```javascript
vi.mock('../Components/Child', () => ({
  default: ({ prop }) => <div data-testid="child">Mock: {prop}</div>
}))
```

## 🔧 Configuration

### Vitest Configuration (`vite.config.js`)

```javascript
test: {
  globals: true,           // Global test functions (describe, it, expect)
  environment: 'jsdom',    // DOM environment for React components
  setupFiles: './src/test/setup.js',  // Test setup file
  css: true,              // Process CSS imports
  coverage: {
    provider: 'v8',       // Coverage provider
    reporter: ['text', 'json', 'html'],  // Coverage formats
    exclude: [            // Files to exclude from coverage
      'node_modules/',
      'src/test/',
      '**/*.{test,spec}.{js,jsx}',
      'src/assets/',
      '**/*.config.js',
      'dist/',
    ],
  },
}
```

### Test Setup (`src/test/setup.js`)

- Imports `@testing-library/jest-dom` matchers
- Mocks browser APIs (matchMedia, IntersectionObserver, ResizeObserver)
- Provides global test utilities

## 📝 Writing New Tests

### 1. Component Test Template

```javascript
import { describe, it, expect, vi } from 'vitest'
import { render, screen, fireEvent } from '@testing-library/react'
import YourComponent from '../path/to/YourComponent'

// Mock dependencies
vi.mock('../dependency', () => ({
  default: () => <div data-testid="mock">Mock</div>
}))

describe('YourComponent', () => {
  it('should render correctly', () => {
    render(<YourComponent prop="value" />)
    
    expect(screen.getByTestId('your-component')).toBeInTheDocument()
  })

  it('should handle user interactions', () => {
    const mockHandler = vi.fn()
    render(<YourComponent onAction={mockHandler} />)
    
    fireEvent.click(screen.getByRole('button'))
    
    expect(mockHandler).toHaveBeenCalledTimes(1)
  })
})
```

### 2. Utility Function Test Template

```javascript
import { describe, it, expect } from 'vitest'
import { yourUtilityFunction } from '../path/to/utility'

describe('yourUtilityFunction', () => {
  it('should handle normal cases', () => {
    expect(yourUtilityFunction('input')).toBe('expected')
  })

  it('should handle edge cases', () => {
    expect(yourUtilityFunction(null)).toBe('default')
    expect(yourUtilityFunction('')).toBe('empty')
  })
})
```

## 🐛 Debugging Tests

### Common Issues and Solutions

1. **Component not rendering**
   - Check if all dependencies are mocked
   - Verify import paths
   - Ensure proper test environment setup

2. **State updates not working**
   - Use `act()` for async state updates
   - Check if event handlers are properly bound

3. **Router-related errors**
   - Wrap components with `BrowserRouter` or `MemoryRouter`
   - Mock navigation functions if needed

### Debug Commands

```bash
# Run specific test file
npm test -- data.test.js

# Run tests matching pattern
npm test -- --grep "navbar"

# Run tests in debug mode
npm test -- --inspect-brk

# Verbose output
npm test -- --reporter=verbose
```

## 📈 Continuous Integration

### GitHub Actions Example

```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm run test:run
      - run: npm run test:coverage
```

## 🎯 Testing Goals

- **Unit Test Coverage**: >80% for utility functions
- **Component Coverage**: >70% for React components
- **Integration Coverage**: All major user flows tested
- **Performance**: Tests should run in <30 seconds

## 📚 Additional Resources

- [Vitest Documentation](https://vitest.dev/)
- [Testing Library Documentation](https://testing-library.com/)
- [React Testing Best Practices](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)

---

**Happy Testing! 🧪✨**
