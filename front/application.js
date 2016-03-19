import React from 'react';
import ReactDOM from 'react-dom';
import { Router, Route, Link, browserHistory, IndexRoute } from 'react-router'

require('./chromecast.js');

import NoMatch from './components/no_match'
import Index from './components/index'
import Player from './components/player'
import SearchBox from './components/search_box'
import Head from './components/head'
import Latest from './components/latest'
import Recommend from './components/recommend'

import Config from './models/config'
import Session from './models/session'
import Recent from './models/recent'
import Playing from './models/playing'
import CustomList from './models/custom_list'

window.config = new Config();
window.session = new Session();
window.recent = new Recent();
window.custom_list = new CustomList();

window.playing = new Playing();

config.load();
session.load();
recent.load();
custom_list.load();

class Application extends React.Component{
  constructor(props){
    super(props);
    this.state = {}
    config.addEventListener('loaded', ()=>{ this.reload() });
    session.addEventListener('loaded', ()=>{ this.reload() });
    recent.addEventListener('loaded', ()=>{ this.reload() });
    playing.addEventListener('updated', ()=>{ this.reload() });

  }
  reload(){ 
    this.setState(this.state); 
  }
  render(){
    return <div>
      <Player/>
      <div id='all'>
        <Head />
        <SearchBox/>
        {this.props.children}
      </div>
    </div>
  }
}

var route = <Router history={browserHistory}>
  <Route path="/" name='app' component={Application}>
    <IndexRoute component={Index} />
    <Route path='/recommend' component={Recommend} />
    <Route path='/latest' component={Latest} />
  </Route>
</Router>

ReactDOM.render(route, document.querySelector("#application"));



