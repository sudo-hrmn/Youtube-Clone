import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import PlayVideo from '../Components/PlayVideo/PlayVideo.jsx'

// Mock the data module
vi.mock('../data', () => ({
  API_KEY: 'test-api-key',
  value_converter: vi.fn((value) => {
    if (value >= 1000000) return Math.floor(value / 1000000) + 'M'
    if (value >= 1000) return Math.floor(value / 1000) + 'K'
    return value?.toString() || '0'
  })
}))

// Mock image imports
vi.mock('../../assets/like.png', () => ({ default: 'like.png' }))
vi.mock('../../assets/dislike.png', () => ({ default: 'dislike.png' }))
vi.mock('../../assets/share.png', () => ({ default: 'share.png' }))
vi.mock('../../assets/save.png', () => ({ default: 'save.png' }))
vi.mock('../../assets/user_profile.jpg', () => ({ default: 'user_profile.jpg' }))

const mockVideoData = {
  items: [{
    id: 'test-video-id',
    snippet: {
      title: 'Test Video Title',
      channelTitle: 'Test Channel',
      channelId: 'test-channel-id',
      publishedAt: '2024-01-01T00:00:00Z',
      description: 'This is a test video description'
    },
    statistics: {
      viewCount: '1500000',
      likeCount: '50000',
      commentCount: '100'
    }
  }]
}

const mockChannelData = {
  items: [{
    id: 'test-channel-id',
    snippet: {
      title: 'Test Channel',
      thumbnails: {
        default: {
          url: 'https://example.com/channel-thumb.jpg'
        }
      }
    },
    statistics: {
      subscriberCount: '2000000'
    }
  }]
}

const mockCommentsData = {
  items: [
    {
      snippet: {
        topLevelComment: {
          snippet: {
            authorDisplayName: 'Test User 1',
            authorProfileImageUrl: 'https://example.com/user1.jpg',
            textDisplay: 'Great video!',
            publishedAt: '2024-01-02T00:00:00Z',
            likeCount: 5
          }
        }
      }
    },
    {
      snippet: {
        topLevelComment: {
          snippet: {
            authorDisplayName: 'Test User 2',
            authorProfileImageUrl: null,
            textDisplay: 'Thanks for sharing',
            publishedAt: '2024-01-03T00:00:00Z',
            likeCount: 2
          }
        }
      }
    }
  ]
}

describe('PlayVideo Component', () => {
  beforeEach(() => {
    global.fetch = vi.fn()
    vi.clearAllMocks()
  })

  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('should show loading state initially', () => {
    global.fetch.mockImplementation(() => new Promise(() => {})) // Never resolves
    
    render(<PlayVideo videoId="test-video-id" />)
    
    expect(screen.getByText('Loading...')).toBeInTheDocument()
  })

  it('should fetch and display video details', async () => {
    global.fetch
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockVideoData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockChannelData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockCommentsData)
      })

    render(<PlayVideo videoId="test-video-id" />)

    await waitFor(() => {
      expect(screen.getByText('Test Video Title')).toBeInTheDocument()
      expect(screen.getByText('Test Channel')).toBeInTheDocument()
      expect(screen.getByText(/1,500,000 views/)).toBeInTheDocument()
    })
  })

  it('should render YouTube iframe with correct src', async () => {
    global.fetch
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockVideoData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockChannelData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockCommentsData)
      })

    render(<PlayVideo videoId="test-video-id" />)

    await waitFor(() => {
      const iframe = screen.getByTitle('YouTube Video Player')
      expect(iframe).toHaveAttribute('src', 'https://www.youtube.com/embed/test-video-id?autoplay=1')
    })
  })

  it('should display video statistics correctly', async () => {
    global.fetch
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockVideoData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockChannelData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockCommentsData)
      })

    render(<PlayVideo videoId="test-video-id" />)

    await waitFor(() => {
      expect(screen.getByText('50000')).toBeInTheDocument() // Like count
      expect(screen.getByText(/1,500,000 views/)).toBeInTheDocument()
      expect(screen.getByText(/Mon Jan 01 2024/)).toBeInTheDocument()
    })
  })

  it('should display channel information', async () => {
    global.fetch
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockVideoData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockChannelData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockCommentsData)
      })

    render(<PlayVideo videoId="test-video-id" />)

    await waitFor(() => {
      expect(screen.getByText('2M subscribers')).toBeInTheDocument()
      expect(screen.getByText('Subscribe')).toBeInTheDocument()
    })
  })

  it('should display video description', async () => {
    global.fetch
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockVideoData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockChannelData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockCommentsData)
      })

    render(<PlayVideo videoId="test-video-id" />)

    await waitFor(() => {
      expect(screen.getByText('This is a test video description')).toBeInTheDocument()
    })
  })

  it('should display comments', async () => {
    global.fetch
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockVideoData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockChannelData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockCommentsData)
      })

    render(<PlayVideo videoId="test-video-id" />)

    await waitFor(() => {
      expect(screen.getByText('100 Comments')).toBeInTheDocument()
      expect(screen.getByText('Test User 1')).toBeInTheDocument()
      expect(screen.getByText('Great video!')).toBeInTheDocument()
      expect(screen.getByText('Test User 2')).toBeInTheDocument()
      expect(screen.getByText('Thanks for sharing')).toBeInTheDocument()
    })
  })

  it('should handle comments without profile images', async () => {
    global.fetch
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockVideoData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockChannelData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockCommentsData)
      })

    render(<PlayVideo videoId="test-video-id" />)

    await waitFor(() => {
      const commentImages = screen.getAllByAltText('user')
      expect(commentImages).toHaveLength(2)
      // One should have the actual profile image, one should have the default
      expect(commentImages[0]).toHaveAttribute('src', 'https://example.com/user1.jpg')
      expect(commentImages[1]).toHaveAttribute('src', 'user_profile.jpg')
    })
  })

  it('should render action buttons', async () => {
    global.fetch
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockVideoData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockChannelData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockCommentsData)
      })

    render(<PlayVideo videoId="test-video-id" />)

    await waitFor(() => {
      expect(screen.getByAltText('like')).toBeInTheDocument()
      expect(screen.getByAltText('dislike')).toBeInTheDocument()
      expect(screen.getByAltText('share')).toBeInTheDocument()
      expect(screen.getByAltText('save')).toBeInTheDocument()
    })
  })

  it('should make correct API calls', async () => {
    global.fetch
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockVideoData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockChannelData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockCommentsData)
      })

    render(<PlayVideo videoId="test-video-id" />)

    await waitFor(() => {
      expect(global.fetch).toHaveBeenCalledTimes(3)
      
      // Video details API call
      expect(global.fetch).toHaveBeenCalledWith(
        expect.stringContaining('videos?part=snippet,statistics&id=test-video-id')
      )
      
      // Channel details API call
      expect(global.fetch).toHaveBeenCalledWith(
        expect.stringContaining('channels?part=snippet,statistics&id=test-channel-id')
      )
      
      // Comments API call
      expect(global.fetch).toHaveBeenCalledWith(
        expect.stringContaining('commentThreads?part=snippet&videoId=test-video-id')
      )
    })
  })

  it('should refetch data when videoId changes', async () => {
    global.fetch
      .mockResolvedValue({
        json: () => Promise.resolve(mockVideoData)
      })
      .mockResolvedValue({
        json: () => Promise.resolve(mockChannelData)
      })
      .mockResolvedValue({
        json: () => Promise.resolve(mockCommentsData)
      })

    const { rerender } = render(<PlayVideo videoId="video1" />)

    await waitFor(() => {
      expect(global.fetch).toHaveBeenCalledTimes(3)
    })

    vi.clearAllMocks()
    global.fetch
      .mockResolvedValue({
        json: () => Promise.resolve(mockVideoData)
      })
      .mockResolvedValue({
        json: () => Promise.resolve(mockChannelData)
      })
      .mockResolvedValue({
        json: () => Promise.resolve(mockCommentsData)
      })

    rerender(<PlayVideo videoId="video2" />)

    await waitFor(() => {
      expect(global.fetch).toHaveBeenCalledTimes(3)
    })
  })

  it('should display comment like counts', async () => {
    global.fetch
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockVideoData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockChannelData)
      })
      .mockResolvedValueOnce({
        json: () => Promise.resolve(mockCommentsData)
      })

    render(<PlayVideo videoId="test-video-id" />)

    await waitFor(() => {
      const likeSpans = screen.getAllByText(/^[0-9]+$/)
      expect(likeSpans.some(span => span.textContent === '5')).toBe(true)
      expect(likeSpans.some(span => span.textContent === '2')).toBe(true)
    })
  })
})
