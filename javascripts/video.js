class Video{
  constructor(app){
    this.app = app;
  }

  set(item){
    this.app.state.video = item;
    this.app.update_state();
  }
}

window.Video = Video;
