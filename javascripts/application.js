window.React = require('react');
window.$ = window.jQuery = require('jquery');
window.moment = require('moment');

require('./utils.js');
require('./controller.js');

require('./recent.js');
require('./video.js');
require('./custom_list.js');

require('./components/head.js');
require('./components/sort.js');
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
    this.custom_list = new CustomList(this);

    this.state = {
      config: {},
      session: {},
      items: {}, 
      recent: {},
      video: null,

      set_video: (item)=>{this.video.set(item)},
      open: (link)=>{this.open(link)},
      initialize: ()=>{this.initialize()},

      models: {video: this.video, recent: this.recent, custom_list: this.custom_list}
    }

    window.addEventListener('popstate',(ev)=>{ this.initialize(); },false);
  }

  open(link){
    history.pushState('', '', link);
    this.initialize();
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
    this.custom_list.load();
    this.routing()
  }
  
  componentDidMount(){ this.initialize() }

  render(){
    return <div>
      <Player state={this.state} />
      <div id='all'>
        <Head state={this.state} />
        <SearchBox state={this.state}/>
        <List state={this.state}/>
      </div>
    </div>
  }
}

React.render(<Application />, document.querySelector("#application"));



