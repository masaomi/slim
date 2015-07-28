# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#?= require 'jquery'

heatmap = (value, min, max) ->
  r = (value-min)/(max-min)
  if r<0.5
    d = Math.floor(256*r+127)
    'rgb('+d+','+d+',255)'
  else
    d = Math.floor(255+255*(0.5-r))
    'rgb(255,'+d+','+d+')'

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
    return [x,y]

getTransformation = (canvas,width,height) ->
  return (x) ->
    sw = (canvas.scrollWidth-20)/(width)
    sh = (canvas.scrollHeight-20)/(height)
    [x,y] = x
    return [20+x*sw,canvas.scrollHeight-y*sh-20]

$(document).ready ->
  if $('#oxichain-log').length #oxichaining
    log = $('#oxichain-log')
    log.hide()
    $('#button-container').append($('<button />', text: 'Start oxichaining search', id: 'oxichain_start').click((e) ->
      log.show()
      e.target.remove()
      source = new EventSource 'oxichain_find'
      log.html($('<image />',{url:'/assets/ajax-loader.gif',id:'loader'}))
      log.append('Starting oxichain search, this may take a while. Do not close this window!...\n')
      source.onmessage = (e) ->
        log.append(e.data+'\n')
      source.onerror = (e) ->
        source.close()
        $('#loader').remove()
      ))
  if $('#log').length   #2d-plot
    #optimize for retina display
    if window.devicePixelRatio? && window.devicePixelRatio > 1
      devicePixelRatio = window.devicePixelRatio
      canvas = $('#plot')
      canvasWidth = canvas.attr 'width'
      canvasHeight = canvas.attr 'height'
      canvas.css 'width', canvasWidth+'px'
      canvas.css 'height', canvasHeight+'px'
      canvas.attr 'width', canvasWidth*devicePixelRatio
      canvas.attr 'height', canvasHeight*devicePixelRatio
      canvas[0].getContext('2d').scale(devicePixelRatio,devicePixelRatio)
    i = 0
    features = []
    oxichains = {}
    df = null
    old_feature = null
    ctx = $('#plot')[0].getContext('2d')
    $('#plot').click (e) ->
      x = e.pageX - e.target.offsetLeft
      y = e.pageY - e.target.offsetTop
      #x = x/(e.target.scrollWidth-20)
      #y = 1-y/(e.target.scrollHeight-20)
      #x = x*1350
      #y = y*25.5
      for f in features
        if (f.x<x+3) && (f.x>x-3) && (f.y>y-3) && (f.y<y+3)
          $("#log").html('clicked on feature '+f.id+' with coordinates x='+f.x+' and y='+f.y+', own coordinates: x='+x+', y='+y)
          selected_feature = f
          break
      if selected_feature?
        $('#log-head').html($('<h3 />',class: 'panel-title', html: 'Status-Info'))
        $('#log').html('loading feature '+f.id+'...')
        df(selected_feature.m_z, selected_feature.rt, selected_feature.id,'#ff0000')
        if old_feature?
          df(old_feature.m_z, old_feature.rt, old_feature.id, old_feature.color)
        old_feature = selected_feature
        f = $.getJSON '/features/show/'+f.id+'.json', (data) ->
           $('#log-head').html($('<h3 />',class:'panel-title').append($('<a />', href: data.url,html:'Feature '+data.id_string)))
           i = $('<ul />')
           i.append($('<li />',html:'m/z: '+data.m_z))
           i.append($('<li />', html:'rt:' +data.rt))
           i.append($('<li />', html:'charge: '+data.charge))
           i.append($('<li />', html:'mass: '+data.mass))
           $('#log').html(i)
           t = $('<table />', class: 'table table-condensed')
           tr = $('<tr />')
           tr.append($('<th />', html:'Identified lipid'))
           tr.append($('<th />', html:'Score'))
           tr.append($('<th />', html:'Frag. Score'))
           tr.append($('<th />', html:'Isotope Sim.'))
           tr.append($('<th />', html:'Mass error'))
           tr.append($('<th />', html:'Adducts'))
           t.append(tr)
           for i in data.identifications
             tr = $('<tr />')
             tr.append($('<td />', html:'<a href="'+i.url+'">'+i.common_name+'</a>'))
             tr.append($('<td />', html:i.score.toFixed(2)))
             tr.append($('<td />', html:i.fragmentation_score.toFixed(2)))
             tr.append($('<td />', html:i.isotope_similarity.toFixed(2)))
             tr.append($('<td />', html:i.mass_error.toFixed(2)))
             tr.append($('<td />', html:i.adducts.toFixed(2)))
             t.append(tr)
           $('#log').append(t)
           $('#log').append($('<h5 />',html: 'Quantification'))
           max = Math.max.apply(Math,data.quantifications)
           min = Math.min.apply(Math,data.quantifications)
           ql = $('<ul />',class: 'quant-list')
           for i in [0..data.quantifications.length-1]
             ql.append($('<li />',html: data.samples[i]+'<br />'+data.quantifications[i].toFixed(0), style: 'background-color:'+heatmap(data.quantifications[i],min,max)))
           $('#log').append(ql)
           $("html, body").animate({
            scrollTop: $('#log').offset().top-50
           }, 200);
    t = getTransformation($('#plot')[0],1350,25.5)
    draw_ksxy(ctx,t)
    df = draw_feature(ctx,t)
    source = new EventSource 'load_features'
    $('#log').html('Connecting to server')
    oxichains = {}
    source.onmessage = (e) ->
      i += 1
      e = eval(e.data)
      e = e[0]
      [x,y] = df(e.m_z,e.rt,e.id,e.color)
      $('#log').html('Loaded feature '+i+', continuing...')
      features.push {x: x, y:y, mz:e.m_z,rt:e.rt, id:e.id,color:e.color,oxichain:e.oxichain}
      if e.oxichain?
        oxichains[e.oxichain] = [] unless oxichains[e.oxichain]?
        oxichains[e.oxichain].push {x:x,y:y}
    source.onerror = (e) ->
      source.close()
      $('#log').html('Finished loading '+i+' features.')
      #now draw oxichains
      console.log(oxichains)
      for k,i of oxichains
        console.log('Drawing oxichain',k,'with array',i)
        ctx.beginPath()
        ctx.strokeStyle="#008800"
        start = true
        for f in i
          if start
            ctx.moveTo(f.x,f.y)
            start = false
          else
            ctx.lineTo(f.x,f.y)
        ctx.stroke()
    source.onstart = (e) ->
      $('#log').html('Connected to server')
