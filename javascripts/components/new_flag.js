class NewFlag extends React.Component{
  is_new(){
    if(!!this.props.state.recents){
      var ext = window.ext(this.props.item.name);
      if(ext == 'mp4' || ext == 'flv'){
        var result = true;
        $.each(this.props.state.recents, (k,v)=>{ if(k == `movie/${this.props.item.key}`){ result = false } });
        return result
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  render(){
    var is_new = this.is_new();
    return <span>{is_new ? <span className='new_flag' style={{color:'lime', "fontWeight":'bold'}}>New</span> : null }</span>
  }
}

window.NewFlag = NewFlag;
