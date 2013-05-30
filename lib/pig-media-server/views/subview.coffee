ps = null
ids = []
mode = 'eroge'
current = null

eroge_next = ->
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

eroge_prev = ->
  if current == null or current ==undefined
    current = ps[0]
  else
    current = ps[ids.indexOf($(current).attr('id'))-1]
  if $(current).find('img').length != 0
    $('html, body').animate {scrollTop: $(current).offset().top}, 'fast'
  $(current).css display: 'block'


window.sub_view = ->
  for n in $('.srt_line')
    a = $(n).html().split('<br>')
    a.splice(0, 1)
    $(n).html a.join('<br>')
  $.get('/api/get', name: "sub/caps/#{$('#key').text()}").success (data)->
    caps = JSON.parse(data)
    $.each caps, (i,n)->
      $("##{i}").before $('<p>').append($('<img>').attr(src: n)).attr(class: 'srt_image', id: "image_#{i}")
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
$ ->
  $(document).on('click', '.srt_image', -> eroge_next()).css('cursor','pointer')
  #$(document).on('touchend', '.srt_image', -> eroge_next())

