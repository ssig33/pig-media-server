watch = (link)->
  $link = $(link)
  key = $(link).attr 'key'
  url = $("##{key} .main_link").attr('href')
  title = $(link).attr 'title'
  srt = false
  srt = true if $link.attr('srt') == 'true'
  $link.click ->
    $('#area').html('')
    $('#area').css 'min-height', 0
    width = $('body').width()
    $('<video>').attr(id: 'play', src: url, key: key, controls: 'controles').css('width', '98%').css('max-height', '98%').appendTo('#area')
    $('<br>').appendTo('#area')
    $('<a href="javascript:void(0)">Gyazo</a>').click(-> gyazo()).appendTo('#area')
    $('<span>&nbsp;&nbsp;&nbsp;</span>').appendTo('#area')
    $('<a>close video</a>').attr('href', 'javascript:void(0)').click(->
      $('#area').html('')
      $('#area').css 'min-height', 0
    ).appendTo('#area')
    $('<span>&nbsp;&nbsp;&nbsp;</span>').appendTo('#area')
    $('<a>').attr(href: 'javascript:void(0)').text('No Controls').click(->
      if $('video').attr('controls')
        $('video').removeAttr 'controls'
        $(this).text('Controls')
      else
        $('video').attr 'controls', 'c'
        $(this).text('No Controls')
    ).appendTo('#area')
    if srt
      $('video').append(
        $('<track default>').attr(src: "/webvtt/#{key}", srclang: "en", kind: "subtitles", label: "Subtitles")
      )
    $('<span>&nbsp;&nbsp;&nbsp;</span>').appendTo('#area')
    $('<span>').text('Rate:').appendTo('#area')
    $('<input>').attr('id', 'playback_rate').appendTo('#area').val(1).attr('size',2)
    $('<span>').html('<br> Now Playing : '+title).appendTo('#area')
    $('<div>').attr('class', 'space').appendTo('#area')
    video = document.querySelector '#play'
    video.load()
    video.addEventListener('canplay', (e)->
      e.target.play()
      $('video').removeAttr 'controls'
      $('video').attr 'controls', 'c'
      window.get_recents (recents)->
        recents['movie/'+key] = {time: parseInt((new Date)/1000), type: 'movie'}
        window.save_recents recents
        $('.new_flag').text('')
        $('.main_span').attr('data-new': '')
        unless $('#action').text() == 'remote'
          setTimeout ->
            window.set_new()
          ,2000
      playback_rate_loop()
    )

window.watch_movie = watch

playback_rate_loop = ->
  setTimeout ->
    v = $('video').get(0)
    if v
      v.playbackRate = parseFloat($('#playback_rate').val())
      playback_rate_loop()
  ,200

initialize_movie = ->
  $.each $('a.watch'), -> watch(this)

movie_size = (origin_height)->
  setTimeout ->
    if $('#play').length > 0
      space_height = parseInt(($('#area').height() - $('#play').height())/4)
      space_height = space_height *2
      if origin_height != space_height
        $('#area').css 'min-height', $(window).height()
        $('.space').css 'height', space_height if space_height != origin_height
        origin_height = space_height
    movie_size(origin_height)
  , 20

gyazo = ->
  c = document.querySelector '#canvas'
  v = document.querySelector '#play'
  context = c.getContext '2d'
  c.width = v.videoWidth
  c.height = v.videoHeight
  context.drawImage(v, 0, 0)
  url = c.toDataURL()
  $.post('/gyazo', {url: url, point: localStorage.gyazo}).success((data)->
    window.open(data.url, "", "width=500,height=400")
    copyArea = $("<textarea/>")
    copyArea.text(data.url)
    $("body").append(copyArea)
    copyArea.select()
    document.execCommand("copy")
    copyArea.remove()
  )

next_loop = ->
  setTimeout ->
    if $('video')[0]
      v = document.querySelector 'video'
      if v.currentTime== v.duration
        key = $(v).attr 'key'
        keys = $.map($('.watch'), (n,i)-> $(n).attr('key'))
        index = keys.indexOf key
        next = keys[index-1]
        if next
          $('.watch[key="'+next+'"]').click()
        else
          next = keys[keys.length-1]
          $('.watch[key="'+next+'"]').click()
    next_loop()
  ,200

seek = (count)->
  node = document.querySelector '#play'
  node.currentTime = node.currentTime + count

pause = ->
  node = document.querySelector '#play'
  if node.paused
    node.play()
  else
    node.pause()

key_func_j = ->
  seek (15) if $('video')[0]

key_func_k = ->
  seek (-15) if $('video')[0]

key_func_g = ->
  gyazo() if $('video')[0]

key_func_p = ->
  pause() if $('video')[0]

remote = ->
  $('a.remote').click ->
    save_to_pig remote_key: $(this).attr('key')


$ ->
  initialize_movie() if $('#action').text() == 'list' or $('#action').text() == 'others'
  next_loop()
  movie_size(0)
  remote()
  $(window).keyup (e)->
    switch e.keyCode
      when 74
        key_func_j()
      when 75
        key_func_k()
      when 80
        key_func_p()
      when 71
        key_func_g()

# vim: set ft=coffee:
