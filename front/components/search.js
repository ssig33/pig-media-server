import React from 'react'
import {Link} from 'react-router'
import jQuery from 'jQuery'

import SearchList from '../models/list'

import Item from './item'
import Pager from './pager'

var list = new SearchList();

class QuerySave extends React.Component{
  constructor(props){
    super(props);
  }
  
  click(){
    jQuery.post("/api/r/query_list", {query: this.props.query})
  }
  render(){
    return <span>
      <a href='javascript:void(0)' onClick={()=> this.click()}>Save Query</a>
    </span>
  }
}

class Sort extends React.Component{
  can_change_order(){ return !!this.props.location.query.sort }
  change_order(order){
    var params = this.props.location.query;
    params.order = order;
    history.pushState('','',"/?"+jQuery.param(params));
    list.search(params);
  }
  render(){
    return <p>
      <Link to={`/?query=${this.props.query}&sort=date`}>Sort By Date</Link>
      <Link to={`/?query=${this.props.query}&sort=name`}>Sort By Name</Link>
      {this.can_change_order() ?
        <span>
          <a href="javascript:void(0)" onClick={()=> this.change_order('ascending')}>Ascending</a>
          <a href="javascript:void(0)" onClick={()=> this.change_order('descending')}>Descending</a>
        </span>
        : null
      }
      <QuerySave query={this.props.query} />
    </p>
  }
  
}

export default class Search extends React.Component {
  constructor(props){
    super(props);
    this.state = {}
    this.mounted = true;
    list.addEventListener('loaded', ()=>{this.reload()});
  }
  reload(){ if(this.mounted){this.setState({});} }

  search(){
    list.search(this.props.location.query)
    $('title').text(`${this.props.location.query.query} - Pig Media Server`);
  }
  componentDidMount(){
    this.mounted = true;
    this.search();
  }
  componentDidUpdate(prevProps){
    if(this.props.location.query != prevProps.location.query){
      this.search();
    }
  }
  componentWillUnmount(){ this.mounted = false; }

  render(){
    var items = list.list.map((e)=>{
      return <Item key={e.key} item={e} />
    });
    return <div>
      <Sort query={this.props.location.query.query} location={this.props.location}/>
      <p>{items}</p>
      <Pager location={this.props.location} list={list}/>
    </div>
  }
}
