import { describe, it, expect, vi } from 'vitest'
import { render, screen, fireEvent } from '@testing-library/react'
import Sidebar from '../Components/Sidebar/Sidebar.jsx'

// Mock all the image imports
vi.mock('../../assets/home.png', () => ({ default: 'home.png' }))
vi.mock('../../assets/game_icon.png', () => ({ default: 'game_icon.png' }))
vi.mock('../../assets/automobiles.png', () => ({ default: 'automobiles.png' }))
vi.mock('../../assets/sports.png', () => ({ default: 'sports.png' }))
vi.mock('../../assets/entertainment.png', () => ({ default: 'entertainment.png' }))
vi.mock('../../assets/tech.png', () => ({ default: 'tech.png' }))
vi.mock('../../assets/music.png', () => ({ default: 'music.png' }))
vi.mock('../../assets/blogs.png', () => ({ default: 'blogs.png' }))
vi.mock('../../assets/news.png', () => ({ default: 'news.png' }))
vi.mock('../../assets/jack.png', () => ({ default: 'jack.png' }))
vi.mock('../../assets/simon.png', () => ({ default: 'simon.png' }))
vi.mock('../../assets/tom.png', () => ({ default: 'tom.png' }))
vi.mock('../../assets/megan.png', () => ({ default: 'megan.png' }))
vi.mock('../../assets/cameron.png', () => ({ default: 'cameron.png' }))

describe('Sidebar Component', () => {
  const defaultProps = {
    sidebar: true,
    category: 0,
    setCategory: vi.fn()
  }

  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('should render with full sidebar when sidebar prop is true', () => {
    render(<Sidebar {...defaultProps} />)
    
    const sidebar = screen.getByText('home').closest('.sidebar')
    expect(sidebar).not.toHaveClass('small-sidebar')
  })

  it('should render with small sidebar when sidebar prop is false', () => {
    render(<Sidebar {...defaultProps} sidebar={false} />)
    
    const sidebar = screen.getByText('home').closest('.sidebar')
    expect(sidebar).toHaveClass('small-sidebar')
  })

  it('should render all category links', () => {
    render(<Sidebar {...defaultProps} />)
    
    expect(screen.getByText('home')).toBeInTheDocument()
    expect(screen.getByText('game')).toBeInTheDocument()
    expect(screen.getByText('automobiles')).toBeInTheDocument()
    expect(screen.getByText('sports')).toBeInTheDocument()
    expect(screen.getByText('entertainment')).toBeInTheDocument()
    expect(screen.getByText('tech')).toBeInTheDocument()
    expect(screen.getByText('music')).toBeInTheDocument()
    expect(screen.getByText('blogs')).toBeInTheDocument()
    expect(screen.getByText('news')).toBeInTheDocument()
  })

  it('should render subscribed channels section', () => {
    render(<Sidebar {...defaultProps} />)
    
    expect(screen.getByText('Subscribed')).toBeInTheDocument()
    expect(screen.getByText('pewtiepie')).toBeInTheDocument()
    expect(screen.getByText('MrBeast')).toBeInTheDocument()
    expect(screen.getByText('justin bieber')).toBeInTheDocument()
    expect(screen.getByText('5 min craft')).toBeInTheDocument()
    expect(screen.getByText('nas daily')).toBeInTheDocument()
  })

  it('should highlight active category', () => {
    render(<Sidebar {...defaultProps} category={20} />)
    
    const gameLink = screen.getByText('game').closest('.side-link')
    const homeLink = screen.getByText('home').closest('.side-link')
    
    expect(gameLink).toHaveClass('active')
    expect(homeLink).not.toHaveClass('active')
  })

  it('should call setCategory when category link is clicked', () => {
    const mockSetCategory = vi.fn()
    render(<Sidebar {...defaultProps} setCategory={mockSetCategory} />)
    
    fireEvent.click(screen.getByText('game'))
    expect(mockSetCategory).toHaveBeenCalledWith(20)
    
    fireEvent.click(screen.getByText('music'))
    expect(mockSetCategory).toHaveBeenCalledWith(10)
    
    fireEvent.click(screen.getByText('tech'))
    expect(mockSetCategory).toHaveBeenCalledWith(28)
  })

  it('should handle all category clicks correctly', () => {
    const mockSetCategory = vi.fn()
    render(<Sidebar {...defaultProps} setCategory={mockSetCategory} />)
    
    const categoryTests = [
      { text: 'home', expectedCategory: 0 },
      { text: 'game', expectedCategory: 20 },
      { text: 'automobiles', expectedCategory: 2 },
      { text: 'sports', expectedCategory: 17 },
      { text: 'entertainment', expectedCategory: 24 },
      { text: 'tech', expectedCategory: 28 },
      { text: 'music', expectedCategory: 10 },
      { text: 'blogs', expectedCategory: 22 },
      { text: 'news', expectedCategory: 25 }
    ]
    
    categoryTests.forEach(({ text, expectedCategory }) => {
      fireEvent.click(screen.getByText(text))
      expect(mockSetCategory).toHaveBeenCalledWith(expectedCategory)
    })
    
    expect(mockSetCategory).toHaveBeenCalledTimes(9)
  })

  it('should render correct active states for different categories', () => {
    const categories = [
      { category: 0, activeText: 'home' },
      { category: 20, activeText: 'game' },
      { category: 2, activeText: 'automobiles' },
      { category: 17, activeText: 'sports' },
      { category: 24, activeText: 'entertainment' },
      { category: 28, activeText: 'tech' },
      { category: 10, activeText: 'music' },
      { category: 22, activeText: 'blogs' },
      { category: 25, activeText: 'news' }
    ]
    
    categories.forEach(({ category, activeText }) => {
      const { rerender } = render(<Sidebar {...defaultProps} category={category} />)
      
      const activeLink = screen.getByText(activeText).closest('.side-link')
      expect(activeLink).toHaveClass('active')
      
      rerender(<div />)
    })
  })

  it('should not make subscribed channels clickable', () => {
    const mockSetCategory = vi.fn()
    render(<Sidebar {...defaultProps} setCategory={mockSetCategory} />)
    
    // Subscribed channels should not have click handlers
    fireEvent.click(screen.getByText('pewtiepie'))
    fireEvent.click(screen.getByText('MrBeast'))
    
    expect(mockSetCategory).not.toHaveBeenCalled()
  })

  it('should render all images with correct alt attributes', () => {
    const { container } = render(<Sidebar {...defaultProps} />)
    
    const images = container.querySelectorAll('img')
    expect(images).toHaveLength(14) // 9 category icons + 5 subscriber avatars
    
    // Category images should have descriptive alt attributes for accessibility
    const categoryImages = container.querySelectorAll('button img')
    categoryImages.forEach(img => {
      expect(img).toHaveAttribute('alt')
      expect(img.getAttribute('alt')).not.toBe('')
    })
    
    // Subscriber images should have empty alt attributes (decorative)
    const subscriberImages = container.querySelectorAll('.subscribed-list img')
    subscriberImages.forEach(img => {
      expect(img).toHaveAttribute('alt', '')
    })
  })

  it('should maintain sidebar state across category changes', () => {
    const { rerender } = render(<Sidebar {...defaultProps} sidebar={false} category={0} />)
    
    let sidebar = screen.getByText('home').closest('.sidebar')
    expect(sidebar).toHaveClass('small-sidebar')
    
    rerender(<Sidebar {...defaultProps} sidebar={false} category={20} />)
    
    sidebar = screen.getByText('home').closest('.sidebar')
    expect(sidebar).toHaveClass('small-sidebar')
  })

  it('should render horizontal rule separator', () => {
    const { container } = render(<Sidebar {...defaultProps} />)
    
    const hr = container.querySelector('hr')
    expect(hr).toBeInTheDocument()
  })
})
