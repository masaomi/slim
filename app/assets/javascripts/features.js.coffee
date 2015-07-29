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

class Feature
  oxichain: null
  constructor: (plot,mz,rt,color,id) ->
    this.ttp = plot.getTTP()
    this.ttc = plot.getTTC()
    this.ctx = plot.ctx
    this.x = null
    this.y = null
    this.mz = mz
    this.rt = rt
    this.color = color
    this.id = id
  draw: () ->
    [this.x,this.y] = this.ttp(this.mz,this.rt)
    if this.x?
      this.ctx.beginPath()
      this.ctx.strokeStyle = this.color
      this.ctx.arc(this.x,this.y,2,0,2*Math.PI)
      this.ctx.stroke()
  clicked: (x,y) ->
    return (x-3<this.x && x+3>this.x && y-3<this.y && y+3>this.y)
  draw_oxichain: () ->
    return unless this.oxichain?
    return unless this.oxichain.x?
    return unless this.x?
    return if this.mz>this.oxichain.mz
    this.ctx.beginPath()
    this.ctx.strokeStyle = '#008800'
    this.ctx.moveTo(this.x,this.y)
    this.ctx.lineTo(this.oxichain.x,this.oxichain.y)
    this.ctx.stroke()

class Plot
  ks_width: 20
  original_scaling: [80,5,1350,23.1]
  min_x_scaling: 10
  min_y_scaling: 2
  constructor: (canvas) ->
    if window.devicePixelRatio? && window.devicePixelRatio > 1
      devicePixelRatio = window.devicePixelRatio
      canvasWidth = canvas.attr 'width'
      canvasHeight = canvas.attr 'height'
      canvas.css 'width', canvasWidth+'px'
      canvas.css 'height', canvasHeight+'px'
      canvas.attr 'width', canvasWidth*devicePixelRatio
      canvas.attr 'height', canvasHeight*devicePixelRatio
      canvas[0].getContext('2d').scale(devicePixelRatio,devicePixelRatio)
    this.canvas = canvas[0]
    this.ctx = this.canvas.getContext('2d')
    this.setScaling(this.original_scaling[0],this.original_scaling[1],this.original_scaling[2],this.original_scaling[3])
    this.extractWidthHeight()
    this.draw()
  draw: () ->
    this.ctx.clearRect(0,0,this.canvas.scrollWidth,this.canvas.scrollHeight)
    this.draw_ksxy()
  extractWidthHeight: () ->
     this.pH = this.canvas.scrollHeight-this.ks_width
     this.pW = this.canvas.scrollWidth-this.ks_width
  setScaling: (xmin,ymin,xmax,ymax) ->
    if xmin>xmax
      t = xmin
      xmin = xmax
      xmax = t
    if ymin>ymax
      t = ymin
      ymin = ymax
      ymax = t
    if xmax-xmin<this.min_x_scaling
      xmax = xmin+this.min_x_scaling
    if ymax-ymin<this.min_y_scaling
      ymax = ymin+this.min_y_scaling
    if xmin<this.original_scaling[0]
      delta = this.original_scaling[0]-xmin
      xmin = this.original_scaling[0]
      xmax = xmax+delta
    if ymin<this.original_scaling[1]
      delta = this.original_scaling[1]-ymin
      ymin = this.original_scaling[1]
      ymax = ymax+delta
    if xmax>this.original_scaling[2]
      delta = this.original_scaling[2]-xmax
      xmax = this.original_scaling[2]
      xmin = xmin-delta
    if ymax>this.original_scaling[3]
      delta = this.original_scaling[3]-ymax
      ymax = this.original_scaling[3]
      ymin = ymin-delta
    if xmax-xmin>this.original_scaling[2]-this.original_scaling[0]
      xmin = this.original_scaling[0]
      xmax = this.original_scaling[2]
    if ymax-ymin>this.original_scaling[3]-this.original_scaling[1]
      ymin = this.original_scaling[1]
      ymax = this.original-scaling[3]
    this.xmin = xmin
    this.ymin = ymin
    this.xmax = xmax
    this.ymax = ymax
    this.cH = ymax-ymin
    this.cW = xmax-xmin
  transform_to_pixel: (x,y) ->
    return [null,null] if x>this.xmax || y>this.ymax || x<this.xmin || y < this.ymin
    x = x-this.xmin
    y = y-this.ymin
    return [this.ks_width + x*this.pW/this.cW, this.pH-y*this.pH/this.cH]
  transform_to_coordinates: (x,y) ->
    x = x-this.ks_width
    y = this.pH-y
    return [this.xmin+x*this.cW/this.pW,this.ymin+y*this.cH/this.pH]
  ttp: (x,y) ->
    this.transform_to_pixel(x,y)
  ttc: (x,y) ->
    this.transform_to_coordinates(x,y)
  getTTP: () ->
    a = (t) ->
      (x,y) ->
        t.transform_to_pixel(x,y)
    return a(this)
  getTTC: () ->
    a = (t) ->
      (x,y) ->
        t.transform_to_coordinates(x,y)
    return a(this)
  draw_ksxy: () ->
    origin = this.ttp(this.xmin,this.ymin)
    top = this.ttp(this.xmin,this.ymax)
    right = this.ttp(this.xmax,this.ymin)
    this.ctx.beginPath()
    this.ctx.strokeStyle = 'black'
    this.ctx.lineWidth = 1
    this.ctx.moveTo(top[0],top[1])
    this.ctx.lineTo(origin[0],origin[1])
    this.ctx.lineTo(right[0],right[1])
    this.ctx.lineTo(right[0]-5,right[1]-3)
    this.ctx.moveTo(right[0],right[1])
    this.ctx.lineTo(right[0]-5,right[1]+3)
    this.ctx.moveTo(top[0],top[1])
    this.ctx.lineTo(top[0]-3,top[1]+5)
    this.ctx.moveTo(top[0],top[1])
    this.ctx.lineTo(top[0]+3,top[1]+5)
    this.ctx.stroke()
    this.ctx.font = '10px Arial'
    ymin = Math.ceil(this.ymin)
    ymax = Math.floor(this.ymax)
    for i in [ymin..ymax-1]
      [x,y] = this.ttp(this.xmin,i)
      m = this.ctx.measureText(i)
      this.ctx.fillText(i,x-m.width-4,y+3)
      this.ctx.beginPath()
      this.ctx.moveTo(x,y)
      this.ctx.lineTo(x-2,y)
      this.ctx.stroke()
    xstep = (this.xmax-this.xmin)/40
    xstep=1 if xstep<=1
    xstep=2 if xstep<=2 && xstep>1
    xstep=5 if xstep<=5 && xstep>2
    xstep=10 if xstep<=10 && xstep>5
    xstep=20 if xstep<=20 && xstep>10
    xstep=50 if xstep<=50 && xstep>20
    xstep=100 if xstep>50
    xmin = Math.ceil(this.xmin/xstep)
    xmax = Math.floor(this.xmax/xstep)
    for i in [xmin..xmax-1]
      i = i*xstep
      [x,y] = this.ttp(i,this.ymin)
      w = this.ctx.measureText(i).width
      this.ctx.fillText(i,x-w/2,y+15)
      this.ctx.beginPath()
      this.ctx.moveTo(x,y)
      this.ctx.lineTo(x,y+3)
      this.ctx.stroke()


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
    features = []
    i = 0
    oxichains = {}
    do_on_drag = (e,dx,dy ) ->
      x = e.pageX - e.target.offsetLeft
      y = e.pageY - e.target.offsetTop
      [xmax,ymax] = p.ttc(x,y)
      dx = -dx if dx<0
      dy = -dy if dy<0
      [xmin,ymin] = p.ttc(x-dx,y-dy)
      p.setScaling(xmin,ymin,xmax,ymax)
      p.draw() #redraw ksxy
      for f in features
        f.draw() #redraw features
      for f in features
        f.draw_oxichain() #redraw oxichains
    old_feature = null
    do_on_click = (e,dx,dy) ->
      x = e.pageX - e.target.offsetLeft
      y = e.pageY - e.target.offsetTop
      for f in features
        if f.clicked(x,y)
          selected_feature = f
          break
      if selected_feature?
        $('#log-head').html($('<h3 />',class: 'panel-title', html: 'Status-Info'))
        $('#log').html('loading feature '+selected_feature.id+'...')
        if old_feature?
          old_feature.draw()
        old_feature = selected_feature
        c = selected_feature.color
        selected_feature.color = '#ff4444'
        selected_feature.draw()
        selected_feature.color = c
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
    #Distinguish click or drag
    old_event = null
    $('#plot').dblclick (e) ->
      p.setScaling(p.original_scaling[0],p.original_scaling[1],p.original_scaling[2],p.original_scaling[3])
      p.draw() #redraw ksxy
      for f in features
        f.draw() #redraw features
      for f in features
        f.draw_oxichain() #redraw oxichains
    $('#plot').resize (e) ->
      p.extractWidthHeight()
      p.draw()
      for f in features
        f.draw() #redraw features
      for f in features
        f.draw_oxichain() #redraw oxichains
    $('#plot').mousedown (e) ->
      old_event = e
    $('#plot').mouseup (e) ->
      return unless old_event?
      return if old_event.timestamp>e.timestamp+5000
      dx = old_event.pageX - e.pageX
      dy = old_event.pageY - e.pageY
      if (dx<3 && dx>-3) or (dy<3 && dy>-3)
        do_on_click(old_event)
      else
        do_on_drag(e,dx,dy)
    p = new Plot($('#plot'))
    source = new EventSource 'load_features'
    $('#log').html('Connecting to server')
    source.onmessage = (e) ->
      i += 1
      e = eval(e.data)
      e = e[0]
      f = new Feature(p,e.m_z,e.rt,e.color,e.id)
      features.push f
      f.draw()
      if e.oxichain?
        oxichains[e.oxichain] = [] unless oxichains[e.oxichain]?
        oxichains[e.oxichain].push f
      $('#log').html('Loaded feature '+i+', continuing...')
    source.onerror = (e) ->
      source.close()
      $('#log').html('Finished loading '+i+' features.')
      #now draw oxichains
      for k,i of oxichains
        start = null
        for f in i
          if start?
            start.oxichain = f
          start = f
      for f in features
        f.draw_oxichain()
    source.onstart = (e) ->
      $('#log').html('Connected to server')
