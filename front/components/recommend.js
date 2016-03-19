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
}
