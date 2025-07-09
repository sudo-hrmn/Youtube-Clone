import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import Feed from '../Components/Feed/Feed.jsx'

// Mock the data module
vi.mock('../data', () => ({
  API_KEY: 'test-api-key',
  value_converter: vi.fn((value) => {
    if (value >= 1000000) return Math.floor(value / 1000000) + 'M'
    if (value >= 1000) return Math.floor(value / 1000) + 'K'
    return value?.toString() || '0'
  })
}))

// Mock moment
vi.mock('moment/moment', () => ({
  default: vi.fn((date) => ({
    fromNow: () => '2 days ago'
  }))
}))

const mockVideoData = {
  items: [
    {
      id: 'video1',
      snippet: {
        title: 'Test Video 1',
        channelTitle: 'Test Channel 1',
        publishedAt: '2024-01-01T00:00:00Z',
        thumbnails: {
          medium: {
            url: 'https://example.com/thumb1.jpg'
          }
        }
      },
      statistics: {
        viewCount: '1500000'
      }
    },
    {
      id: 'video2',
      snippet: {
        title: 'Test Video 2',
        channelTitle: 'Test Channel 2',
        publishedAt: '2024-01-02T00:00:00Z',
        thumbnails: {
          medium: {
            url: 'https://example.com/thumb2.jpg'
          }
        }
      },
      statistics: {
        viewCount: '500000'
      }
    }
  ]
}

const renderWithRouter = (component) => {
  return render(
    <BrowserRouter>
      {component}
    </BrowserRouter>
  )
}

describe('Feed Component', () => {
  beforeEach(() => {
    global.fetch = vi.fn()
    vi.clearAllMocks()
  })

  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('should render loading state initially', () => {
    global.fetch.mockResolvedValueOnce({
      json: () => Promise.resolve(mockVideoData)
    })

    renderWithRouter(<Feed category={0} />)
    
    // Initially, no videos should be rendered
    expect(screen.queryByText('Test Video 1')).not.toBeInTheDocument()
  })

  it('should fetch and display videos', async () => {
    global.fetch.mockResolvedValueOnce({
      json: () => Promise.resolve(mockVideoData)
    })

    renderWithRouter(<Feed category={0} />)

    await waitFor(() => {
      expect(screen.getByText('Test Video 1')).toBeInTheDocument()
      expect(screen.getByText('Test Video 2')).toBeInTheDocument()
    })

    expect(screen.getByText('Test Channel 1')).toBeInTheDocument()
    expect(screen.getByText('Test Channel 2')).toBeInTheDocument()
  })

  it('should call fetch with correct URL for different categories', async () => {
    global.fetch.mockResolvedValueOnce({
      json: () => Promise.resolve(mockVideoData)
    })

    renderWithRouter(<Feed category={10} />)

    await waitFor(() => {
      expect(global.fetch).toHaveBeenCalledWith(
        expect.stringContaining('videoCategoryId=10')
      )
    })
  })

  it('should handle API errors gracefully', async () => {
    const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {})
    global.fetch.mockRejectedValueOnce(new Error('API Error'))

    renderWithRouter(<Feed category={0} />)

    await waitFor(() => {
      expect(consoleSpy).toHaveBeenCalledWith('Error fetching video data', expect.any(Error))
    })

    consoleSpy.mockRestore()
  })

  it('should handle empty API response', async () => {
    global.fetch.mockResolvedValueOnce({
      json: () => Promise.resolve({ items: null })
    })

    renderWithRouter(<Feed category={0} />)

    await waitFor(() => {
      expect(screen.queryByText('Test Video 1')).not.toBeInTheDocument()
    })
  })

  it('should render video links with correct URLs', async () => {
    global.fetch.mockResolvedValueOnce({
      json: () => Promise.resolve(mockVideoData)
    })

    renderWithRouter(<Feed category={5} />)

    await waitFor(() => {
      const videoLinks = screen.getAllByRole('link')
      expect(videoLinks[0]).toHaveAttribute('href', '/video/5/video1')
      expect(videoLinks[1]).toHaveAttribute('href', '/video/5/video2')
    })
  })

  it('should display formatted view counts', async () => {
    global.fetch.mockResolvedValueOnce({
      json: () => Promise.resolve(mockVideoData)
    })

    renderWithRouter(<Feed category={0} />)

    await waitFor(() => {
      expect(screen.getByText(/1M views/)).toBeInTheDocument()
      expect(screen.getByText(/500K views/)).toBeInTheDocument()
    })
  })

  it('should display relative time', async () => {
    global.fetch.mockResolvedValueOnce({
      json: () => Promise.resolve(mockVideoData)
    })

    renderWithRouter(<Feed category={0} />)

    await waitFor(() => {
      const timeElements = screen.getAllByText(/2 days ago/)
      expect(timeElements).toHaveLength(2)
    })
  })

  it('should refetch data when category changes', async () => {
    global.fetch.mockResolvedValue({
      json: () => Promise.resolve(mockVideoData)
    })

    const { rerender } = renderWithRouter(<Feed category={0} />)

    await waitFor(() => {
      expect(global.fetch).toHaveBeenCalledTimes(1)
    })

    rerender(
      <BrowserRouter>
        <Feed category={10} />
      </BrowserRouter>
    )

    await waitFor(() => {
      expect(global.fetch).toHaveBeenCalledTimes(2)
      expect(global.fetch).toHaveBeenLastCalledWith(
        expect.stringContaining('videoCategoryId=10')
      )
    })
  })

  it('should render video thumbnails', async () => {
    global.fetch.mockResolvedValueOnce({
      json: () => Promise.resolve(mockVideoData)
    })

    renderWithRouter(<Feed category={0} />)

    await waitFor(() => {
      const thumbnails = screen.getAllByAltText('thumbnail')
      expect(thumbnails).toHaveLength(2)
      expect(thumbnails[0]).toHaveAttribute('src', 'https://example.com/thumb1.jpg')
      expect(thumbnails[1]).toHaveAttribute('src', 'https://example.com/thumb2.jpg')
    })
  })
})
