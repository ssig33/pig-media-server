class Player extends React.Component {
  video_url(){
    var url = null;
    if(!!this.props.state.video){ url = this.props.state.video.url; }
    return url;
  }
  componentDidUpdate(){
    if(!!this.video_url()){
      var node = this.refs.video.getDOMNode();
      if(node.currentTime == 0){
        node.addEventListener('canplay', (e)=>{ 
          var target = e.target;
          target.play(); 
          this.props.state.models.recent.use(`movie/${this.props.state.video.key}`);
          target.addEventListener('ended', (e)=>{
            var src = $(target).attr("src");
            if(src && src != ''){ this.next(); }
          });
        });
        node.load();
      }
    }
  }
  class_name(){ if(!!this.video_url()){ return "" } else { return "none" } }

  close(){
    this.props.state.set_video(null);
  }

  render(){
    return <div className={this.class_name()} id='area'>
      <video 
        ref='video'
        src={this.video_url()} 
        controls='controls'
      />
      <a href='javascript:void(0)' onClick={()=> this.close()}>Close Video</a>
    </div>
  }
}

window.Player = Player;
