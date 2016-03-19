import Base from './base'
import jQuery from 'jquery'

export default class LatestList extends Base {
  constructor(){ super(); this.list = []; }

  load(page){
    jQuery.get('/api/r/latest', {page: page}).done((data)=>{ 
      this.list = data;
      this.dispatchEvent({type: 'loaded'});
    }); 
  }

  paginate(page){
    jQuery.get('/api/r/latest', {page: page}).done((data)=>{ 
      this.list = this.list.concat(data);
      this.dispatchEvent({type: 'loaded'});
    }); 
  }
}
