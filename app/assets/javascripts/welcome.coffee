# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
#$ ->
#
#  $('#search').keypress (e) ->
#    env = $('#application_environment').val()
#    $(".env").parent().parent().show()
#    $(".env").parent().parent().siblings().show()
#
#    if env is 'ALL'
#      to_hide = ''
#    else if env is 'PRODUCTION'
#      to_hide= ", .env:contains(' DEV') , .env:contains(' STAGING') , .env:contains(' TEST')"
#    else
#      to_hide=", .env:not(:contains(' " + env + "'))"
#
#    s = $(this).val()
#
#    if s.length > 1
#      $(".app:contains('" + s + "')").parent().parent().show()
#      $(".app:not(:contains('" + s + "'))" + to_hide).parent().parent().hide()
#    else
#      $(to_hide.substr(1)).parent().parent().hide()
#
#  $('#application_environment').change (e) ->
#    env = $(this).val()
#    $(".env").parent().parent().show()
#    $(".env").parent().parent().siblings().show()
#
#    if env is 'ALL'
#      $(".env").parent().parent().show()
#    else if env is 'PRODUCTION'
#      $(".env:contains(' DEV')").parent().parent().hide()
#      $(".env:contains(' STAGING')").parent().parent().hide()
#      $(".env:contains(' TEST')").parent().parent().hide()
#    else
#      $(".env:not(:contains(' " + env + "'))").parent().parent().hide()
