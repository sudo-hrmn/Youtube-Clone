import { describe, it, expect, vi } from 'vitest'
import { render, screen } from '@testing-library/react'
import Home from '../Pages/Home/Home.jsx'

// Mock the child components
vi.mock('../Components/Sidebar/Sidebar', () => ({
  default: ({ sidebar, category, setCategory }) => (
    <div data-testid="sidebar">
      <div>Sidebar visible: {sidebar ? 'true' : 'false'}</div>
      <div>Category: {category}</div>
      <button onClick={() => setCategory(1)}>Change Category</button>
    </div>
  )
}))

vi.mock('../Components/Feed/Feed', () => ({
  default: ({ category }) => (
    <div data-testid="feed">
      Feed with category: {category}
    </div>
  )
}))

describe('Home Component', () => {
  it('should render sidebar and feed components', () => {
    render(<Home sidebar={true} />)
    
    expect(screen.getByTestId('sidebar')).toBeInTheDocument()
    expect(screen.getByTestId('feed')).toBeInTheDocument()
  })

  it('should pass sidebar prop to Sidebar component', () => {
    render(<Home sidebar={true} />)
    
    expect(screen.getByText('Sidebar visible: true')).toBeInTheDocument()
  })

  it('should handle sidebar false state', () => {
    render(<Home sidebar={false} />)
    
    expect(screen.getByText('Sidebar visible: false')).toBeInTheDocument()
  })

  it('should initialize category state to 0', () => {
    render(<Home sidebar={true} />)
    
    expect(screen.getByText('Category: 0')).toBeInTheDocument()
    expect(screen.getByText('Feed with category: 0')).toBeInTheDocument()
  })

  it('should apply correct container class when sidebar is open', () => {
    render(<Home sidebar={true} />)
    
    const container = screen.getByTestId('feed').parentElement
    expect(container).toHaveClass('container')
    expect(container).not.toHaveClass('large-container')
  })

  it('should apply large-container class when sidebar is closed', () => {
    render(<Home sidebar={false} />)
    
    const container = screen.getByTestId('feed').parentElement
    expect(container).toHaveClass('container', 'large-container')
  })

  it('should pass category state to both Sidebar and Feed components', () => {
    render(<Home sidebar={true} />)
    
    expect(screen.getByText('Category: 0')).toBeInTheDocument()
    expect(screen.getByText('Feed with category: 0')).toBeInTheDocument()
  })
})
