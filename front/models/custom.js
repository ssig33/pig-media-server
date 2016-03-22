import Base from './base'

export default class CustomList extends Base {
  constructor(){ super(); this.list = []; }

  load(user_id){
    jQuery.get('/api/r/custom', {name: user_id}).done((data)=>{ 
      this.list = data;
      this.dispatchEvent({type: 'loaded'});
      this.external_fetch(user_id);
    }).fail(()=> this.external_fetch(user_id)); 
  }

  external_fetch(name){
    if(!!config.data.external_pigs){
      config.data.external_pigs.forEach((e,i)=>{
        if(e.method.indexOf('custom') > 0){
          var query = {};
          query.i = i;
          query.method = 'custom';
          query.name = name;
          jQuery.get('/api/r/external',query).done((data)=>{
            this.list = this.list.concat(data);
            this.dispatchEvent({type: 'loaded'});
          });
        }
      });
    }
  }

}
