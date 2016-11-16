# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
   $('#search').keypress (e) ->
     s = $(this).val()
     if s.length < 2
       $(".app").parent().parent().show()
       $(".app").parent().parent().siblings().show()
     else
       $(".app:contains('" + s + "')").parent().parent().show()
       $(".app:not(:contains('" + s + "'))").parent().parent().hide()

