class EventDispatcher {
  constructor(){
    this.listeners = {};
  }

  addEventListener(type, callback){
    if (!this.listeners[type]) { this.listeners[type] = []; }
    this.listeners[type].push(callback);
  }
  clearEventListener(){ this.listeners = {}; }

  dispatchEvent(event) {
    if (this.listeners[event.type]) {
      for (var listener in this.listeners[event.type]) {
        this.listeners[event.type][listener].apply(this.listeners, arguments);
      }
    }
  }
}

window.EventDispatcher = EventDispatcher;
