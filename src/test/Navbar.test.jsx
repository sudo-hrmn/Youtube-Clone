import { describe, it, expect, vi } from 'vitest'
import { render, screen, fireEvent } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import Navbar from '../Components/Navbar/Navbar.jsx'

// Mock the image imports
vi.mock('../../assets/menu.png', () => ({ default: 'menu-icon.png' }))
vi.mock('../../assets/logo.png', () => ({ default: 'logo.png' }))
vi.mock('../../assets/search.png', () => ({ default: 'search-icon.png' }))
vi.mock('../../assets/upload.png', () => ({ default: 'upload-icon.png' }))
vi.mock('../../assets/more.png', () => ({ default: 'more-icon.png' }))
vi.mock('../../assets/notification.png', () => ({ default: 'notification-icon.png' }))
vi.mock('../../assets/jack.png', () => ({ default: 'profile-icon.png' }))

const renderWithRouter = (component) => {
  return render(
    <BrowserRouter>
      {component}
    </BrowserRouter>
  )
}

describe('Navbar Component', () => {
  it('should render all navbar elements', () => {
    const mockSetSidebar = vi.fn()
    const { container } = renderWithRouter(<Navbar setSidebar={mockSetSidebar} />)
    
    // Check if menu icon is present using class selector
    const menuIcon = container.querySelector('.menu-icon')
    expect(menuIcon).toBeInTheDocument()
    
    // Check if search input is present
    const searchInput = screen.getByPlaceholderText('search')
    expect(searchInput).toBeInTheDocument()
    
    // Check if logo link is present
    const logoLink = screen.getByRole('link')
    expect(logoLink).toHaveAttribute('href', '/')
  })

  it('should call setSidebar when menu icon is clicked', () => {
    const mockSetSidebar = vi.fn()
    const { container } = renderWithRouter(<Navbar setSidebar={mockSetSidebar} />)
    
    const menuIcon = container.querySelector('.menu-icon')
    fireEvent.click(menuIcon)
    
    expect(mockSetSidebar).toHaveBeenCalledTimes(1)
    expect(mockSetSidebar).toHaveBeenCalledWith(expect.any(Function))
  })

  it('should toggle sidebar state correctly', () => {
    const mockSetSidebar = vi.fn()
    const { container } = renderWithRouter(<Navbar setSidebar={mockSetSidebar} />)
    
    const menuIcon = container.querySelector('.menu-icon')
    fireEvent.click(menuIcon)
    
    // Test the function passed to setSidebar
    const toggleFunction = mockSetSidebar.mock.calls[0][0]
    expect(toggleFunction(false)).toBe(true)
    expect(toggleFunction(true)).toBe(false)
  })

  it('should have correct CSS classes', () => {
    const mockSetSidebar = vi.fn()
    renderWithRouter(<Navbar setSidebar={mockSetSidebar} />)
    
    const nav = screen.getByRole('navigation')
    expect(nav).toHaveClass('flex-div')
    
    const searchInput = screen.getByPlaceholderText('search')
    expect(searchInput).toBeInTheDocument()
  })

  it('should render search functionality', () => {
    const mockSetSidebar = vi.fn()
    renderWithRouter(<Navbar setSidebar={mockSetSidebar} />)
    
    const searchInput = screen.getByPlaceholderText('search')
    expect(searchInput).toBeInTheDocument()
    expect(searchInput).toHaveAttribute('type', 'text')
  })

  it('should render all navigation icons', () => {
    const mockSetSidebar = vi.fn()
    const { container } = renderWithRouter(<Navbar setSidebar={mockSetSidebar} />)
    
    // Count all images using querySelector
    const images = container.querySelectorAll('img')
    expect(images).toHaveLength(7)
    
    // Verify specific icons by their classes
    expect(container.querySelector('.menu-icon')).toBeInTheDocument()
    expect(container.querySelector('.logo')).toBeInTheDocument()
    expect(container.querySelector('.user-icon')).toBeInTheDocument()
  })
})
