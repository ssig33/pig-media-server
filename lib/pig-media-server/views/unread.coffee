window.set_new = ->
  window.get_recents (recents)->
    count = 0
    $.each $('.new_flag'), ->
      key = this.getAttribute 'key'
      unless recents[key]
        $(this).text 'New!'
        count += 1
    if count == 0
      $('.main_link').css('margin-left', '0')

$ ->
  set_new()

