import React from 'react';
import RecommendList from '../models/recommend';

import Item from './item'

var recommend = new RecommendList();

export default class Recommend extends React.Component {
  constructor(props){
    super(props);
    recommend.addEventListener('loaded', ()=>{this.reload()});
    this.mounted = true;
  }
  reload(){ if(this.mounted){this.setState({});} }
  componentDidMount(){
    this.mounted = true;
    $('title').text("Recommned - Pig Media Server");
    recommend.load(this.props.location.query.name);
    window.list = recommend;
  }
  componentWillUnmount(){ this.mounted = false; }
  render(){
    var items = recommend.list.map((e)=>{
      return <Item key={e.key} item={e} />
    });
    return <div>
      <p>{items}</p>
    </div>
  }

  next(){
    var index = this.list.map((e,i)=>{return e.key}).indexOf(playing.item.key);
    var item = null
    while(index > -1){
      index = index - 1;
      item = this.list[index];
      if(item.type == 'video'){break}
    }
    if(item){ playing.set(item); }
  }
}
