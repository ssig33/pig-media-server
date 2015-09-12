class Player extends React.Component {
  constructor(props){
    super(props);
    this.current_url = '';
  }
  close(){ this.props.state.set_video(null); }
  dom(){ return this.refs.video.getDOMNode(); }

  video_url(){
    var url = null;
    if(!!this.props.state.video){ url = this.props.state.video.url; }
    return url;
  }

  to_play(url){
    if(!!url){
      if(url != this.current_url){
        this.current_url = url;
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  play(prev){
    if(this.to_play(this.video_url())){
      console.log("LOAD");
      var node = this.dom();
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

  size_loop(){
    if(!!this.video_url()){
      var video_width = this.dom().videoWidth;
      var video_height = this.dom().videoHeight;
      
      var width = $(window).width();
      var height = $(window).height();

      var new_w, new_h;

      if(parseFloat(video_height) / parseFloat(video_width) < parseFloat(height) / parseFloat(width)){
        new_w = width;
        new_h = parseInt((parseFloat(video_height) * (parseFloat(width) / parseFloat(video_width))));
      } else {
        new_w = parseInt((parseFloat(video_width) * (parseFloat(height) / parseFloat(video_height))));
        new_h = height;
      }
      new_w = new_w - 10;
      new_h = new_h - 10;

      var spacer = (height - new_h) / 2;

      $(this.dom()).css({width: new_w, height: new_h});
      $(this.refs.spacer.getDOMNode()).css({height: spacer});
    }
    setTimeout(()=>{ this.size_loop()}, 200)
  }

  capture(){
    var c = this.refs.canvas.getDOMNode();
    var v = this.dom();
    var context = c.getContext('2d');
    c.width = v.videoWidth;
    c.height = v.videoHeight;
    context.drawImage(v, 0, 0);
    return c.toDataURL();
  }

  seek(count){ this.dom().currentTime += count; }
  pause(){
    this.dom().paused ? this.dom().play() : this.dom().pause();
  }
  gyazo(){
    var url = this.capture();
    $.post('/gyazo', {url: url, point: localStorage.gyazo}).done((data)=>{
      window.open(data.url, "", "width=500,height=400");
    });
  }
  tweet(){ $.post('/gyazo/tweet', {url: this.capture()}).success((data)=>{return true}); }
  comment_tweet(){
    var comment = prompt('tweet');
    if(!!comment){
      $.post('/gyazo/tweet', {url: this.capture(), comment: comment}).success((data)=>{return true});
    }
  }


  bind(){
    $(window).keyup((e)=>{
      if(!!$(this.dom()).attr('src')){
        switch(e.keyCode){
          case 74:
            this.seek(15);
            break;
          case 75:
            this.seek(-15);
            break;
          case 80:
            this.pause();
            break;
          case 71:
            this.gyazo();
            break;
          case 78:
            this.next();
            break;
          case 67:
            this.comment_tweet();
            break;
          case 84:
            this.tweet();
            break;
        }
      }
    });
  }

  componentDidMount(){ this.size_loop(); this.bind(); }
  componentDidUpdate(prev, prevState){ this.play(prev); }
  
  class_name(){ if(!!this.video_url()){ return "" } else { return "none" } }

  render(){
    return <div className={this.class_name()} id='area'>
      <div ref='spacer' />
      <video 
        ref='video'
        src={this.video_url()} 
        controls='controls'
      />
      <canvas className='none' ref='canvas' />
      <div style={{height: '300px'}}/>
      <a href='javascript:void(0)' onClick={()=> this.close()}>Close Video</a>
    </div>
  }
}

window.Player = Player;
