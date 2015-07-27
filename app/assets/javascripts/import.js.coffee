# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#?= require 'jquery'

$(document).ready ->
  source = new EventSource 'importlog'
  source.onmessage = (e) ->
    $("#log").append('> '+e.data+"\n")
  source.onerror = (e) ->
      if source.readyState == 0
        $("#log").append('> closed connection.\n')
        source.close()
      else
        $("#log").append('!!! an error occured: '+e.message+'\n')
        source.close()
  source.onopen = (e) ->
    $("#log").append('> opened connection to '+source.url+'\n')
  source
