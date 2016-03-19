import React from 'react';

export default class NewFlag extends React.Component {
  constructor(props){
    super(props);
    recent.addEventListener('loaded', ()=>{ this.reload()});
  }
  reload(){
    this.setState({});
  }
  ext(str){ return String(str).split('.').pop().toLowerCase(); }
  is_new(){
    var ext = this.ext(this.props.item.name);
    if(ext == 'mp4' || ext == 'flv'){
      var result = true;
      jQuery.each(recent.data, (k,v)=>{ 
        if(k == `movie/${this.props.item.key}`){ result = false } 
      });
      return result
    } else {
      return false;
    }
  }

  render(){
    var is_new = this.is_new();
    return <span>{is_new ? <span className='new_flag' style={{color:'lime', "fontWeight":'bold'}}>New</span> : null }</span>
  }
}
