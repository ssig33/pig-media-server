class QuerySave extends React.Component{
  constructor(props){
    super(props);
    this.controller = new Controller();
  }
  
  click(){
    var query = decodeURIComponent(this.controller.query());
    $.post("/api/r/query_list", {query: query})
  }
  render(){
    return <span>
      <a href='javascript:void(0)' onClick={()=> this.click()}>Save Query</a>
    </span>
  }
}

class Sort extends React.Component{
  constructor(props){
    super(props);
    this.controller = new Controller();
  }

  sort_by_date(){
    var query = this.controller.query();
    var new_url = `/?query=${query}&sort=date&order=descending`
    history.pushState("", "", new_url);
    this.props.state.initialize();
  }

  sort_by_name(){
    var query = this.controller.query();
    var new_url = `/?query=${query}&sort=name&order=ascending`
    history.pushState("", "", new_url);
    this.props.state.initialize();
  }

  change_order(order){
    var query = this.controller.query();
    var sort = this.controller.params().sort;
    var new_url = `/?query=${query}&sort=${sort}&order=${order}`
    history.pushState("", "", new_url);
    this.props.state.initialize();

  }

  can_change_order(){ return !!this.controller.params().sort; }
  render(){
    return <p>
      <a href="javascript:void(0)" onClick={()=> this.sort_by_date()}>Sort By Date</a>
      <a href="javascript:void(0)" onClick={()=> this.sort_by_name()}>Sort By Name</a>
      {this.can_change_order() ?
        <span>
          <a href="javascript:void(0)" onClick={()=> this.change_order('ascending')}>Ascending</a>
          <a href="javascript:void(0)" onClick={()=> this.change_order('descending')}>Descending</a>
        </span>
        : null
      }
      <QuerySave />
    </p>
  }
}

window.Sort = Sort;
