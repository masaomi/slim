# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

heatmap = (value, min, max) ->
  r = (value-min)/(max-min)
  if r<0.5
    d = Math.floor(256*r+127)
    'rgb('+d+','+d+',255)'
  else
    d = Math.floor(255+255*(0.5-r))
    'rgb(255,'+d+','+d+')'
export_csv = (data) ->
  csv = ''
  header = ['feature',
            'retention_time',
            'lipid',
            'common_name',
            'oxidations',
            'score',
            'fragmentation_score',
            'mass_error',
            'isotope_similarity',
            'category',
            'cat1',
            'cat2',
            'cat3',
            'n_identifications']
  csv += header.join(',')+"\n"
  for row in data
    a = []

  u = encodeURI('data:text/csv;charset=utf-8;filename=results.csv,\n'+csv)
$(document).ready ->
  norm = false
  results = []
  sorting_criterium = 'n_ids'
  draw_row = () ->
    console.log('Drawing row '+this.data.id, norm )
    this.empty()
    this.append('<td><a href="'+this.data.feature_url.url+'">'+this.data.feature.id_string+'</a></td>')
    this.append('<td><a href="'+this.data.lipid_url.url+'">'+this.data.lipid.common_name+'</a></td>')
    switch sorting_criterium
      when 'n_ids' then this.append('<td>'+this.data.n_ids+'</td>')
      when 'cat' then this.append('<td>'+this.data.lipid.main_class+'</td>')
      when 'oxidations' then this.append('<td>'+this.data.lipid.oxidations+'</td>')
      when 'rt' then this.append('<td>'+this.data.feature.rt+'</td>')
      when 'm/z' then this.append('<td>'+this.data.feature.m_z+'</td>')
      else this.append('<td>???</td>')
    values = []
    for i in [0..this.data.values.length/2-1]
      if norm
        values.push this.data.values[i*2+1]
      else
        values.push this.data.values[i*2]
    ma = Math.max.apply(Math,values);
    mi = Math.min.apply(Math,values);
    for i in values
      if norm
        this.append($("<td />", html:Math.floor(i) ).css('background-color',heatmap(i,mi,ma)))
      else
        this.append($("<td />", html:Math.floor(i) ).css('background-color',heatmap(i,mi,ma)))

  if $( "#results" ).length
    $.ajax 'get_list.json', success: (data) ->
      $("#waiting").remove()
      for d in data
        row = $('<tr />', id: 'result_'+d.id)
        row.data = d
        row.draw_row = draw_row
        row.draw_row()
        results.push row
        $("#results").append(row)
      $("#info").html '<br /><p>Filtered '+(data.length)+' lipids.</p>'
      $("#info").append $('<button />', text: 'show normalized values', id: 'toggle_norm').click((e) ->
        if norm
          # switch to raw values
          norm = false
          $('#toggle_norm').text 'show normalized values'
          $('.values_norm').hide()
          $('.values_raw').show()
        else
          # switch to normalized values
          norm = true
          $('#toggle_norm').text 'show raw values'
          $('.values_norm').show()
          $('.values_raw').hide()
        for row in results
          row.draw_row()
      )
      $("#info").append $('<button />', text: 'sort by category').click((e) ->
        cat = {}
        $('#sorting_criterium').html('Category')
        sorting_criterium = 'cat'
        for row in results
          row.detach()
          cat[row.data.lipid.main_class] ||= []
          cat[row.data.lipid.main_class].push row
        for key, value of cat
          value.sort (a,b) ->
            if a.data.lipid.oxidations >= b.data.lipid.oxidations
              return 1
            else
              return -1
          for row in value
            $("#results").append(row)
            row.draw_row()
      )
      $("#info").append $('<button />', text: 'sort by oxidations').click((e) ->
        cat = {}
        for i in [0..10]
          cat[i] = []
        $('#sorting_criterium').html('Oxidations')
        sorting_criterium = 'oxidations'
        for row in results
          row.detach()
          cat[row.data.lipid.oxidations].push row
        for key, value of cat
          for row in value
            $("#results").append(row)
            row.draw_row()
      )
      $("#info").append $('<button />', text: 'sort by retention time').click((e) ->
        $('#sorting_criterium').html('rt (min)')
        sorting_criterium = 'rt'
        results = results.sort (a,b) ->
          if a.data.feature.rt >= b.data.feature.rt
            return 1
          else
            return -1
        for row in results
          row.detach()
          row.draw_row()
          $("#results").append(row)
      )
      $("#info").append $('<button />', text: 'sort by m/z').click((e) ->
        $('#sorting_criterium').html('m/z')
        sorting_criterium = 'm/z'
        results = results.sort (a,b) ->
          if a.data.feature.m_z >= b.data.feature.m_z
            return 1
          else
            return -1
        for row in results
          row.detach()
          row.draw_row()
          $("#results").append(row)
      )
    $('.values_norm').hide()
  if $("#statistics").length
    $.ajax url: 'statistics', type: 'GET', success: (data) ->
      $("#statistics").html(data)