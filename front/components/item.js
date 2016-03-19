import React from 'react';

import NewFlag from './new_flag'
import {Watch, ChromeCast} from './watch'

class CustomLinks extends React.Component{
  render(){
    return <span dangerouslySetInnerHTML={{__html: this.props.item.custom_links}}/>
  }
}


export default class Item extends React.Component {
  mtime(){ 
    return this.props.item.mtime;
  }

  size_pretty(size){
    var size = parseFloat(String(size));
    var result = size;
    if(size < 1024){
      result = `${size} Bytes`
    } else if(size < 1024*1024){
      result = `${this.round(size / 1024)} KB`
    } else if(size < 1024*1024*1024){
      result = `${this.round(size / (1024*1024))} MB`
    } else if(size < 1024*1024*1024*1024){
      result = `${this.round(size / (1024*1024*1024))} GB`
    }
    return result
  }

  round(i){
    i = i*10;
    return Math.round(i)/10
  }



  render(){
    var item = this.props.item;
    var meta = `/meta/${this.props.item.key}`;
    var sub = `/sub/${this.props.item.key}`;
    return <span className='main_span'>
      <NewFlag 
        item={this.props.item}
      />
      <a href={item.url} className='main_link'>{item.name}</a>&nbsp;

      <Watch 
        item={this.props.item}
      />
      <ChromeCast
        item={this.props.item}
      />
      <span className='mtime'>{this.mtime()}</span>&nbsp;
      <span className='size'>{this.size_pretty(item.size)}</span>&nbsp;
      <a className='meta' href={meta}>Meta</a>
      <a className='meta' href={sub}>Sub</a>
      <CustomLinks item={this.props.item} />
    </span>
  }
}
