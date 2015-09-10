window.React = require('react');
window.$ = window.jQuery = require('jquery');

require('./components/head.js');

class Controller {
  route(){
    var result = {}
    switch(location.pathname){
      case "/":
        result.page = "list";
        result.api_url = null;
        break;

      case "/latest":
        result.page = "list";
        result.api_url = '/api/r/latest';
        break;

    }
    return result;
  }

  params(){
    var arg  = new Object;
    var pair = location.search.substring(1).split('&');
    for(var i=0; pair[i]; i++) {
      var kv = pair[i].split('=');
      arg[kv[0]] = kv[1];
    }
    return arg;
  }
}



class SearchBox extends React.Component {
  render(){
    return <form>
      <input /><button>Search</button>
      <a href='/latest'>Latest</a>
      <a href='/config'>Config</a>
    </form>
  }
}

class Application extends React.Component {
  constructor(props){
    super(props);
    this.controller = new Controller();

    this.state = {
      config: {},
      session: {},
    }
  }

  componentDidMount(){
    $.get("/api/r/config").done((data)=>{ this.state.config = data; this.update_state(); })
    $.get("/api/r/session").done((data)=>{ this.state.session = data; this.update_state(); })
    console.log(this.controller.route().api_url);
  }

  update_state(){ this.setState(this.state); }

  render(){
    
    return <div>
      <div id='all'>
        <Head state={this.state} />
        <SearchBox state={this.state}/>
      </div>
    </div>
  }
}

React.render(<Application />, document.querySelector("#application"));

