import Base from './base'
import jQuery from 'jQuery'

export default class Session extends Base {
  constructor(){ super(); this.data = {} }
  load(){
    jQuery.get("/api/r/session").done((data)=>{ 
      this.data = data;
      this.dispatchEvent({type: 'loaded'});
    })
  }

  login(){
    return !!this.data.user_id
  }
}
