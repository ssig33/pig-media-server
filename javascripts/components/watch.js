class ChromeCast extends React.Component {
  is_video(){
    var e = ext(this.props.item.name);
    return e == 'mp4' || e == 'flv';
  }

  click(){
    window.chrome_cast(this.props.item.url, this.props.item.key)
  }

  set_video(){ this.props.state.set_video(this.props.item); }
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
  is_video(){
    var e = ext(this.props.item.name);
    return e == 'mp4' || e == 'flv';
  }

  set_video(){ this.props.state.set_video(this.props.item); }
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

window.Watch = Watch;
window.ChromeCast = ChromeCast;
