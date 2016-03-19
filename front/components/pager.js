import React from 'react'
import jQuery from 'jquery'
import {browserHistory} from 'react-router'

export default class Pager extends React.Component {
  constructor(props){
    super(props);
    this.page = 1;
    var page = this.props.location.query.page;
    if(page){ this.page = parseInt(page)}
    this.bind();
  }

  bind(){
    //this.click();
  }
  prev(){
    var params = this.props.location.query;
    var page = this.props.location.query.page;
    if(page){ this.page = parseInt(page)}
    page = page - 1;
    if(page < 1){page = 1}
    params.page = page;
    browserHistory.push("/?"+jQuery.param(params));
  }
  click(){
    this.page ++;
    var params = this.props.location.query;
    params.page = this.page;
    this.props.list.paginate(this.page);
    history.pushState('', '', "/?"+jQuery.param(params));
  }

  render(){ return <span>
    {(this.page > 1) ?  <a href='javascript:void(0)' onClick={()=> this.prev()}>Prev</a> : null } <a href='javascript:void(0)' onClick={()=> this.click()}>Next</a> 
    </span>
  }
}
