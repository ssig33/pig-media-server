class Video extends EventDispatcher{
  set(item){
    this.item = null;
    this.dispatchEvent({type: 'videoUpdated'});
    this.item = item;
    this.dispatchEvent({type: 'videoUpdated'});
  }
}

window.Video = Video;
