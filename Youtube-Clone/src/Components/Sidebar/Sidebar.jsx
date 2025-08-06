import React from 'react'
import './Sidebar.css'

import home from '../../assets/home.png'
import game_icon from '../../assets/game_icon.png'
import automobiles from '../../assets/automobiles.png'
import sports from '../../assets/sports.png'
import entertainment from '../../assets/entertainment.png'
import tech from '../../assets/tech.png'
import music from '../../assets/music.png'
import blogs from '../../assets/blogs.png'
import news from '../../assets/news.png'
import jack from '../../assets/jack.png'
import simon from '../../assets/simon.png'
import tom from '../../assets/tom.png'
import megan from '../../assets/megan.png'
import cameron from '../../assets/cameron.png'

const Sidebar = ({ sidebar ,category , setCategory}) => {
  return (
    <div className={`sidebar ${sidebar ? '' : 'small-sidebar'}`}>
      <div className="shortcut-links">
        <button className={`side-link ${category===0?"active":" "}`} onClick={()=>setCategory(0)} type="button" aria-label="Home category">
          <img src={home} alt="Home" /> <p>home</p>
        </button>
        <button className={`side-link ${category===20?"active":" "}`}  onClick={()=>setCategory(20)} type="button" aria-label="Gaming category">
          <img src={game_icon} alt="Gaming" /> <p>game</p>
        </button>
        <button className={`side-link ${category===2?"active":" "}`} onClick={()=>setCategory(2)} type="button" aria-label="Automobiles category">
          <img src={automobiles} alt="Automobiles" /> <p>automobiles</p>
        </button>
        <button className={`side-link ${category===17?"active":" "}`}  onClick={()=>setCategory(17)} type="button" aria-label="Sports category">
          <img src={sports} alt="Sports" /> <p>sports</p>
        </button>
        <button className={`side-link ${category===24?"active":" "}`}  onClick={()=>setCategory(24)} type="button" aria-label="Entertainment category">
          <img src={entertainment} alt="Entertainment" /> <p>entertainment</p>
        </button>
        <button className={`side-link ${category===28?"active":" "}`}  onClick={()=>setCategory(28)} type="button" aria-label="Technology category">
          <img src={tech} alt="Technology" /> <p>tech</p>
        </button>
        <button className={`side-link ${category===10?"active":" "}`}  onClick={()=>setCategory(10)} type="button" aria-label="Music category">
          <img src={music} alt="Music" /> <p>music</p>
        </button>
        <button className={`side-link ${category===22?"active":" "}`}  onClick={()=>setCategory(22)} type="button" aria-label="Blogs category">
          <img src={blogs} alt="Blogs" /> <p>blogs</p>
        </button>
        <button className={`side-link ${category===25?"active":" "}`}  onClick={()=>setCategory(25)} type="button" aria-label="News category">
          <img src={news} alt="News" /> <p>news</p>
        </button>
        <hr />
      </div>
      <div className="subscribed-list">
        <h3>Subscribed</h3>
        <div className="side-link">
          <img src={jack} alt="" /> <p>pewtiepie</p>
        </div>
        <div className="side-link">
          <img src={simon} alt="" /> <p>MrBeast</p>
        </div>
        <div className="side-link">
          <img src={tom} alt="" /> <p>justin bieber</p>
        </div>
        <div className="side-link">
          <img src={megan} alt="" /> <p>5 min craft</p>
        </div>
        <div className="side-link">
          <img src={cameron} alt="" /> <p>nas daily</p>
        </div>
      </div>
    </div>
  )
}

export default Sidebar
