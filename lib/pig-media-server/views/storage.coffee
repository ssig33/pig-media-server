window.get_recents = (func)->
  if $('#user_id').text() and $('#user_id').text() != ''
    dd = new Date()
    $.get('/recents', stamp: dd.getTime()).success((data)-> func data)
  else
    try
      recents = JSON.parse window.localStorage['recents']
    catch error
      recents = {}
    func(recents)

window.save_recents = (recents)->
  if $('#user_id').text() and $('#user_id').text() != ''
    $.post("/recents", data: JSON.stringify(recents))
  else
    window.localStorage['recents'] = JSON.stringify recents

window.save_to_pig = (key, value)->
  $.post('/data', key: key, value: value)
window.get_from_pig = (key, func)-> $.get('/data', key: key).success((data)-> func(data))

