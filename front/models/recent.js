import Base from './base'
import jQuery from 'jQuery'

export default class Recent extends Base {
  constructor(){
    super();
    session.addEventListener('loaded', ()=>{this.load()});

    this.data = {}
  }

  load(){
    if(session.login()){
      var dd = new Date();
      jQuery.get('/recents', {stamp: dd.getTime()}).done((data)=>{
        this.data = data;
        this.dispatchEvent({type: 'loaded'});
      });
    }
  }

  use(key){
    if(session.login()){
      var dd = new Date();
      jQuery.get('/recents', {stamp: dd.getTime()}).done((recents)=>{
        recents[key] = {time: parseInt((new Date)/1000), type: 'movie'}
        jQuery.post("/recents", {data: JSON.stringify(recents)});
        this.data = recents;
        this.dispatchEvent({type: 'loaded'});
      });
    } else {
    }
  }
}
