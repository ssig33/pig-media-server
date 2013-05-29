window.get_recents = (func)->
  if $('#user_id').text() and $('#user_id').text() != ''
    dd = new Date()
    $.get('/hash', stamp: dd.getTime()).success((data)->
      if data['recents']
        func data['recents']
      else
        func {}
    )
  else
    try
      recents = JSON.parse window.localStorage['recents']
    catch error
      recents = {}
    func(recents)

window.save_recents = (recents)->
  if $('#user_id').text() and $('#user_id').text() != ''
    $.get('/hash').success((data)->
      data['recents'] = recents
      $.post('/hash', json: JSON.stringify(data))
    )
    
  else
    window.localStorage['recents'] = JSON.stringify recents

window.save_to_pig = (hash)->
  $.get('/hash').success((data)->
    data = $.extend data, hash
    $.post('/hash', json: JSON.stringify(data)))
window.get_from_pig = (key, func)-> $.get('/hash').success((data)-> func(data[key]))

