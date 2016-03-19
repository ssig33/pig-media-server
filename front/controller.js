export default class Controller {
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

  can_sort_and_paging(){
    if(location.pathname == '/'){
      return !!this.query();
    } else {
      return false;
    }
  }
}

