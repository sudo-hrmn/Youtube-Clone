import { render } from '@testing-library/react'
import { BrowserRouter, MemoryRouter } from 'react-router-dom'

/**
 * Custom render function that includes Router wrapper
 * @param {React.Component} ui - Component to render
 * @param {Object} options - Render options
 * @returns {Object} - Render result
 */
export const renderWithRouter = (ui, options = {}) => {
  const { initialEntries: _initialEntries = ['/'], ...renderOptions } = options
  
  const Wrapper = ({ children }) => (
    <BrowserRouter>
      {children}
    </BrowserRouter>
  )
  
  return render(ui, { wrapper: Wrapper, ...renderOptions })
}

/**
 * Custom render function with MemoryRouter for testing specific routes
 * @param {React.Component} ui - Component to render
 * @param {Object} options - Render options including initialEntries
 * @returns {Object} - Render result
 */
export const renderWithMemoryRouter = (ui, options = {}) => {
  const { initialEntries = ['/'], ...renderOptions } = options
  
  const Wrapper = ({ children }) => (
    <MemoryRouter initialEntries={initialEntries}>
      {children}
    </MemoryRouter>
  )
  
  return render(ui, { wrapper: Wrapper, ...renderOptions })
}

/**
 * Mock function factory for creating consistent mock functions
 * @param {string} name - Name of the mock function
 * @returns {Function} - Mock function
 */
export const createMockFunction = (name = 'mockFunction') => {
  const mockFn = vi.fn()
  mockFn.displayName = name
  return mockFn
}

/**
 * Helper to create mock component with props logging
 * @param {string} name - Component name
 * @param {string} testId - Test ID for the mock component
 * @returns {Function} - Mock component
 */
export const createMockComponent = (name, testId) => {
  return (props) => (
    <div data-testid={testId} data-component={name}>
      {name} Mock - Props: {JSON.stringify(props)}
    </div>
  )
}

/**
 * Helper to wait for async operations in tests
 * @param {number} ms - Milliseconds to wait
 * @returns {Promise} - Promise that resolves after specified time
 */
export const waitFor = (ms = 0) => {
  return new Promise(resolve => setTimeout(resolve, ms))
}

/**
 * Helper to simulate user typing
 * @param {HTMLElement} element - Input element
 * @param {string} text - Text to type
 */
export const typeText = async (element, text) => {
  const { userEvent } = await import('@testing-library/user-event')
  const user = userEvent.setup()
  await user.type(element, text)
}

/**
 * Helper to simulate user clicking
 * @param {HTMLElement} element - Element to click
 */
export const clickElement = async (element) => {
  const { userEvent } = await import('@testing-library/user-event')
  const user = userEvent.setup()
  await user.click(element)
}

/**
 * Common test data for YouTube clone
 */
export const testData = {
  mockVideo: {
    id: 'test-video-123',
    title: 'Test Video Title',
    views: 1000000,
    publishedAt: '2024-01-01T00:00:00Z',
    channelTitle: 'Test Channel',
    thumbnail: 'test-thumbnail.jpg'
  },
  
  mockChannel: {
    id: 'test-channel-123',
    title: 'Test Channel',
    subscriberCount: 500000,
    thumbnail: 'test-channel-thumbnail.jpg'
  },
  
  mockComment: {
    id: 'test-comment-123',
    text: 'This is a test comment',
    authorDisplayName: 'Test User',
    likeCount: 10,
    publishedAt: '2024-01-01T00:00:00Z'
  }
}

/**
 * Mock API responses for testing
 */
export const mockApiResponses = {
  videos: {
    items: [testData.mockVideo],
    nextPageToken: 'next-page-token'
  },
  
  videoDetails: {
    items: [{
      ...testData.mockVideo,
      statistics: {
        viewCount: '1000000',
        likeCount: '50000',
        commentCount: '1000'
      }
    }]
  },
  
  comments: {
    items: [testData.mockComment]
  }
}

/**
 * Helper to mock localStorage
 */
export const mockLocalStorage = () => {
  const localStorageMock = {
    getItem: vi.fn(),
    setItem: vi.fn(),
    removeItem: vi.fn(),
    clear: vi.fn(),
  }
  
  Object.defineProperty(window, 'localStorage', {
    value: localStorageMock
  })
  
  return localStorageMock
}

/**
 * Helper to mock fetch API
 * @param {Object} mockResponse - Mock response object
 */
export const mockFetch = (mockResponse) => {
  global.fetch = vi.fn(() =>
    Promise.resolve({
      ok: true,
      json: () => Promise.resolve(mockResponse),
    })
  )
}

/**
 * Helper to reset all mocks
 */
export const resetAllMocks = () => {
  vi.clearAllMocks()
  vi.resetAllMocks()
}
