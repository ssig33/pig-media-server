class LoginAs extends React.Component {
  render(){
    return <span>Login as {this.props.user_id}</span>
  }
}

class LoginLink extends React.Component {
  render(){
    return <a href='/sessions'>Login</a>
  }
}

class Session extends React.Component {
  render(){
    return <div>
      {this.props.state.session.user_id ? 
        <LoginAs user_id={this.props.state.session.user_id} /> :
        <LoginLink />
      }
    </div>
  }
}

class Head extends React.Component {
  click(){
    this.props.state.open('/'); 
  }
  render(){
    return <div>
      <Session state={this.props.state} />
      <h2>
        <a href='javascript:void(0)' onClick={()=> this.click()}>
          {this.props.state.config.page_title}
        </a>
      </h2>
    </div>
  }
}

class CustomList extends React.Component{
  click(){
    this.props.state.open(`/custom?name=${encodeURIComponent(this.props.name)}`)
  }
  render(){
    return <a href='javascript:void(0)' onClick={()=> this.click()}>{this.props.name}</a>
  }
}

class SearchBox extends React.Component {
  submit(event){
    event.preventDefault();
    var query = this.refs.input.value;
    var url = `/?query=${encodeURIComponent(query)}`
    history.pushState(url, '', url);
    this.props.state.initialize();
  }
  click(e){ this.props.state.open(e.target.dataset.url); }

  full_screen(){
    var elem = document.querySelector("body");
    if (elem.requestFullScreen) {
      elem.requestFullScreen();
    } else if (elem.mozRequestFullScreen) {
      elem.mozRequestFullScreen();
    } else if (elem.webkitRequestFullScreen) {
      elem.webkitRequestFullScreen();
    }
  }

  componentDidUpdate(){
    var query = decodeURIComponent(this.props.state.controller.query());
    if(query == 'undefined' || query == 'null' || !query){query = ''}
    this.refs.input.value = query;
  }



  change(){ }

  render(){
    var query = decodeURIComponent(this.props.state.controller.query());
    if(query == 'undefined' || query == 'null' || !query){query = ''}
    var custom_list = $.map(this.props.state.models.custom_list.list, (v,k)=>{return <CustomList key={k} name={k} state={this.props.state}/>});
    return <form onSubmit={(e)=> this.submit(e)}>
      <input ref='input' defaultValue={query} onChange={()=>{this.change()}}/><button>Search</button>
      <a href='javascript:void(0)' onClick={(e)=>this.click(e)} data-url='/latest'>Latest</a>
      <a href='/config'>Config</a>
      <a href='javascript:void(0)' onClick={()=> this.full_screen()}>Full Screen</a>
      {custom_list}
    </form>
  }
}

window.Head = Head;
window.SearchBox = SearchBox;
