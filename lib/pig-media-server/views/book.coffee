## coffee -csb
portlait_db = {}
this.mobile = ->
  true

this.mobile = ->
  user_agent = navigator.userAgent
  user_agent.indexOf('iPhone') > -1 or user_agent.indexOf('iPad') > -1 or user_agent.indexOf('MSIE') > -1

max_page = ->
  parseInt($("#max_page").text())-1

left = ->
  if is_left()
    prev()
  else
    next()
right = ->
  if is_left()
    next()
  else
    prev()
plus1 = ->
  open_page(now()+1)
next = ->
  if is_portlait() and $("#area2 img").attr("class") == "portlait"
    open_page(now()+2)
  else
    open_page(now()+1)
prev = ->
  if is_portlait() and $("#area2 img").attr("class") == "portlait"
    open_page(now()-2)
  else
    open_page(now()-1)

remover= (i)->
  if i >= 0
    $('#page_area_'+(i)).remove()
    remover(i-1)
open_page = (page)->
  page = 1 if is_NaN(page) or page < 1
  
  try
    recents = JSON.parse window.localStorage['recents']
  catch error
    recents = {}
  delete recents['aozora/'+_id()]
  recents['read/'+_id()] = {page: page, time: parseInt((new Date)/1000), type: 'read'}
  window.localStorage['recents'] = JSON.stringify recents
  
  if $('#action').text() == 'read'
    $("#page_jump").val(page)
    if page > max_page()
      page = max_page()
    _now(page)
    remover(page-1)
    for i in [0,1,2,3,4,5,6,7]
      unless document.querySelector('#page_area_'+(page+i))
        landscape(page+i) unless is_portlait()
        portlait(page+i) if is_portlait()

img_style = (mode)->
  if mode == "portlait"
    "max-height:"+(height()-5)+"px; max-width:"+((width()/2)-10)+"px"
  else
    "max-height:"+(height()-5)+"px; max-width:"+(width()-10)+"px"


landscape = (page)->
  $("#area2").html("<div id='page_insert'/>")
  img = "<img src='/book/image?id="+_id()+"&page="+page+"' class='landscape' style='"+img_style("")+"'/>"
  $("#page_insert").after(img)
  $("#area2 img").click(-> next())

portlait = (page)->
  if localStorage["portlait/"+_id()+"/"+page] != undefined and localStorage["portlait/"+_id()+"/"+(page+1)] != undefined
    portlait_real(page)
  else
    $.get("/book/info/"+_id()+"?page="+page).success((data)->
      localStorage["portlait/"+_id()+"/"+(page)] = data.portlait
      $.get("/book/info/"+_id()+"?page="+(page+1)).success((data)->
        localStorage["portlait/"+_id()+"/"+(page+1)] = data.portlait
        portlait_real(page)
      )
    )

portlait_real = (page) ->
  if localStorage["portlait/"+_id()+"/"+page] == 'true' or localStorage["portlait/"+_id()+"/"+(page+1)] == 'true'
    img = "<img src='/book/image?id="+_id()+"&page="+page+"' class='landscape' style='"+img_style("")+"'/>"
  else
    if is_left()
      img = "<img src='/book/image?id="+_id()+"&page="+page+"' class='portlait' style='"+img_style("portlait")+"'/>"
      img += "<img src='/book/image?id="+_id()+"&page="+(page+1)+"' class='portlait' style='"+img_style("portlait")+"'/>"
    else
      img = "<img src='/book/image?id="+_id()+"&page="+(page+1)+"' class='portlait' style='"+img_style("portlait")+"'/>"
      img += "<img src='/book/image?id="+_id()+"&page="+page+"' class='portlait' style='"+img_style("portlait")+"'/>"

  $('#area2').height(height()-5)
  img = $('<div class="img_area" id="page_area_'+page+'">'+img+'</div>')
  img.css {'z-index': 100000000-page,  position: 'absolute'}
  $("#page_insert").after(img)


size_loop = (size)->
  setTimeout ->
    unless size == undefined or window_size() == undefined
      if size.width != window_size().width or size.height != window_size().height
        size = window_size()
        $('.portlait').attr 'style', img_style('portlait')
        $('.landscape').attr 'style', img_style('landscape')
        $('#area').height(height()-5)
    size_loop(size)
  ,500

area_width_loop = (size) ->
  setTimeout ->
    unless document.querySelector('.img_area')
      area_width_loop(0)
    else
      count = $('.img_area').last().width()
      count = ($('#area2').width()-count)/2
      if size != count
        $('.img_area').css('left', count)
        area_width_loop(count)
      else
        $('.img_area').css('left', size)
        area_width_loop(size)
  , 100

portlait_loop = (i)->
  $.get("/book/info/#{_id()}", all: true).success((data)->
    for n in data
      localStorage["portlait/#{_id()}/#{i}"] = n
      i += 1
  )

change_bound = ->
  $.get("/page/change_bound/"+_id()).success(->
    if is_left()
      $("#is_left").text("")
      open_page(now())
    else
      $("#is_left").text("true")
      open_page(now())
    if is_left()
      $("#bound").text("Left Side")
    else
      $("#bound").text("Right Side")
  )

swipe_left = ->
  right()
swipe_right = ->
  left()

read = (link)->
  key = link.getAttribute 'key'
  $(link).click ->
    $('#area').html('')
    $('#area').css 'min-height', 0
    $.get('/read/'+key).success((data)->
      c = $('<a>close book</a>')
      c.attr('href', 'javascript:void(0)')
      c.click ->
        $('#area').html('')
        $('#area').css 'min-height', 0
      $(data).appendTo('#area')
      c.appendTo('#area')
      $('body').animate(0)
      if is_left()
        $("#bound").text("Left Side")
      else
        $("#bound").text("Right Side")
      $("#bound").click(-> change_bound())
      size = window_size()
      open_page(parseInt $("#page_initial").text())
      size_loop(window_size())
      area_width_loop(0)
      $("#left").click(-> left())
      $("#right").click(-> right())
      $("#plus1").click(-> plus1())
      $('#area2').css('-ms-touch-action': 'none', '-ms-user-select': 'none')
      if window.navigator.msPointerEnabled
        area_pointer = {x: 0, y: 0}
        $('#area2').get(0).addEventListener('MSPointerDown', (e)->
          area_pointer.x = e.clientX
          area_pointer.y = e.clientY
        )
        $('#area2').get(0).addEventListener('MSPointerUp', (e)->
          if area_pointer.y - e.clientY < 300
            if area_pointer.x - e.clientX > 50
              swipe_left()
            if e.clientX - area_pointer.x > 50
              swipe_right()

          area_pointer.x = 0
          area_pointer.y = 0
        )
      else
        $("#area2").swipe({swipeLeft:swipe_left, swipeRight:swipe_right, threshold:0})

      $('#area2').click -> next() #unless window.navigator.msPointerEnabled
      $("#book_list").off()
      $("#book_list").click -> open_index()
      $("#jump").click ->
        open_page(parseInt($("#page_jump").val()))
      $("#to_aozora").click ->
        id = $('#id').text()
        $.get('/aozora/'+id+"?remote=remote").success (data)->
          $('#area2').html data
          $('.control').html ''
          initialize_aozora()
      portlait_loop(1)
    ).error(-> alert('you cannot this book'))

key_queue = []

key_loop = ->
  setTimeout ->
    if key_queue.length > 0
      key = key_queue.shift()
      if $("#action").text() == "read"
        if key == 74
          next()
        else if key == 75
          prev()
    key_loop()
  ,50

initialize_read = ->
  $.each $('a.read'), -> read(this)
$ ->
  initialize_read()
  $(document).keyup((e)-> key_queue.push e.keyCode)
  key_loop()
## vim: set ft=coffee :
