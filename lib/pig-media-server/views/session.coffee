$ ->
  user_id = $('#user_id').text()
  localStorage.user_id = user_id  if  user_id != ''
  if localStorage.user_id != undefined and localStorage.user_id != ''
    if user_id == ''
      $.post('/sessions', user_id: localStorage.user_id).success(-> location.reload())
