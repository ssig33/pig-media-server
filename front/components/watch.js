import React from 'react';

class ChromeCast extends React.Component {
  ext(str){ return String(str).split('.').pop().toLowerCase(); }
  is_video(){ var e = this.ext(this.props.item.name); return e == 'mp4' || e == 'flv'; }

  click(){ window.chrome_cast(this.props.item.url, this.props.item.key) } 
  render(){
    return <span>
      {this.is_video() ?
        <span>
          <a 
            className="watch" 
            href="javascript:void(0)"
            title={this.props.item.name}
            onClick={()=> this.click()}
          >ChromeCast</a>
          &nbsp;
        </span>
        : null}
    </span>
  }
}


class Watch extends React.Component {
  ext(str){ return String(str).split('.').pop().toLowerCase(); }
  is_video(){
    var e = this.ext(this.props.item.name);
    return e == 'mp4' || e == 'flv';
  }

  set_video(){ playing.set(this.props.item); }
  render(){
    return <span>
      {this.is_video() ?
        <span>
          <a 
            className="watch" 
            href="javascript:void(0)"
            title={this.props.item.name}
            onClick={()=> this.set_video()}
          >Watch</a>
          &nbsp;
        </span>
        : null}
    </span>
  }
}

module.exports = {Watch: Watch, ChromeCast: ChromeCast}
