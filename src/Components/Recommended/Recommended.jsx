import React, { useEffect, useState, useCallback } from 'react'
import './Recommended.css'

import { API_KEY, value_converter } from '../../data'
import { Link, useParams } from 'react-router-dom'


const Recommended = ({categoryId}) => {

    const{videoId}=useParams();

    const [apiData, setApiData]=useState([]);

    const fetchData = useCallback(async () => {
        try {
            const relatedVideo_url=`https://youtube.googleapis.com/youtube/v3/videos?part=snippet%2CcontentDetails%2Cstatistics&chart=mostPopular&maxResults=45&regionCode=US&videoCategoryId=${categoryId}&key=${API_KEY}`
            const response = await fetch(relatedVideo_url);
            const data = await response.json();
            setApiData(data.items || []);
        } catch (error) {
            console.error('Error fetching recommended videos:', error);
            setApiData([]);
        }
    }, [categoryId])

    useEffect(()=>{
        fetchData();
    },[fetchData, videoId])
  return (
    <div className='recommended' >
        {apiData.map((item, index)=>{
            return(
            <Link to={`/video/${categoryId}/${item.id}`} key={index} className="side-video-list">
             <img src={item?.snippet?.thumbnails?.medium?.url || '/default-thumbnail.jpg'} alt={`Thumbnail for ${item?.snippet?.title || 'video'}`} />
                <div className="vid-info">
                    <h4>{item?.snippet?.title || 'Untitled Video'}</h4>
                    <p>{item?.snippet?.channelTitle || 'Unknown Channel'}</p>
                    <p>{item?.statistics?.viewCount ? value_converter(item.statistics.viewCount) : '0'} views</p>
            </div>
            </Link>
            )
        })}

        
        
    </div>
  )
}

export default Recommended
