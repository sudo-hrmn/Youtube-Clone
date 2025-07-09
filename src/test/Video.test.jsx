import { describe, it, expect, vi } from 'vitest'
import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import Video from '../Pages/Video/Video.jsx'

// Mock the child components
vi.mock('../Components/PlayVideo/PlayVideo', () => ({
  default: ({ videoId }) => (
    <div data-testid="play-video">
      PlayVideo Component - Video ID: {videoId}
    </div>
  )
}))

vi.mock('../Components/Recommended/Recommended', () => ({
  default: ({ categoryId }) => (
    <div data-testid="recommended">
      Recommended Component - Category ID: {categoryId}
    </div>
  )
}))

const renderWithRouter = (route) => {
  return render(
    <MemoryRouter initialEntries={[route]}>
      <Video />
    </MemoryRouter>
  )
}

describe('Video Component', () => {
  it('should render PlayVideo and Recommended components', () => {
    renderWithRouter('/video/10/abc123')
    
    expect(screen.getByTestId('play-video')).toBeInTheDocument()
    expect(screen.getByTestId('recommended')).toBeInTheDocument()
  })

  it('should pass correct videoId to PlayVideo component', () => {
    renderWithRouter('/video/15/xyz789')
    
    expect(screen.getByText('PlayVideo Component - Video ID: xyz789')).toBeInTheDocument()
  })

  it('should pass correct categoryId to Recommended component', () => {
    renderWithRouter('/video/20/def456')
    
    expect(screen.getByText('Recommended Component - Category ID: 20')).toBeInTheDocument()
  })

  it('should handle different route parameters', () => {
    const testCases = [
      { route: '/video/0/home123', expectedCategory: '0', expectedVideo: 'home123' },
      { route: '/video/10/music456', expectedCategory: '10', expectedVideo: 'music456' },
      { route: '/video/25/news789', expectedCategory: '25', expectedVideo: 'news789' },
    ]

    testCases.forEach(({ route, expectedCategory, expectedVideo }) => {
      const { unmount } = renderWithRouter(route)
      
      expect(screen.getByText(`PlayVideo Component - Video ID: ${expectedVideo}`)).toBeInTheDocument()
      expect(screen.getByText(`Recommended Component - Category ID: ${expectedCategory}`)).toBeInTheDocument()
      
      unmount()
    })
  })

  it('should render with correct CSS structure', () => {
    const { container } = renderWithRouter('/video/10/test123')
    
    expect(container.querySelector('.play-container')).toBeInTheDocument()
  })

  it('should handle missing route parameters gracefully', () => {
    renderWithRouter('/video//')
    
    // Components should still render even with empty parameters
    expect(screen.getByTestId('play-video')).toBeInTheDocument()
    expect(screen.getByTestId('recommended')).toBeInTheDocument()
  })

  it('should handle special characters in video ID', () => {
    renderWithRouter('/video/10/abc-123_xyz')
    
    expect(screen.getByText('PlayVideo Component - Video ID: abc-123_xyz')).toBeInTheDocument()
  })

  it('should handle numeric category IDs correctly', () => {
    renderWithRouter('/video/999/test')
    
    expect(screen.getByText('Recommended Component - Category ID: 999')).toBeInTheDocument()
  })

  it('should maintain component structure', () => {
    const { container } = renderWithRouter('/video/10/test123')
    
    const playContainer = container.querySelector('.play-container')
    expect(playContainer).toBeInTheDocument()
    
    const playVideo = playContainer.querySelector('[data-testid="play-video"]')
    const recommended = playContainer.querySelector('[data-testid="recommended"]')
    
    expect(playVideo).toBeInTheDocument()
    expect(recommended).toBeInTheDocument()
  })

  it('should re-render when route parameters change', () => {
    const { rerender } = render(
      <MemoryRouter initialEntries={['/video/10/video1']}>
        <Video />
      </MemoryRouter>
    )
    
    expect(screen.getByText('PlayVideo Component - Video ID: video1')).toBeInTheDocument()
    expect(screen.getByText('Recommended Component - Category ID: 10')).toBeInTheDocument()
    
    rerender(
      <MemoryRouter initialEntries={['/video/20/video2']}>
        <Video />
      </MemoryRouter>
    )
    
    expect(screen.getByText('PlayVideo Component - Video ID: video2')).toBeInTheDocument()
    expect(screen.getByText('Recommended Component - Category ID: 20')).toBeInTheDocument()
  })
})
