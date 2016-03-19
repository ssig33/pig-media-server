import React from  'react'

class Item extends React.Component {
  url(){ return `/?query=${encodeURIComponent(this.props.query)}` }

  click(){
    this.props.state.open(this.url());
  }

  delete_query(){
    if(confirm('Really?')){
      $.post("/api/r/delete_query_list", {query: this.props.query}).done((data)=>{
        this.props.update_list();
      });
    }
  }
  render(){
    return <span className='main_span'>
      <a href='javascript:void(0)' onClick={()=> this.click()}>
        {this.props.query}
      </a>
      <a href='javascript:void(0)' className='delete' onClick={()=> this.delete_query()}>
        Delete
      </a>
    </span>
  }
}

export default class QueryList extends React.Component {
  constructor(props){
    super(props);
    this.state = {};
    this.state.list = [];
  }

  update_list(){
    $.get("/api/r/query_list").done((data)=>{
      this.state.list = data;
      this.setState(this.state);
    });
  }
  
  componentDidMount(){
    this.update_list();
  }

  render(){
    var items = $.map(this.state.list, (query)=>{
      return <Item key={query} query={query} state={this.props.state} update_list={()=> this.update_list()}/>
    });
    return <div>
    {items}
    </div>
  }
}

