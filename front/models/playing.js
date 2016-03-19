import Base from './base'
import jQuery from 'jQuery'

export default class Playing extends Base {
  set(item){
    this.item = null;
    this.dispatchEvent({type: 'updated'});
    this.item = item;
    this.dispatchEvent({type: 'updated'});
  }
}
