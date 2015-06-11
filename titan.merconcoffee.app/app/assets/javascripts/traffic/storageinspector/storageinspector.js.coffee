# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  ife('#verso', '#recto')

  $('#lnk_list').on 'click', (e) ->
    $(this).removeClass('active').addClass('active')
    $('#lnk_graph').removeClass('active')

    ife('#verso', '#recto')

  $('#lnk_graph').on 'click', (e) ->
    $('#lnk_list').removeClass('active')
    $(this).removeClass('active').addClass('active')

    ife('#recto', '#verso')

  ipc()

  tbl_storage = $('#tbl_storage').DataTable
    aoColumnDefs: [
      {
        aTargets: [0]
        sClass: 'details-control'
      }
      {
        aTargets: [3, 4, 5]
        visible: false
      }
    ]
    columns: [
      { width: '16px' }
      { width: '150px' }
      null
    ]
    info: false
    ordering: false
    paging: false
    scrollCollapse: true
    scrollY: 224
    searching: false

  $('#tbl_storage tbody').on 'click', 'td.details-control', ->
    tr = $(this).closest('tr')
    row = tbl_storage.row(tr)

    if (row.child.isShown())
      row.child.hide()
      tr.removeClass('shown')
    else
      row.child(d1(row.data()), 'details-info').show()
      tr.addClass('shown')

  $(document).on 'change', '#storage', (e) ->
    s = $(this).val()

    $('#bubble_chart').html('')

    if s
      $.ajax('/traffic/storageinspector/get_inventory_by_storage_group_by_commodity',
        data: {
          equipment_num: s
        }
      ).done (d) ->
        if d
          rs = []

          for i in d
            ors = {
              data: [
                [
                  parseFloat(i.build_draw_qty)
                  parseFloat(i.open_qty.toString())
                  parseFloat(i.open_qty.toString())
                ]
              ]
              name: i.cmdty_cd
            }

            rs.push(ors)

          $('#bubble_chart').highcharts
            chart: {
              type: 'bubble'
              zoomType: 'xy'
            }
            series: rs
            title: ''
            yAxis: {
              title: {
                text: 'Open Qty'
              }
            }
        else
          $('#bubble_chart').html('<h1 style="color: #ed321d;">No Data Available!</h1>')
    else
      $('#bubble_chart').html('<h1 style="color: #ed321d;">No Data Available!</h1>')

  $('#my_tab a').on 'click', (e) ->
    e.preventDefault()

    $(this).tab('show')

  # $('#tbl_build tfoot th').each ->
  #   $(this).html('<input class="form-control" type="text" />')

  tbl_build = $('#tbl_build').DataTable
    aoColumnDefs: [
      {
        aTargets: [9, 10, 11]
        visible: false
      }
    ]
    bProcessing: true
    bServerSide: true
    columns: [
      { width: '100px' }
      { width: '130px' }
      { width: '130px' }
      { width: '120px' }
      { width: '120px' }
      { width: '100px' }
      { width: '100px' }
      { width: '100px' }
      { width: '100px' }
    ]
    deferRender: true
    lengthChange: false
    lengthMenu: [10, 30, 50, -1]
    order: [
      [1, 'desc']
    ]
    ordering: false
    sAjaxSource: $('#tbl_build').data('source')
    scrollX: true
    searching: false
    sPaginationType: 'full_numbers'

  $('#tbl_build tbody').on 'click', 'td > a[id^=lnk_build_]', ->
    bn = $(this).text()

    tr = $(this).closest('tr')
    row = tbl_build.row(tr)

    if (row.child.isShown())
      row.child.hide()
      tr.removeClass('shown')
    else
      rd = row.data()

      equipment_num = rd[9]
      cargo_num = rd[10]

      $.ajax('/traffic/storageinspector/get_draw_by_equipment_and_cargo',
        data: {
          equipment_num: equipment_num
          cargo_num: cargo_num
        }
        beforeSend: (xhr) ->
          ###
          Start progress animation
          ###
          $('.loading-spinner').removeClass('hidden').addClass('show')
      ).done (d) ->
        row.child(d2(rd, d), 'details-info').show()
        tr.addClass('shown')

        ###
        Hide progress animation
        ###
        $('.loading-spinner').removeClass('show').addClass('hidden')

  $('#tbl_draw').DataTable
    aoColumnDefs: [
      {
        aTargets: [9, 10, 11]
        visible: false
      }
    ]
    bProcessing: true
    bServerSide: true
    columns: [
      { width: '100px' }
      { width: '130px' }
      { width: '130px' }
      { width: '120px' }
      { width: '120px' }
      { width: '100px' }
      { width: '100px' }
      { width: '100px' }
      { width: '100px' }
    ]
    deferRender: true
    lengthChange: false
    lengthMenu: [10, 30, 50, -1]
    order: [
      [1, 'desc']
    ]
    ordering: false
    sAjaxSource: $('#tbl_draw').data('source')
    scrollX: true
    searching: false
    sPaginationType: 'full_numbers'

  return true

# window.bind 'resize', ->
#   tbl_inventory.fnAdjustColumnSizing()

###
Initialize pie charts
###
ipc = ->
  $('#chart_1').easyPieChart
    barColor: '#ffffff'
    scaleColor: false
    trackColor: '#c0392b'

  $('#chart_2').easyPieChart
    barColor: '#ffffff'
    scaleColor: false
    trackColor: '#d35400'

  $('#chart_3').easyPieChart
    barColor: '#ffffff'
    scaleColor: false
    trackColor: '#2980b9'

  $('#chart_4').easyPieChart
    barColor: '#ffffff'
    scaleColor: false
    trackColor: '#16a085'

  $('#chart_5').easyPieChart
    barColor: '#ffffff'
    scaleColor: false
    trackColor: '#27ae60'

  $('#chart_6').easyPieChart
    barColor: '#ffffff'
    scaleColor: false
    trackColor: '#8e44ad'

###
Initialize flippy effect
###
ife = (html1, html2) ->
  $('.flipbox-container').flippy
    direction: 'LEFT'
    duration: '750'
    noRemove: true
    recto: html1
    verso: html2

d1 = (v) ->
  h = ''
  h += '<div class="details-info-content-grey">'
  h += '  <div class="no-margin row">'
  h += '    <div class="form-group">'
  h += '      <label class="col-sm-2 control-label">Build/Draw Qty</label>'
  h += '      <div class="col-sm-10">'
  h += '      <input class="form-control" disabled value="' + v[3] + '" />'
  h += '    </div>'
  h += '    <div class="form-group">'
  h += '      <label class="col-sm-2 control-label">Open Qty</label>'
  h += '      <div class="col-sm-10">'
  h += '      <input class="form-control" disabled value="' + v[4] + '" />'
  h += '    </div>'
  h += '    <div class="form-group">'
  h += '      <label class="col-sm-2 control-label">Used Qty</label>'
  h += '      <div class="col-sm-10">'
  h += '      <input class="form-control" disabled value="' + v[5] + '" />'
  h += '    </div>'
  h += '  </div>'
  h += '</div>'

  return h

d2 = (v1, v2) ->
  h = ''
  h += '<div class="details-info-content-grey">'
  h += '  <div class="row">'
  h += '    <div class="col-md-12">'
  h += '      <div class="form-horizontal">'
  h += '        <h3 class="heading-a no-margin">Tags</h3>'
  h += '      </div>'
  h += '    </div>'
  h += '  </div>'
  h += '  <div class="clearfix"></div>'
  h += '  <div class="row">'
  h += '    <div class="col-md-12">'
  h += '      <table class="table" style="margin-bottom: 0 !important; width: 100% !important;">'
  h += '        <thead>'
  h += '          <tr>'
  h += '            <th>Type</th>'
  h += '            <th>Chop Id</th>'
  h += '            <th>Container</th>'
  h += '            <th>ICO</th>'
  h += '            <th>Tag Qty</th>'
  h += '            <th>Tag Qty UOM</th>'
  h += '            <th>Tag Allocated Qty</th>'
  h += '            <th>Gain/Loss Qty</th>'
  h += '          </tr>'
  h += '        </thead>'
  h += '        <tbody>'

  for item in v1[11]
    h += '        <tr class="warning">'
    h += '          <td>' + item.tag_type_cd + '</td>'
    h += '          <td>' + item.chop_id + '</td>'
    h += '          <td>' + item.tag_value1 + '</td>'
    h += '          <td>' + item.tag_value2 + '</td>'
    h += '          <td>' + parseFloat(item.tag_qty).toFixed(2) + '</td>'
    h += '          <td>' + item.tag_qty_uom_cd + '</td>'
    h += '          <td>' + (if item.tag_alloc_qty != null then parseFloat(item.tag_alloc_qty).toFixed(2) else '0.00') + '</td>'
    h += '          <td>' + (if item.tag_loss_gain_adj_qty != null then parseFloat(item.tag_loss_gain_adj_qty).toFixed(2) else '0.00') + '</td>'
    h += '        </tr>'

  h += '        </tbody>'
  h += '      </table>'
  h += '    </div>'
  h += '  </div>'
  h += '  <div class="clearfix"></div>'
  h += '  <br />'
  h += '  <div class="row">'
  h += '    <div class="col-md-12">'
  h += '      <div class="form-horizontal">'
  h += '        <h3 class="heading-a no-margin">Associated Draws</h3>'
  h += '      </div>'
  h += '    </div>'
  h += '  </div>'
  h += '  <div class="clearfix"></div>'
  h += '  <div class="row">'
  h += '    <div class="col-md-12">'
  h += '      <table class="table" style="margin-bottom: 0 !important; width: 100% !important;">'
  h += '        <thead>'
  h += '          <tr>'
  h += '            <th>Draw No.</th>'
  h += '            <th>Location</th>'
  h += '            <th>Type</th>'
  h += '            <th>Draw Qty</th>'
  h += '            <th>Open Qty</th>'
  h += '          </tr>'
  h += '        </thead>'
  h += '        <tbody>'

  if v2.associated_draw.length > 0
    for item in v2.associated_draw
      h += '        <tr class="success">'
      h += '          <td>' + item.build_draw_num + '</td>'
      h += '          <td>' + item.location.location_cd + '</td>'
      h += '          <td>' + item.build_draw_type.ind_value_name + '</td>'

      if item.build_draw_qty < 0
        h += '          <td style="color: #ed321d;">(' + parseFloat(item.build_draw_qty * -1).toFixed(2) + ')</td>'
      else
        h += '          <td>' + parseFloat(item.build_draw_qty).toFixed(2) + '</td>'

      h += '          <td>' + parseFloat(item.open_qty).toFixed(2) + '</td>'
      h += '        </tr>'
  else
    h += '        <tr class="success"><td colspan="5">No Data Available!</td></tr>'

  h += '        </tbody>'
  h += '      </table>'
  h += '    </div>'
  h += '  </div>'
  # h += '  <div class="clearfix"></div>'
  # h += '  <br />'
  # h += '  <div class="row">'
  # h += '    <div class="col-md-12">'
  # h += '      <div class="form-horizontal">'
  # h += '        <h3 class="heading-a no-margin">Available Draws</h3>'
  # h += '      </div>'
  # h += '    </div>'
  # h += '  </div>'
  # h += '  <div class="clearfix"></div>'
  # h += '  <div class="row">'
  # h += '    <div class="col-md-12">'
  # h += '      <table class="table" style="margin-bottom: 0 !important; width: 100% !important;">'
  # h += '        <thead>'
  # h += '          <tr>'
  # h += '            <th>Draw No.</th>'
  # h += '            <th>Location</th>'
  # h += '            <th>Type</th>'
  # h += '            <th>Draw Qty</th>'
  # h += '            <th>Open Qty</th>'
  # h += '          </tr>'
  # h += '        </thead>'
  # h += '        <tbody>'
  #
  # if v2.available_draw.length > 0
  #   for item in v2.available_draw
  #     h += '        <tr class="info">'
  #     h += '          <td>' + item.build_draw_num + '</td>'
  #     h += '          <td>' + item.location.location_cd + '</td>'
  #     h += '          <td>' + item.build_draw_type.ind_value_name + '</td>'
  #
  #     if item.build_draw_qty < 0
  #       h += '          <td style="color: #ed321d;">(' + parseFloat(item.build_draw_qty * -1).toFixed(2) + ')</td>'
  #     else
  #       h += '          <td>' + parseFloat(item.build_draw_qty).toFixed(2) + '</td>'
  #
  #     h += '          <td>' + parseFloat(item.open_qty).toFixed(2) + '</td>'
  #     h += '        </tr>'
  # else
  #   h += '        <tr class="info"><td colspan="5">No Data Available!</td></tr>'
  #
  # h += '        </tbody>'
  # h += '      </table>'
  # h += '    </div>'
  # h += '  </div>'
  h += '</div>'

  return h
