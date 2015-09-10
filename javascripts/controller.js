class Controller {
  route(){
    var query =this.params().query; 
    var result = {}
    switch(location.pathname){
      case "/":
        result.page = "list";
        if(!!query){
          result.api_url = `/api/r/search?query=${query}`
        } else {
          result.api_url = null;
        }
        break;

      case "/latest":
        result.page = "list";
        result.api_url = '/api/r/latest';
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
}

window.Controller = Controller;
