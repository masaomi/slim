# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  if $( "#results" ).length
    $.ajax url: 'get_list', type: 'GET', success: (data) ->
      $("#results").html(data)
      $("#waiting").remove()
  if $("#statistics").length
    $.ajax url: 'statistics', type: 'GET', success: (data) ->
      $("#statistics").html(data)