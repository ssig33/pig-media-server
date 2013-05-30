shot = (index, targets, complete)->
  t = targets[index]
  if t == undefined
    $.post('/api/save', name: "sub/caps/#{$('#key').text()}", body: JSON.stringify(complete)).success ->
      $.post('/api/save', name:"sub/exist_cap/#{$('#key').text()}", body: 'true').success ->
        location.reload()
  else
    i = ~~(parseInt($(t).attr('start'))/1000)
    $.post('/api/capapi', key: $('#key').text(), time: i).success((data)->
      complete[$(t).attr('id')] = data
      $('.control').text "#{index} / #{targets.length}"
      shot index+1, targets, complete
    ).error(->
      setTimeout ->
        shot index, targets, complete
      ,500
    )
create_cap = ->
  c = 0
  targets = []
  $.each $('.srt_line'), (i,n)->
    if i == 0
      targets.push n
      c = parseInt($(n).attr('start')) + 15*1000
    else if i == ($('.srt_line').length-1)
      targets.push n
    else
      if c <= parseInt($(n).attr('start'))
        targets.push n
        c = parseInt($(n).attr('start')) + 15*1000
  shot(0, targets, {})
  true
    
$ ->
  for n in $('.srt p')
    start = $($(n).text().split('\n')[1].split(' ')).filter(-> this.length != 0)[0]
    milli = parseInt start.split(',')[1], 10
    hour = parseInt start.split(',')[0].split(':')[0], 10
    min = parseInt start.split(',')[0].split(':')[1], 10
    sec = parseInt start.split(',')[0].split(':')[2], 10
    start_i = hour*60*60*1000 + min*60*1000 + sec*1000 + milli
    $(n).attr start: start_i, id: "start_#{start_i}", class: 'srt_line'
  $.get('/api/get', name: "sub/exist_cap/#{$('#key').text()}").success (data)->
    if data.match /true/
      sub_view()
    else
      $('<button>').text('Create Capture').attr(
        id: 'cap'
      ).appendTo('.control').click(-> create_cap()).css('cursor','pointer')
  
