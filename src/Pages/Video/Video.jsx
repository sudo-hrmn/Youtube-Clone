import React from 'react'
import './Video.css'
import PlayVideo from '../../Components/PlayVideo/PlayVideo'
import Recommended from '../../Components/Recommended/Recommended'
import { useParams } from 'react-router-dom'

const Video = () => {

  const {videoId, categoryId}=useParams()

  return (
    <div>
      <div className="play-container">
        <PlayVideo videoId={videoId} />
        <Recommended categoryId={categoryId} />
      </div>
    </div>
  )
}

export default Video
