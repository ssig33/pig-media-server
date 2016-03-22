import Base from './base'

import Controller from '../controller'

export default class LatestList extends Base {
  constructor(){ super(); this.list = [];  this.controller = new Controller();}

  load(page){
    jQuery.get('/api/r/latest', {page: page}).done((data)=>{
      this.list = data;
      this.dispatchEvent({type: 'loaded'});
      this.external_fetch(page);
    });
  }

  paginate(page){
    jQuery.get('/api/r/latest', {page: page}).done((data)=>{
      this.list = this.list.concat(data);
      this.dispatchEvent({type: 'loaded'});
      this.external_fetch(page);
    });
  }

  external_fetch(page){
    if(!!config.data.external_pigs){
      config.data.external_pigs.forEach((e,i)=>{
        if(e.method.indexOf('latest') > 0){
          var query = {};
          query.i = i;
          query.method = 'latest';
          query.page = page;
          jQuery.get('/api/r/external',query).done((data)=>{
            this.list = this.list.concat(data);
            this.sort();
            this.dispatchEvent({type: 'loaded'});
          });
        }
      });
    }
  }

  sort(){
    var params = this.controller.params();
    this.list = this.list.sort((a,b)=>{ return b.mtime_to_i - a.mtime_to_i });
    if(params.order == 'ascending'){
      this.list = this.list.reverse();
    }
  }

  next(){
    var index = this.list.map((e,i)=>{return e.key}).indexOf(playing.item.key);
    var item = null
    while(index > -1){
      index = index - 1;
      item = this.list[index];
      if(item.type == 'video'){break}
    }
    if(item){ playing.set(item); }
  }
}
