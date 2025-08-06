import React, { useEffect, useState, useCallback } from 'react';
import './Feed.css';
import { API_KEY, value_converter } from '../../data';
import { Link } from 'react-router-dom';
import moment from 'moment/moment';

const Feed = ({ category }) => {
  const [data, setData] = useState([]);

  const fetchData = useCallback(async () => {
    const videoList_url = `https://youtube.googleapis.com/youtube/v3/videos?part=snippet%2CcontentDetails%2Cstatistics&chart=mostPopular&maxResults=50&regionCode=US&videoCategoryId=${category}&key=${API_KEY}`;

    try {
      const res = await fetch(videoList_url);
      const json = await res.json();
      setData(json.items || []);
    } catch (err) {
      console.error("Error fetching video data", err);
    }
  }, [category]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  return (
    <div className="feed">
      {data.map((item, index) => (
        <Link to={`/video/${category}/${item.id}`} className="card" key={index}>
          <img src={item.snippet?.thumbnails?.medium?.url} alt="thumbnail" />
          <h2>{item.snippet?.title}</h2>
          <h3>{item.snippet?.channelTitle}</h3>
          <p>{value_converter(item.statistics?.viewCount)} views &bull; {moment(item.snippet?.publishedAt).fromNow()}</p>
        </Link>
      ))}
    </div>
  );
};

export default Feed;
