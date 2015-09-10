window.React = require('react');
window.$ = window.jQuery = require('jquery');
window.moment = require('moment');

require('./utils.js');
require('./controller.js');

require('./recent.js');
require('./video.js');

require('./components/head.js');
require('./components/list.js');
require('./components/new_flag.js');
require('./components/watch.js');
require('./components/player.js');


class Application extends React.Component {
  constructor(props){
    super(props);
    this.controller = new Controller();
    this.recent = new Recent(this);
    this.video = new Video(this);

    this.state = {
      config: {},
      session: {},
      items: {}, 
      recent: {},
      video: null,

      set_video: (item)=>{this.video.set(item)},
      initialize: ()=>{this.initialize()},

      models: {video: this.video, recent: this.recent}
    }
  }
  update_state(){ this.setState(this.state); }

  load_from_api(url){ if(!!url){ $.get(url).done((data)=>{ this.state.items = data; this.update_state(); }); } }

  load_config(){ $.get("/api/r/config").done((data)=>{ this.state.config = data; this.update_state(); })}
  load_session(){ 
    $.get("/api/r/session").done((data)=>{ 
      this.state.session = data; 
      this.update_state(); 
      this.load_recent();
    }) 
  }

  load_recent(){ this.recent.load() }

  routing(){
    var route = this.controller.route();
    switch(route.page){
      case "list":
        this.load_from_api(this.controller.route().api_url);
        this.state.active_page = 'list';
        this.update_state();
        break;
    }
  }

  initialize(){
    this.load_config();
    this.load_session();
    this.routing()
  }
  
  componentDidMount(){ this.initialize() }

  render(){
    return <div>
      <div id='all'>
        <Player state={this.state} />
        <Head state={this.state} />
        <SearchBox state={this.state}/>
        <List state={this.state}/>
      </div>
    </div>
  }
}

React.render(<Application />, document.querySelector("#application"));

window.addEventListener('popstate',function(ev){ location.reload(); },false);

