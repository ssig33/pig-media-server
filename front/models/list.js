import Base from './base'

import Controller from '../controller'

export default class SearchList extends Base {
  constructor(){ super(); this.list = []; this.controller = new Controller();}

  search(query){
    this.query = query
      this.fetch();
  }

  paginate(page){
    var params = this.query;
    params.page = page;
    jQuery.get('/api/r/search', this.query).done((data)=>{
      this.list = this.list.concat(data);
      this.dispatchEvent({type: 'loaded'});
      this.external_fetch();
    });
  }

  fetch(){
    jQuery.get('/api/r/search', this.query).done((data)=>{
      this.list = data;
      this.dispatchEvent({type: 'loaded'});
      this.external_fetch();
    });
  }

  external_fetch(){
    if(!!config.data.external_pigs){
      config.data.external_pigs.forEach((e,i)=>{
        var query = JSON.parse(JSON.stringify(this.query));
        query.i = i;
        query.method = 'search'
        jQuery.get('/api/r/external',query).done((data)=>{
          this.list = this.list.concat(data);
          this.sort();
          this.dispatchEvent({type: 'loaded'});
        });

      });
    }
  }

  sort(){
    var params = this.controller.params();
    switch(params.sort){
      case 'name':
        this.list = this.list.sort((a,b)=>{ if(b.name > a.name){return 1}else {return -1} });
        if(params.order == 'ascending'){
          this.list = this.list.reverse();
        }
        break;
      default:
        this.list = this.list.sort((a,b)=>{ return b.mtime_to_i - a.mtime_to_i });
        if(params.order == 'ascending'){
          this.list = this.list.reverse();
        }
        break;
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
