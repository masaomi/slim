# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#?= require 'jquery'

draw_ksxy = (c,t) ->
  origin = t([0,0])
  top = t([0,25.5])
  right = t([1350,0])
  c.beginPath()
  c.lineWidth = 1
  c.moveTo(top[0],top[1])
  c.lineTo(origin[0],origin[1])
  c.lineTo(right[0],right[1])
  c.lineTo(right[0]-5,right[1]-5)
  c.moveTo(right[0],right[1])
  c.lineTo(right[0]-5, right[1]+5)
  c.moveTo(top[0],top[1])
  c.lineTo(top[0]-5,top[1]+5)
  c.moveTo(top[0],top[1])
  c.lineTo(top[0]+5,top[1]+5)
  c.stroke()
  c.font = '10px Arial'
  for i in [0..25]
    [x,y] = t([0,i])
    m = c.measureText(i)
    c.fillText(i,x-m.width-4,y+3)
    c.beginPath()
    c.moveTo(x,y)
    c.lineTo(x-2,y)
    c.stroke()
  for i in [0..13]
    i = i*100
    [x,y] = t([i,0])
    w = c.measureText(i).width
    c.fillText(i,x-w/2,y+15)
    c.beginPath()
    c.moveTo(x,y)
    c.lineTo(x,y+3)
    c.stroke()
draw_feature = (c,t) ->
  return (x,y,feature,col) ->
    c.beginPath()
    c.strokeStyle = col
    [x,y] = t([x,y])
    c.arc(x,y,2,0,2*Math.PI)
    #c.fill()
    c.stroke()

getTransformation = (canvas,width,height) ->
  return (x) ->
    sw = (canvas.scrollWidth-20)/(width)
    sh = (canvas.scrollHeight-20)/(height)
    [x,y] = x
    return [20+x*sw,canvas.scrollHeight-y*sh-20]

$(document).ready ->
  i = 0
  ctx = $('#plot')[0].getContext('2d')
  t = getTransformation($('#plot')[0],1350,25.5)
  draw_ksxy(ctx,t)
  df = draw_feature(ctx,t)
  if $('#log').length
    source = new EventSource 'load_features'
    $('#log').html('Connecting to server')
    source.onmessage = (e) ->
      i += 1
      e = eval('['+e.data+']')
      e = e[0]
      df(e.m_z,e.rt,e.id,e.color)
      $('#log').html('Loaded feature '+i+', continuing...')
    source.onerror = (e) ->
      source.close()
      $('#log').html('Finished loading '+i+' features.')
    source.onstart = (e) ->
      $('#log').html('Connected to server')
