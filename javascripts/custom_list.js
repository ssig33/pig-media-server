class CustomList {
  constructor(app){
    this.app = app;
    this.list = []
  }
  load(){
    $.get('/api/r/custom_list').done((data)=>{
      this.list = data;
      this.app.update_state();
    });
  }
}

window.CustomList = CustomList;
