class Recent {
  constructor(app){
    this.app = app;
  }

  login(){ return !!this.app.state.session.user_id }

  load(){
    if(this.login()){
      var dd = new Date();
      $.get('/recents', {stamp: dd.getTime()}).done((data)=>{
        this.app.state.recents = data;
        this.app.update_state();
      });
    } else {
    }
  }

  use(key){
    if(this.login()){
      var dd = new Date();
      $.get('/recents', {stamp: dd.getTime()}).done((recents)=>{
        recents[key] = {time: parseInt((new Date)/1000), type: 'movie'}
        $.post("/recents", {data: JSON.stringify(recents)});
        this.app.state.recents = recents;
        this.app.update_state();
      });
    } else {
      console.log("kotti");
    }
  }
}

window.Recent = Recent;
