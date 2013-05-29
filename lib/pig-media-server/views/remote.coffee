remote_loop = (original)->
  get_from_pig 'remote_key', (key)->
    if original != key
      if key == '' or key == undefined
        $('#area').html ''
        setTimeout ->
          remote_loop(key)
        , 2000

      else
        $.get('/remote', key: key).success((data)->
          $('#link').html(data)
          watch_movie($('a.watch').get(0))
          $('a.watch').click()
          setTimeout ->
            remote_loop(key)
          , 2000
        )
    else
      setTimeout ->
        remote_loop(key)
      , 2000
$ ->
  remote_loop('')
# vim: set ft=coffee:
