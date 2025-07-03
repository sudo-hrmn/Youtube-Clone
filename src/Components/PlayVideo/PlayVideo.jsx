import React, { useEffect, useState } from 'react';
import './PlayVideo.css';
import { API_KEY, value_converter } from '../../data';
import like from '../../assets/like.png';
import dislike from '../../assets/dislike.png';
import share from '../../assets/share.png';
import save from '../../assets/save.png';
import user_profile from '../../assets/user_profile.jpg';

const PlayVideo = ({ videoId }) => {
  const [videoDetail, setVideoDetail] = useState(null);
  const [channelDetail, setChannelDetail] = useState(null);
  const [comments, setComments] = useState([]);

  // Fetch video details
  useEffect(() => {
    const fetchVideoData = async () => {
      const videoRes = await fetch(
        `https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&id=${videoId}&key=${API_KEY}`
      );
      const videoData = await videoRes.json();
      setVideoDetail(videoData.items[0]);

      const channelId = videoData.items[0].snippet.channelId;

      // Fetch channel info
      const channelRes = await fetch(
        `https://www.googleapis.com/youtube/v3/channels?part=snippet,statistics&id=${channelId}&key=${API_KEY}`
      );
      const channelData = await channelRes.json();
      setChannelDetail(channelData.items[0]);
    };

    const fetchComments = async () => {
      const commentRes = await fetch(
        `https://www.googleapis.com/youtube/v3/commentThreads?part=snippet&videoId=${videoId}&key=${API_KEY}`
      );
      const commentData = await commentRes.json();
      setComments(commentData.items);
    };

    fetchVideoData();
    fetchComments();
  }, [videoId]);

  if (!videoDetail || !channelDetail) return <div>Loading...</div>;

  return (
    <div className='play-video'>
      <iframe
        src={`https://www.youtube.com/embed/${videoId}?autoplay=1`}
        frameBorder="0"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
        allowFullScreen
        title="YouTube Video Player"
      ></iframe>

      <h3>{videoDetail.snippet.title}</h3>

      <div className="play-video-info">
        <p>
          {parseInt(videoDetail.statistics.viewCount).toLocaleString()} views &bull;{' '}
          {new Date(videoDetail.snippet.publishedAt).toDateString()}
        </p>
        <div>
          <span><img src={like} alt="like" /> {videoDetail.statistics.likeCount}</span>
          <span><img src={dislike} alt="dislike" /> Dislike</span>
          <span><img src={share} alt="share" /> Share</span>
          <span><img src={save} alt="save" /> Save</span>
        </div>
      </div>

      <hr />

      <div className="publisher">
        <img src={channelDetail.snippet.thumbnails.default.url} alt="channel" />
        <div>
          <p>{videoDetail.snippet.channelTitle}</p>
          <span> {value_converter(channelDetail.statistics.subscriberCount)} subscribers</span>
        </div>
        <button>Subscribe</button>
      </div>

      <div className="vid-description">
        <p>{videoDetail.snippet.description}</p>
        <hr />
        <h4>{videoDetail.statistics.commentCount} Comments</h4>

        {comments.map((comment, index) => {
          const topComment = comment.snippet.topLevelComment.snippet;
          return (
            <div className="comment" key={index}>
              <img src={topComment.authorProfileImageUrl || user_profile} alt="user" />
              <div>
                <h3>{topComment.authorDisplayName} <span>{new Date(topComment.publishedAt).toDateString()}</span></h3>
                <p>{topComment.textDisplay}</p>
                <div className="comment-action">
                  <img src={like} alt="like" />
                  <span>{topComment.likeCount}</span>
                  <img src={dislike} alt="dislike" />
                  <span>Dislike</span>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

export default PlayVideo;
