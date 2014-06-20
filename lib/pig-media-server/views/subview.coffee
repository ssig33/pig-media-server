ps = null
ids = []
mode = 'eroge'
current = null

eroge_next = ->
  unless $('video').get(0)
    if current == null or  current == undefined
      current = ps[0]
    else
      current = ps[ids.indexOf($(current).attr('id'))+1]
    
    before = ps[ids.indexOf($(current).attr('id'))-1]
    if $(before).find('img').length == 0
      $(before).css display: 'none'
    if $(current).find('img').length != 0
      $('html, body').animate {scrollTop: $(current).offset().top}, 'fast'
      current = ps[ids.indexOf($(current).attr('id'))+1]
  else
    seek(15)


eroge_prev = ->
  unless $('video').get(0)
    if current == null or current ==undefined
      current = ps[0]
    else
      current = ps[ids.indexOf($(current).attr('id'))-1]
    if $(current).find('img').length != 0
      $('html, body').animate {scrollTop: $(current).offset().top}, 'fast'
    $(current).css display: 'block'
  else
    seek(-15)

seek = (count)->
  node = document.querySelector 'video'
  node.currentTime = node.currentTime + count
window.gyazo = ->
  c = document.querySelector '#canvas'
  v = document.querySelector 'video'
  context = c.getContext '2d'
  c.width = v.videoWidth
  c.height = v.videoHeight
  context.drawImage(v, 0, 0)
  url = c.toDataURL()
  $.post('/gyazo', {url: url, point: localStorage.gyazo}).success((data)->
    window.open(data.url, "", "width=500,height=400")
  )

window.tweet = ->
  c = document.querySelector '#canvas'
  v = document.querySelector 'video'
  context = c.getContext '2d'
  c.width = v.videoWidth
  c.height = v.videoHeight
  context.drawImage(v, 0, 0)
  url = c.toDataURL()
  $.post('/gyazo/tweet', {url: url}).success((data)->
    true
  )

window.tweet_with_comment = ->
  c = document.querySelector '#canvas'
  v = document.querySelector 'video'
  context = c.getContext '2d'
  c.width = v.videoWidth
  c.height = v.videoHeight
  context.drawImage(v, 0, 0)
  url = c.toDataURL()
  comment = prompt 'Tweet'
  $.post('/gyazo/tweet', {url: url, comment: comment}).success((data)->
    true
  )


video_play = (node)->
  video = $('#url').text()
  $node = $(node)
  console.log "play #{video} #{$node.attr('time')} #{$node.attr('master_id')}"
  $video = $('<video>').attr(
    src: video
    master_id: $node.attr('master_id'),
    image: $node.attr('src'),
    controls: 'controls'
    time: $node.attr('time')
  ).css('max-width': '100%', 'max-height': '100%')
  $("#p_#{$node.attr('master_id')}").html($video)
  $video = $("#p_#{$node.attr('master_id')} video")
  $video.bind('canplay', (e)->
    console.log e
    e.target.currentTime = parseFloat($(e.target).attr('time'))-5
    $(e.target).unbind('canplay')
    e.target.play()
    $('html,body').animate(scrollTop: $(e.target).offset().top)
  )
  $video.get(0).load()
  $video.click(->
    $v = $(this)
    master_id = $v.attr('master_id')
    $("#p_#{master_id}").html(
      $('<img>').attr(
        src: $v.attr('image'),
        class: 'srt_image',
        id: "image_#{master_id}",
        time: $v.attr('time'),
        master_id: master_id
      )
    )
  )
window.sub_view = ->
  for n in $('.srt_line')
    a = $(n).html().split('<br>')
    a.splice(0, 1)
    $(n).html a.join('<br>')
  $.get('/api/get', name: "sub/caps/#{$('#key').text()}").success (data)->
    caps = JSON.parse(data)
    $.each caps, (i,n)->
      time =  parseFloat(i.split('_')[1])/1000
      $("##{i}").before $('<p>').append(
        $('<img>').attr(src: n).attr(class: 'srt_image', id: "image_#{i}", time: time, master_id: i)
      ).attr(id: "p_#{i}")
    ps = document.querySelectorAll('.srt p')
    $('h3').after(
      $('<button>').text('Reset Capture').click ->
        $.post('/api/save', name: "sub/exist_cap/#{$('#key').text()}", body: 'false').success(->
          location.reload()
        )
    )
    for n in ps
      ids.push $(n).attr('id')
    $(window).keyup (e)->
      console.log e.keyCode
      switch e.keyCode
        when 74, 13
          eroge_next()
        when 75
          eroge_prev()
        when 71
          gyazo() if document.querySelector('video')
        when 84
          tweet() if document.querySelector('video')
        when  67
          tweet_with_comment() if document.querySelector('video')

$ ->
  $(document).on('click', '.srt_image', -> video_play(this)).css('cursor','pointer')
  #$(document).on('touchend', '.srt_image', -> eroge_next())
