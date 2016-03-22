import React from 'react';
import CustomList from '../models/custom';

import Item from './item'

var custom = new CustomList();

export default class Custom extends React.Component {
  constructor(props){
    super(props);
    custom.addEventListener('loaded', ()=>{this.reload()});
    this.mounted = true;
  }
  reload(){ if(this.mounted){this.setState({});} }
  componentDidMount(){
    this.mounted = true;
    $('title').text("Pig Media Server");
    custom.load(this.props.location.query.name);
    window.list = custom;
  }
  componentDidUpdate(prevProps){
    if(this.props.location.query != prevProps.location.query){
      custom.load(this.props.location.query.name);
    }
  }
  componentWillUnmount(){ this.mounted = false; }
  render(){
    var items = custom.list.map((e)=>{
      return <Item key={e.key} item={e} />
    });
    return <div>
      <p>{items}</p>
    </div>
  }
}
