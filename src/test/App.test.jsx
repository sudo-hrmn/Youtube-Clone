import { describe, it, expect, vi } from 'vitest'
import { render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import App from '../App.jsx'

// Mock the components
vi.mock('../Components/Navbar/Navbar', () => ({
  default: ({ setSidebar }) => (
    <div data-testid="navbar">
      <button onClick={() => setSidebar(prev => !prev)}>Toggle Sidebar</button>
    </div>
  )
}))

vi.mock('../Pages/Home/Home', () => ({
  default: ({ sidebar }) => (
    <div data-testid="home-page">
      Home Page - Sidebar: {sidebar ? 'open' : 'closed'}
    </div>
  )
}))

vi.mock('../Pages/Video/Video', () => ({
  default: () => <div data-testid="video-page">Video Page</div>
}))

const renderWithRouter = (component, { route = '/' } = {}) => {
  window.history.pushState({}, 'Test page', route)
  return render(
    <BrowserRouter>
      {component}
    </BrowserRouter>
  )
}

describe('App Component', () => {
  it('should render navbar and home page by default', () => {
    renderWithRouter(<App />)
    
    expect(screen.getByTestId('navbar')).toBeInTheDocument()
    expect(screen.getByTestId('home-page')).toBeInTheDocument()
    expect(screen.getByText(/Home Page - Sidebar: open/)).toBeInTheDocument()
  })

  it('should render video page when navigating to video route', () => {
    renderWithRouter(<App />, { route: '/video/1/123' })
    
    expect(screen.getByTestId('navbar')).toBeInTheDocument()
    expect(screen.getByTestId('video-page')).toBeInTheDocument()
  })

  it('should initialize with sidebar state as true', () => {
    renderWithRouter(<App />)
    
    expect(screen.getByText(/Sidebar: open/)).toBeInTheDocument()
  })

  it('should pass sidebar state to Home component', () => {
    renderWithRouter(<App />)
    
    const homeElement = screen.getByTestId('home-page')
    expect(homeElement).toHaveTextContent('Sidebar: open')
  })
})
