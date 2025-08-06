import { describe, it, expect, vi } from 'vitest'
import { render, screen, fireEvent } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import App from '../App.jsx'

// Mock components with state interaction
vi.mock('../Components/Navbar/Navbar', () => ({
  default: ({ setSidebar }) => (
    <div data-testid="navbar">
      <button 
        data-testid="toggle-sidebar" 
        onClick={() => setSidebar(prev => !prev)}
      >
        Toggle Sidebar
      </button>
    </div>
  )
}))

vi.mock('../Pages/Home/Home', () => ({
  default: ({ sidebar }) => (
    <div data-testid="home-page">
      <div data-testid="sidebar-state">Sidebar: {sidebar ? 'open' : 'closed'}</div>
    </div>
  )
}))

vi.mock('../Pages/Video/Video', () => ({
  default: () => <div data-testid="video-page">Video Page</div>
}))

const renderWithRouter = (component) => {
  return render(
    <BrowserRouter>
      {component}
    </BrowserRouter>
  )
}

describe('State Management', () => {
  it('should initialize sidebar state as true', () => {
    renderWithRouter(<App />)
    
    expect(screen.getByTestId('sidebar-state')).toHaveTextContent('Sidebar: open')
  })

  it('should toggle sidebar state when navbar button is clicked', () => {
    renderWithRouter(<App />)
    
    // Initial state should be open
    expect(screen.getByTestId('sidebar-state')).toHaveTextContent('Sidebar: open')
    
    // Click toggle button
    fireEvent.click(screen.getByTestId('toggle-sidebar'))
    
    // State should now be closed
    expect(screen.getByTestId('sidebar-state')).toHaveTextContent('Sidebar: closed')
    
    // Click again to toggle back
    fireEvent.click(screen.getByTestId('toggle-sidebar'))
    
    // State should be open again
    expect(screen.getByTestId('sidebar-state')).toHaveTextContent('Sidebar: open')
  })

  it('should maintain sidebar state across multiple toggles', () => {
    renderWithRouter(<App />)
    
    const toggleButton = screen.getByTestId('toggle-sidebar')
    const sidebarState = screen.getByTestId('sidebar-state')
    
    // Initial state
    expect(sidebarState).toHaveTextContent('Sidebar: open')
    
    // Multiple toggles
    fireEvent.click(toggleButton) // Should be closed
    expect(sidebarState).toHaveTextContent('Sidebar: closed')
    
    fireEvent.click(toggleButton) // Should be open
    expect(sidebarState).toHaveTextContent('Sidebar: open')
    
    fireEvent.click(toggleButton) // Should be closed
    expect(sidebarState).toHaveTextContent('Sidebar: closed')
  })

  it('should pass sidebar state correctly to Home component', () => {
    renderWithRouter(<App />)
    
    // Verify the prop is passed correctly
    const homeComponent = screen.getByTestId('home-page')
    expect(homeComponent).toBeInTheDocument()
    
    const sidebarState = screen.getByTestId('sidebar-state')
    expect(sidebarState).toHaveTextContent('Sidebar: open')
  })
})
