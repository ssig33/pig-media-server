import React from 'react';
import Search from './search'

import QueryList from './query_list'

class Top extends React.Component {
  render(){
    return <div>
      <QueryList query={this.props.query}/>
    </div>
  }
}

export default class Index extends React.Component {
  is_search(){
    return !!this.props.location.query.query;
  }
  render(){
    return <div>
      {this.is_search() ? <Search location={this.props.location}/> : <Top query={this.props.location.query}/> }
    </div>
  }
}
