import Base from './base'
import jQuery from 'jquery'

export default class Config  extends Base {
  constructor(){ super(); this.data = {} }
  load(){
    jQuery.get("/api/r/config").done((data)=>{ 
      this.data = data;
      this.dispatchEvent({type: 'loaded'});
    })
  }
}
