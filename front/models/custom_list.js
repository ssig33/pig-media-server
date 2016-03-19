import Base from './base'
import jQuery from 'jQuery'

export default class CustomList  extends Base {
  constructor(){ super(); this.list = [] }
  load(){
    jQuery.get("/api/r/custom_list").done((data)=>{ 
      this.data = data;
      this.dispatchEvent({type: 'loaded'});
    })
  }
}
