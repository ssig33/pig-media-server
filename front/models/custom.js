import Base from './base'

export default class CustomList extends Base {
  constructor(){ super(); this.list = []; }

  load(user_id){
    jQuery.get('/api/r/custom', {name: user_id}).done((data)=>{ 
      this.list = data;
      this.dispatchEvent({type: 'loaded'});
    }); 
  }

}
