import { describe, it, expect, vi } from 'vitest'
import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import App from '../App.jsx'

// Mock all components
vi.mock('../Components/Navbar/Navbar', () => ({
  default: () => <div data-testid="navbar">Navbar</div>
}))

vi.mock('../Pages/Home/Home', () => ({
  default: ({ sidebar }) => (
    <div data-testid="home-page">Home - Sidebar: {sidebar.toString()}</div>
  )
}))

vi.mock('../Pages/Video/Video', () => ({
  default: () => <div data-testid="video-page">Video Page</div>
}))

const renderWithMemoryRouter = (initialEntries = ['/']) => {
  return render(
    <MemoryRouter initialEntries={initialEntries}>
      <App />
    </MemoryRouter>
  )
}

describe('Routing Integration', () => {
  it('should render Home page on root route', () => {
    renderWithMemoryRouter(['/'])
    
    expect(screen.getByTestId('navbar')).toBeInTheDocument()
    expect(screen.getByTestId('home-page')).toBeInTheDocument()
    expect(screen.queryByTestId('video-page')).not.toBeInTheDocument()
  })

  it('should render Video page on video route', () => {
    renderWithMemoryRouter(['/video/1/123'])
    
    expect(screen.getByTestId('navbar')).toBeInTheDocument()
    expect(screen.getByTestId('video-page')).toBeInTheDocument()
    expect(screen.queryByTestId('home-page')).not.toBeInTheDocument()
  })

  it('should render Video page with different parameters', () => {
    renderWithMemoryRouter(['/video/music/abc123'])
    
    expect(screen.getByTestId('navbar')).toBeInTheDocument()
    expect(screen.getByTestId('video-page')).toBeInTheDocument()
  })

  it('should handle invalid routes gracefully', () => {
    renderWithMemoryRouter(['/invalid-route'])
    
    expect(screen.getByTestId('navbar')).toBeInTheDocument()
    // Should not render any page component for invalid routes
    expect(screen.queryByTestId('home-page')).not.toBeInTheDocument()
    expect(screen.queryByTestId('video-page')).not.toBeInTheDocument()
  })
})
