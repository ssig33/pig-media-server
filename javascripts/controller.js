class Controller {
  route(){
    var query =this.params().query; 
    var result = {}
    switch(location.pathname){
      case "/":
        result.page = "list";
        if(!!query){
          result.api_url = `/api/r/search?query=${query}`
          if(!!this.params().sort){ result.api_url += `&sort=${this.params().sort}` }
          if(!!this.params().order){ result.api_url += `&order=${this.params().order}` }
        } else {
          result.api_url = null;
        }
        break;

      case "/latest":
        result.page = "list";
        result.api_url = '/api/r/latest';
        break;
      case "/custom":
        result.page = "list";
        result.api_url = `/api/r/custom?name=${this.params().name}`;
        break;
    }
    return result;
  }

  params(){
    var arg  = new Object;
    var pair = location.search.substring(1).split('&');
    for(var i=0; pair[i]; i++) {
      var kv = pair[i].split('=');
      arg[kv[0]] = kv[1];
    }
    return arg;
  }

  query(){ return this.params().query; }
}

window.Controller = Controller;
