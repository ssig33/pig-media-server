var currentMedia = null;
var currentVolume = 0.5;
var progressFlag = 1;
var mediaCurrentTime = 0;
var session = null;

var null_func = (obj)=>{''}

var sessionListener = (e)=>{
  console.log('New session ID: ' + e.sessionId)
  session = e
}

var onRequestSessionSuccess = (e)=>{
  console.log("session success: " + e.sessionId)
  session = e
  if(session.media.length != 0){
    onMediaDiscovered('onRequestSession', session.media[0]) 
  }
  session.addMediaListener(
    onMediaDiscovered.bind(this, 'addMediaListener'))
}

var onMediaDiscovered = (how, media)=>{
  console.log("new media session ID:" + media.mediaSessionId)
  currentMedia = media
  mediaCurrentTime = currentMedia.currentTime
}

var initializeCastApi = ()=>{
  var sessionRequest = new chrome.cast.SessionRequest(chrome.cast.media.DEFAULT_MEDIA_RECEIVER_APP_ID)
  var apiConfig = new chrome.cast.ApiConfig(sessionRequest, sessionListener, null_func)
  chrome.cast.initialize(apiConfig, null_func, null_func)
  
  console.log("launching app...")
  chrome.cast.requestSession(onRequestSessionSuccess, null_func)
  $('a.chromecast').show()
}
  
window.chrome_cast = (mediaURL, key)=>{
  if(mediaURL.match(/pig.ssig33.com/)){
    mediaURL = mediaURL.replace(/pig.ssig33.com\/volume/, 'ashare.ssig33.com');
    mediaURL = mediaURL.replace(/https/, 'http');
    console.log(mediaURL);
  }
  var mediaInfo = new chrome.cast.media.MediaInfo(mediaURL)
  mediaInfo.contentType = 'video/mp4'
  var request = new chrome.cast.media.LoadRequest(mediaInfo)
  request.autoplay = true
  request.currentTime = 0
  session.loadMedia(request, onMediaDiscovered.bind(this, 'loadMedia'), null_func)
}

window['__onGCastApiAvailable'] = (loaded, errorInfo)=>{
  if(loaded){ initializeCastApi() }
}
