import React from 'react';
import LatestList from '../models/latest';

import Item from './item'
import Pager from './pager'

var latest = new LatestList();

export default class Recommend extends React.Component {
  constructor(props){
    super(props);
    latest.addEventListener('loaded', ()=>{this.reload()});
    this.mounted = true;
  }
  reload(){ if(this.mounted){this.setState({});} }
  componentDidMount(){
    this.mounted = true;
    $('title').text("Latest - Pig Media Server");
    latest.load(this.props.location.query.page);
    window.list = latest;
  }
  componentWillUnmount(){ this.mounted = false; }
  render(){
    var items = latest.list.map((e)=>{
      return <Item key={e.key} item={e} />
    });
    return <div>
      <p>{items}</p>
      <Pager location={this.props.location} list={latest}/>
    </div>
  }
}
