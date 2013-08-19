flv = (link)->
  $link = $(link)
  key = $(link).attr 'key'
  url = $("##{key} .main_link").attr('href')
  $link.click ->
    $('#area').html('')
    $('#area').css 'min-height', 0
    width = $('body').width()
    $('<embed>').attr(src: "/OSplayer.swf?movie=#{url}&autoload=on&autoplay=on&volume=200", allowFullScreen: true, type: 'application/x-shockwave-flash', width: '800', height: 600).appendTo('#area')
    $('<br>').appendTo('#area')
    $('<a>close video</a>').attr('href', 'javascript:void(0)').click(->
      $('#area').html('')
      $('#area').css 'min-height', 0
    ).appendTo('#area')
        
    window.get_recents (recents)->
      recents['movie/'+key] = {time: parseInt((new Date)/1000), type: 'movie'}
      window.save_recents recents
      $('.new_flag').text('')
      $('.main_span').attr('data-new': '')
      unless $('#action').text() == 'remote'
        setTimeout ->
          window.set_new()
        ,2000

window.watch_flv = flv

initialize_flv = ->
  $.each $('a.flv'), -> flv(this)

$ ->
  initialize_flv() if $('#action').text() == 'list' or $('#action').text() == 'others'

