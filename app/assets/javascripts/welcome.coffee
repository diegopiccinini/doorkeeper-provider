# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
   $('#search').keypress (e) ->
     s = $(this).val()
     if s.length < 2
       $(".row.application").show()
     else
       $(".row.application h2:contains('" + s + "')").parent().parent().parent().show()
       $(".row.application h2:contains('" + s + "')").parent().parent().parent().siblings().hide()


