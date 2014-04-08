save = ->
  localStorage.gyazo = $('#gyazo').val()
  if $('#kindle_to').get(0)
    save_to_pig('kindle_to', $('#kindle_to').val())
    save_to_pig('kindle_from', $('#kindle_from').val())
    save_to_pig('token_secret', $('#token_secret').val())
    save_to_pig('token', $('#token').val())
    save_to_pig('consumer_secret', $('#consumer_secret').val())
    save_to_pig('consumer_key', $('#consumer_key').val())
    save_to_pig('remote', $('#remote').prop('checked'))


$ ->
  if localStorage.gyazo == undefined
    localStorage.gyazo = 'http://gyazo.com/upload.cgi'
  $('#gyazo').val(localStorage.gyazo)

  $('#save').click -> save()

  get_from_pig('kindle_to', (data)-> $('#kindle_to').val(data))
  get_from_pig('kindle_from', (data)-> $('#kindle_from').val(data))
  get_from_pig('consumer_key', (data)-> $('#consumer_key').val(data))
  get_from_pig('consumer_secret', (data)-> $('#consumer_secret').val(data))
  get_from_pig('token', (data)-> $('#token').val(data))
  get_from_pig('token_secret', (data)-> $('#token_secret').val(data))

