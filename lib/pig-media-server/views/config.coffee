save = -> localStorage.gyazo = $('#gyazo').val()

$ ->
  if localStorage.gyazo == undefined
    localStorage.gyazo = 'http://gyazo.com/upload.cgi'
  $('#gyazo').val(localStorage.gyazo)

  $('#save').click -> save()
