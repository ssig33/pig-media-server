TV = ->
  @data = []
  @list = []
  @get = =>
    $.getJSON('/tv/list').done((data)=>
      @data = data
      @bind()
      @render()
    ).fail((a,b,c)=>
      @bind()
    )

  @save = =>
    $.post('/tv/list', data: JSON.stringify(@data)).success(=> @render())

  @cast = =>
    @list = []
    $.ajaxSetup({ async: false })
    for d in @data
      $.get("/feed", query: d).success((res)=>
        for item in $(res).find('item')
          title = $(item).find('title').text()
          link = $(item).find('link').text()
          date = Date.parse $(item).find('pubDate').text()
          key = $(item).find('key').text()
          @list.push [title, link, date, key]
      )
    @list = @list.sort((a,b)->
      a[2] > b[2]
    )
    for l in @list
      @create_link(l)
    $.each $('a.watch'), -> watch(this)
    set_new()

    for n in $('.main_span')
      $(n).remove() if n.dataset.new == undefined
  @create_link = (ary)=>
    $span = $('<span>')
    $span.addClass('main_span')
    $span.attr(id: ary[3])

    $new_flag = $('<span>').addClass('new_flag')
    $new_flag.attr(key: "movie/#{ary[3]}", style: 'color:lime; font-size:large')

    $a = $('<a>')
    $a.addClass('main_link').text(ary[0]).attr(href: ary[1], key: ary[3])

    $watch = $('<a>')
    $watch.addClass('watch').text(' Watch').attr(href: 'javascript:void(0)', url: ary[1], key: ary[3], title: ary[0])

    $span.append($new_flag)
    $span.append($a)
    $span.append($watch)
    $('#list').append($span)

    
  
  @bind = =>
    $('#start').click => @cast()
    $('button').click =>
      t = $('input').val()
      unless t == ''
        @data.push t
        @save()

  @delete = ($node)=>
    d = $node.attr('data')
    @data.splice @data.indexOf(d), 1
    @save()

    $node.parent().remove()


  @render = =>
    $('ul').html('')
    for d in @data
      $li = $('<li>').text(d+" ")
      $li.append(
        $('<a>').text('削除').attr(href: 'javascript:void(0)', data: d).click((e)=>
          @delete($(e.target))
        )
      )
      $('ul').append $li

  @start = =>
    @get()
  @start()

$ ->
  if $('#tv').text() == 'true'
    t = new TV()
