import React, { useEffect, useState, useCallback } from 'react'
import './Recommended.css'

import { API_KEY, value_converter } from '../../data'
import { Link, useParams } from 'react-router-dom'


const Recommended = ({categoryId}) => {

    const{videoId}=useParams();

    const [apiData, setApiData]=useState([]);

    const fetchData = useCallback(async () => {
        const relatedVideo_url=`https://youtube.googleapis.com/youtube/v3/videos?part=snippet%2CcontentDetails%2Cstatistics&chart=mostPopular&maxResults=45&regionCode=US&videoCategoryId=${categoryId}&key=${API_KEY}`
        await fetch(relatedVideo_url).then(res=>res.json()).then(data=>setApiData(data.items))
    }, [categoryId])

    useEffect(()=>{
        fetchData();
    },[fetchData])
    
    useEffect(()=>{
        fetchData();
    },[videoId, fetchData])
  return (
    <div className='recommended' >
        {apiData.map((item, index)=>{
            return(
            <Link to={`/video/${categoryId}/${item.id}`} key={index} className="side-video-list">
             <img src={item?.snippet?.thumbnails?.medium?.url || '/default-thumbnail.jpg'} alt="" />
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
