import Base from './base'

export default class RecommendList extends Base {
  constructor(){ super(); this.list = []; }

  load(user_id){
    jQuery.get('/api/r/recommend', {name: user_id}).done((data)=>{ 
      this.list = data;
      this.dispatchEvent({type: 'loaded'});
    }); 
  }

}
