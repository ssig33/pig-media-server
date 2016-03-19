import React from 'react';
import {Link, browserHistory} from 'react-router'
import jQuery from 'jquery'

import Controller from '../controller'

var controller = new Controller();

class CustomList extends React.Component {
  url(){ return `/custom?name=${encodeURIComponent(this.props.name)}` }
  render(){
    return <Link to={this.url()}>{this.props.name}</Link>
  }
}

class Recommend extends React.Component {
  render(){
    return <span>
    {!!localStorage.user_id ?  <Link to={`/recommend?name=${localStorage.user_id}`}><b>Recommend</b></Link> : null}
    </span>
  }
}


export default class SearchBox extends React.Component {
  submit(event){
    event.preventDefault();
    var query = this.refs.input.value;
    var url = `/?query=${encodeURIComponent(query)}`;
    browserHistory.push(url);
  }
  click(e){ this.props.state.open(e.target.dataset.url); }

  componentDidUpdate(){
    var query = this.query();
    if(query == 'undefined' || query == 'null' || !query){query = ''}
    this.refs.input.value = query;
  }

  change(){ }
  query(){ return decodeURIComponent(controller.query()) }

  render(){
    var query = this.query();
    if(query == 'undefined' || query == 'null' || !query){query = ''}
    var c_list = jQuery.map(custom_list.data, (v,k)=>{return <CustomList key={k} name={k} state={this.props.state}/>});
    return <form onSubmit={(e)=> this.submit(e)}>
      <input ref='input' defaultValue={query} onChange={()=>{this.change()}}/><button>Search</button>
      <Link to='/latest'>Latest</Link>
      <Link to='/config'>Config</Link>
      <Recommend state={this.props.state} />
      <br />
      {c_list}
      </form>
  }
}
