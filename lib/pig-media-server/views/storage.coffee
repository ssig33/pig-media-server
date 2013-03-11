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

