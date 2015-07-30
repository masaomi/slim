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

$(document).ready ->
  norm = false
  results = []
  sorting_criterium = 'n_ids'
  draw_row = () ->
    this.empty()
    if this.data.is_oxifeature && not this.data.has_id
      this.append('<td>through oxichain</td>')
    else
      this.append('<td><a href="'+this.data.lipid_url.url+'">'+this.data.lipid.common_name+'</a></td>')
    this.append('<td><a href="'+this.data.feature_url.url+'">'+this.data.feature.id_string+'</a></td>')
    switch sorting_criterium
      when 'n_ids' then this.append('<td>'+this.data.n_ids+'</td>')
      when 'cat'
        unless this.data.is_oxifeature && not this.data.has_id
          this.append('<td>'+this.data.lipid.main_class+'</td>')
        else
          this.append('<td>&nbsp;</td>')
      when 'oxidations'
        unless this.data.is_oxifeature && not this.data.has_id
          this.append('<td>'+this.data.lipid.oxidations+'</td>')
        else
          this.append('<td></td>')
      when 'rt' then this.append('<td>'+this.data.feature.rt+'</td>')
      when 'm/z' then this.append('<td>'+this.data.feature.m_z+'</td>')
      when 'oxichain' then this.append('<td>'+this.data.feature.oxichain+'</td>')
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
  export_csv = () ->
    csv = ''
    header = ['feature',
              'retention_time',
              'm/z',
              'lipid',
              'common_name',
              'oxidations',
              'score',
              'fragmentation_score',
              'mass_error',
              'isotope_similarity',
              'category',
              'main_class',
              'sub_class',
              'n_identifications',
              'oxichain',
              'included_by_oxichain']
    csv += header.join(',')+($('#sample_names').html())+"\n"
    for row in results
      d = row.data
      r = []
      r.push d.feature.id_string
      r.push d.feature.rt
      r.push d.feature.m_z
      unless d.is_oxifeature && not d.has_id
        r.push d.lipid.common_name
        r.push d.lipid.lm_id
        r.push d.lipid.oxidations
        r.push d.identification.score
        r.push d.identification.fragmentation_score
        r.push d.identification.mass_error
        r.push d.identification.isotope_similarity
        r.push d.lipid.category_
        r.push d.lipid.main_class
        r.push d.lipid.sub_class
        if d.is_oxifeature
          r.push 'true'
        else
          r.push 'false'
      else
        r.push 'through oxichain'
        r.push ''
        r.push ''
        r.push ''
        r.push ''
        r.push ''
        r.push ''
        r.push 'oxichain'
        r.push ''
        r.push ''
        r.push 0
        r.push d.feature.oxichain
        r.push 'true'
      for i in [0..d.values.length/2-1]
        r.push d.values[i*2]
      for i in [0..d.values.length/2-1]
        r.push d.values[i*2+1]
      csv += r.join(',')+"\n"
    window.open(encodeURI('data:application/csv;charset=utf-8;filename=results.csv,'+csv))


  if $( "#results" ).length
    $.ajax 'get_list.json', success: (data) ->
      $("#waiting").remove()
      for d in data.ids
        row = $('<tr />', id: 'result_'+d.id)
        row.data = d
        row.draw_row = draw_row
        row.draw_row()
        results.push row
        $("#results").append(row)
      for d in data.oxifeatures
        row = $('<tr />', id: 'feature_'+d.id)
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
      $("#info").append $('<button />', text: 'sort by oxichain').click((e) ->
        $('#sorting_criterium').html('oxichain #')
        sorting_criterium = 'oxichain'
        results = results.sort (a,b) ->
          if a.data.feature.oxichain == b.data.feature.oxichain
            if a.data.feature.m_z >= b.data.feature.m_z
              return 1
            else
              return -1
          if a.data.feature.oxichain >= b.data.feature.oxichain
            return 1
          else
            return -1
        for row in results
          row.detach()
          row.draw_row()
          $("#results").append(row)
      )
      $("#info").append $('<button />', text: 'download as csv').click((e) ->
        export_csv()
      )
    $('.values_norm').hide()
  if $("#statistics").length
    $("#statistics").html $('<button>',text: 'load statistics',click: (e) ->
      $("#statistics").html('loading statistics...')
      $.ajax url: 'statistics', type: 'GET', success: (data) ->
        $("#statistics").html(data)
    )
