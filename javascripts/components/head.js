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
  render(){
    return <div>
      <Session state={this.props.state} />
      <h1>{this.props.state.config.page_title}</h1>
    </div>
  }
}

class SearchBox extends React.Component {
  submit(event){
    event.preventDefault();
    var query = this.refs.input.getDOMNode().value;
    history.pushState('', '', `/?query=${encodeURIComponent(query)}`);
    this.props.state.initialize();
  }
  render(){
    return <form onSubmit={(e)=> this.submit(e)}>
      <input ref='input'/><button>Search</button>
      <a href='/latest'>Latest</a>
      <a href='/config'>Config</a>
    </form>
  }
}

window.Head = Head;
window.SearchBox = SearchBox;
