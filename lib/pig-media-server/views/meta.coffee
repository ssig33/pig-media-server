## coffee -csb
$ ->
  v = $('video').get(0)
  v.addEventListener('canplay', ->
    $('#aspect').text("Aspect Rate is #{v.videoHeight/v.videoWidth}")
    if $('#aspect').text() != "Aspect Rate is 0.5625"
      $('#aspect').html(
        $('<a>').attr(href: "/change_aspect_rate/#{$('#key').text()}?rate=16:9").text("Change To 16:9")
      )
  )
  v.load()
## vim: set ft=coffee :
