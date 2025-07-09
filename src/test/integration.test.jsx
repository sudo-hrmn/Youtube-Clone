import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { BrowserRouter, MemoryRouter } from 'react-router-dom'
import App from '../App.jsx'

// Mock all the components to focus on integration
vi.mock('../Components/Navbar/Navbar', () => ({
  default: ({ setSidebar }) => (
    <div data-testid="navbar">
      <button data-testid="toggle-sidebar" onClick={() => setSidebar(prev => !prev)}>
        Toggle
      </button>
    </div>
  )
}))

vi.mock('../Components/Sidebar/Sidebar', () => ({
  default: ({ sidebar, category, setCategory }) => (
    <div data-testid="sidebar" className={sidebar ? 'open' : 'closed'}>
      <button data-testid="category-home" onClick={() => setCategory(0)}>Home</button>
      <button data-testid="category-music" onClick={() => setCategory(10)}>Music</button>
      <button data-testid="category-gaming" onClick={() => setCategory(20)}>Gaming</button>
      <div data-testid="current-category">Category: {category}</div>
    </div>
  )
}))

vi.mock('../Components/Feed/Feed', () => ({
  default: ({ category }) => (
    <div data-testid="feed">
      <div data-testid="feed-category">Feed Category: {category}</div>
      <div data-testid="video-item">Mock Video 1</div>
      <div data-testid="video-item">Mock Video 2</div>
    </div>
  )
}))

vi.mock('../Components/PlayVideo/PlayVideo', () => ({
  default: ({ videoId }) => (
    <div data-testid="play-video">
      Playing Video: {videoId}
    </div>
  )
}))

vi.mock('../Components/Recommended/Recommended', () => ({
  default: ({ categoryId }) => (
    <div data-testid="recommended">
      Recommended for category: {categoryId}
    </div>
  )
}))

const renderWithMemoryRouter = (initialEntries = ['/']) => {
  return render(
    <MemoryRouter initialEntries={initialEntries}>
      <App />
    </MemoryRouter>
  )
}

describe('Integration Tests', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  describe('Home Page Integration', () => {
    it('should render complete home page with all components', () => {
      renderWithMemoryRouter(['/'])
      
      expect(screen.getByTestId('navbar')).toBeInTheDocument()
      expect(screen.getByTestId('sidebar')).toBeInTheDocument()
      expect(screen.getByTestId('feed')).toBeInTheDocument()
    })

    it('should handle sidebar toggle from navbar', () => {
      renderWithMemoryRouter(['/'])
      
      const sidebar = screen.getByTestId('sidebar')
      expect(sidebar).toHaveClass('open')
      
      fireEvent.click(screen.getByTestId('toggle-sidebar'))
      
      expect(sidebar).toHaveClass('closed')
    })

    it('should handle category changes from sidebar to feed', () => {
      renderWithMemoryRouter(['/'])
      
      // Initial state
      expect(screen.getByText('Category: 0')).toBeInTheDocument()
      expect(screen.getByText('Feed Category: 0')).toBeInTheDocument()
      
      // Change to music category
      fireEvent.click(screen.getByTestId('category-music'))
      
      expect(screen.getByText('Category: 10')).toBeInTheDocument()
      expect(screen.getByText('Feed Category: 10')).toBeInTheDocument()
      
      // Change to gaming category
      fireEvent.click(screen.getByTestId('category-gaming'))
      
      expect(screen.getByText('Category: 20')).toBeInTheDocument()
      expect(screen.getByText('Feed Category: 20')).toBeInTheDocument()
    })

    it('should maintain sidebar state across category changes', () => {
      renderWithMemoryRouter(['/'])
      
      // Close sidebar
      fireEvent.click(screen.getByTestId('toggle-sidebar'))
      expect(screen.getByTestId('sidebar')).toHaveClass('closed')
      
      // Change category
      fireEvent.click(screen.getByTestId('category-music'))
      
      // Sidebar should remain closed
      expect(screen.getByTestId('sidebar')).toHaveClass('closed')
      expect(screen.getByText('Feed Category: 10')).toBeInTheDocument()
    })
  })

  describe('Video Page Integration', () => {
    it('should render video page with play video and recommendations', () => {
      renderWithMemoryRouter(['/video/10/abc123'])
      
      expect(screen.getByTestId('navbar')).toBeInTheDocument()
      expect(screen.getByTestId('play-video')).toBeInTheDocument()
      expect(screen.getByTestId('recommended')).toBeInTheDocument()
    })

    it('should pass correct parameters to video components', () => {
      renderWithMemoryRouter(['/video/15/xyz789'])
      
      expect(screen.getByText('Playing Video: xyz789')).toBeInTheDocument()
      expect(screen.getByText('Recommended for category: 15')).toBeInTheDocument()
    })

    it('should maintain navbar functionality on video page', () => {
      renderWithMemoryRouter(['/video/10/test123'])
      
      expect(screen.getByTestId('navbar')).toBeInTheDocument()
      expect(screen.getByTestId('toggle-sidebar')).toBeInTheDocument()
    })
  })

  describe('Navigation Integration', () => {
    it('should navigate between home and video pages', () => {
      const { rerender } = render(
        <MemoryRouter initialEntries={['/']}>
          <App />
        </MemoryRouter>
      )
      
      // Should be on home page
      expect(screen.getByTestId('feed')).toBeInTheDocument()
      expect(screen.queryByTestId('play-video')).not.toBeInTheDocument()
      
      // Navigate to video page
      rerender(
        <MemoryRouter initialEntries={['/video/10/test123']}>
          <App />
        </MemoryRouter>
      )
      
      expect(screen.getByTestId('play-video')).toBeInTheDocument()
      expect(screen.queryByTestId('feed')).not.toBeInTheDocument()
    })

    it('should handle invalid routes', () => {
      renderWithMemoryRouter(['/invalid-route'])
      
      // Should still render navbar
      expect(screen.getByTestId('navbar')).toBeInTheDocument()
      
      // Should not render any page components
      expect(screen.queryByTestId('feed')).not.toBeInTheDocument()
      expect(screen.queryByTestId('play-video')).not.toBeInTheDocument()
    })
  })

  describe('State Management Integration', () => {
    it('should maintain independent state for different concerns', () => {
      renderWithMemoryRouter(['/'])
      
      // Initial states
      expect(screen.getByTestId('sidebar')).toHaveClass('open')
      expect(screen.getByText('Category: 0')).toBeInTheDocument()
      
      // Change sidebar state
      fireEvent.click(screen.getByTestId('toggle-sidebar'))
      expect(screen.getByTestId('sidebar')).toHaveClass('closed')
      
      // Change category
      fireEvent.click(screen.getByTestId('category-music'))
      expect(screen.getByText('Category: 10')).toBeInTheDocument()
      
      // Sidebar state should be independent
      expect(screen.getByTestId('sidebar')).toHaveClass('closed')
      
      // Toggle sidebar again
      fireEvent.click(screen.getByTestId('toggle-sidebar'))
      expect(screen.getByTestId('sidebar')).toHaveClass('open')
      
      // Category should remain unchanged
      expect(screen.getByText('Category: 10')).toBeInTheDocument()
    })

    it('should reset to home category when navigating back to home', () => {
      const { rerender } = render(
        <MemoryRouter initialEntries={['/']}>
          <App />
        </MemoryRouter>
      )
      
      // Change category on home page
      fireEvent.click(screen.getByTestId('category-music'))
      expect(screen.getByText('Category: 10')).toBeInTheDocument()
      
      // Navigate to video page
      rerender(
        <MemoryRouter initialEntries={['/video/20/test']}>
          <App />
        </MemoryRouter>
      )
      
      // Navigate back to home
      rerender(
        <MemoryRouter initialEntries={['/']}>
          <App />
        </MemoryRouter>
      )
      
      // Category state should be preserved
      expect(screen.getByText('Category: 10')).toBeInTheDocument()
    })
  })

  describe('Component Communication', () => {
    it('should properly communicate between parent and child components', () => {
      renderWithMemoryRouter(['/'])
      
      // Test navbar -> app -> home -> sidebar -> feed communication chain
      expect(screen.getByText('Feed Category: 0')).toBeInTheDocument()
      
      // Trigger change through sidebar
      fireEvent.click(screen.getByTestId('category-gaming'))
      
      // Should propagate to feed
      expect(screen.getByText('Feed Category: 20')).toBeInTheDocument()
      
      // Should update sidebar display
      expect(screen.getByText('Category: 20')).toBeInTheDocument()
    })

    it('should handle rapid state changes', () => {
      renderWithMemoryRouter(['/'])
      
      // Rapid category changes
      fireEvent.click(screen.getByTestId('category-music'))
      fireEvent.click(screen.getByTestId('category-gaming'))
      fireEvent.click(screen.getByTestId('category-home'))
      
      // Should end up in correct state
      expect(screen.getByText('Category: 0')).toBeInTheDocument()
      expect(screen.getByText('Feed Category: 0')).toBeInTheDocument()
    })
  })

  describe('Error Boundaries and Edge Cases', () => {
    it('should handle component rendering without crashing', () => {
      expect(() => {
        renderWithMemoryRouter(['/'])
      }).not.toThrow()
    })

    it('should handle route parameter edge cases', () => {
      const edgeCases = [
        '/video/0/test',
        '/video/999/test',
        '/video/abc/test',
        '/video//test',
        '/video/10/',
      ]
      
      edgeCases.forEach(route => {
        expect(() => {
          const { unmount } = renderWithMemoryRouter([route])
          unmount()
        }).not.toThrow()
      })
    })
  })
})
