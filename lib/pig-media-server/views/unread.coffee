window.set_new = ->
  window.get_recents (recents)->
    count = 0
    $.each $('.new_flag'), ->
      key = this.getAttribute 'key'
      unless recents[key]
        $(this).text 'New!'
        $(this).parent().attr('data-new': true)
        $(this).click ->
          $node = $(this)
          window.get_recents (recents)->
            recents[$node.attr('key')] = {time: 0, type: 'movie'}
            window.save_recents(recents)
            setTimeout ->
              $('.new_flag').text('')
              $('.main_span').attr('data-new': '')
              window.set_new()
            , 1000
        count += 1
    if count == 0
      $('.main_link').css('margin-left', '0')

$ ->
  set_new()
  $('#only-new').click ->
    if $(this).attr('now') == 'only'
      for n in $('.main_span')
        $(n).attr 'style', ''
      $(this).removeAttr 'now'
      $(this).text 'Only New'
    else
      for n in $('.main_span')
        $(n).attr 'style', 'display:none !important' if n.dataset.new == undefined
      $(this).text 'All'
      $(this).attr 'now', 'only'

