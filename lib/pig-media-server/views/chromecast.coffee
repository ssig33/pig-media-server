currentMedia = null
currentVolume = 0.5
progressFlag = 1
mediaCurrentTime = 0
session = null

null_func = (obj)-> ''

sessionListener = (e)->
  console.log('New session ID: ' + e.sessionId)
  session = e

onRequestSessionSuccess = (e)->
  console.log("session success: " + e.sessionId)
  session = e
  onMediaDiscovered('onRequestSession', session.media[0]) if (session.media.length != 0)
  session.addMediaListener(
    onMediaDiscovered.bind(this, 'addMediaListener'))

onMediaDiscovered = (how, media)->
  console.log("new media session ID:" + media.mediaSessionId)
  currentMedia = media
  mediaCurrentTime = currentMedia.currentTime

initializeCastApi = ->
  sessionRequest = new chrome.cast.SessionRequest(chrome.cast.media.DEFAULT_MEDIA_RECEIVER_APP_ID)
  apiConfig = new chrome.cast.ApiConfig(sessionRequest, sessionListener, null_func)
  chrome.cast.initialize(apiConfig, null_func, null_func)
  
  console.log("launching app...")
  chrome.cast.requestSession(onRequestSessionSuccess, null_func)
  $('a.chromecast').show()
  
window.chrome_cast = (mediaURL, key)->
  mediaInfo = new chrome.cast.media.MediaInfo(mediaURL)
  mediaInfo.contentType = 'video/mp4'
  request = new chrome.cast.media.LoadRequest(mediaInfo)
  request.autoplay = true
  request.currentTime = 0
  session.loadMedia(request, onMediaDiscovered.bind(this, 'loadMedia'), null_func)

  get_recents (recents)->
    recents["movie/#{key}"] = {time: parseInt((new Date)/1000), type: 'movie'}
    window.save_recents recents
    $('.new_flag').text('')
    $('.main_span').attr('data-new': '')
    unless $('#action').text() == 'remote'
      setTimeout ->
        window.set_new()
      ,2000

window['__onGCastApiAvailable'] = (loaded, errorInfo)->
  if loaded
    initializeCastApi()
