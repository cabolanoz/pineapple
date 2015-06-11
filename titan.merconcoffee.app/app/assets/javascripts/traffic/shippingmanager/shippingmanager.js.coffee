# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  tbl = $('#tbl_itinerary').DataTable
    bProcessing: true
    bServerSide: true
    columns: [
      null
      null
      null
      null
      null
      null
      { width: '16px' }
    ]
    deferRender: true
    lengthChange: false
    lengthMenu: [15, 30, 50, -1]
    ordering: false
    sAjaxSource: $('#tbl_itinerary').data('source')
    scrollX: true
    sPaginationType: 'full_numbers'
    preDrawCallback: (s) ->
      ###
      Start progress animation
      ###
      $('.loading-spinner').removeClass('hidden').addClass('show')
    fnDrawCallback: ->
      ###
      Hide progress animation
      ###
      $('.loading-spinner').removeClass('show').addClass('hidden')

      $('#tbl_itinerary tbody').on 'mousedown', 'td:nth-child(n+2)', ->
        if event.which == 3
          tr = $(this).closest('tr')
          row = tbl.row(tr)

          $(tr).contextmenu
            target: '#itinerary_contextmenu'
            before: (e, context) ->
              e.preventDefault

              span = $('#itinerary_contextmenu').find('span')[0]
              if span
                $(span).text($(row.data()[0]).text())

              return true
            onItem: (context, e) ->
              if e.target.tagName != 'SPAN'
                switch e.target.id
                  when 'lnk_edit' then console.log 'Edit!'
                  when 'lnk_void' then console.log 'Void!'

  $('#tbl_itinerary tbody').on 'click', 'td > i.glyphicon-chevron-right', ->
    tr = $(this).closest('tr')
    row = tbl.row(tr)

    rp = $('.pnl-right-sm')
    rp.html('')

    $('.pnl-left-sm').toggle('slow')
    $('.pnl-right-sm').toggle('slow', ->
      $.ajax('/traffic/shippingmanager/get_itinerary_by_id',
        data: {
          id: $(row.data()[0]).text()
        }
        beforeSend: (xhr) ->
          ###
          Start progress animation
          ###
          $('.loading-spinner').removeClass('hidden').addClass('show')
      ).done (data) ->
        ###
        Hide progress animation
        ###
        $('.loading-spinner').removeClass('show').addClass('hidden')

        rp.append(d(data))

        $('.btn-menu-left').removeClass('hidden').addClass('show')
      .fail ->
        rp.html('<h1 style="color: #ed321d;>Unable To Retrieve Itinerary Data!</h1>')
    )

  $('.glyphicon-menu-left').click ->
    $('.btn-menu-left').removeClass('show').addClass('hidden')

    $('.pnl-left-sm').toggle('slow')
    $('.pnl-right-sm').toggle('slow')

d = (v) ->
  h = ''
  h += '<div class="table-responsive">'
  h += '  <table class="table table-condensed">'
  h += '    <thead>'
  h += '      <tr>'
  h += '        <th>Itinerary No.</th>'
  h += '        <th>Trade No.</th>'
  h += '        <th>Itinerary Name</th>'
  h += '        <th>Int. Company</th>'
  h += '        <th>Operator</th>'
  h += '      </tr>'
  h += '    </thead>'
  h += '    <tbody>'
  h += '      <tr class="warning">'
  h += '        <td>' + v.itinerary_num + '</td>'
  h += '        <td>' + v.itinerary_name + '</td>'
  h += '        <td>' + v.itinerary_name + '</td>'
  h += '        <td>' + v.internal_company.company_name + '</td>'
  h += '        <td>' + v.operator.first_name + ' ' + v.operator.last_name + '</td>'
  h += '      </tr>'
  h += '    </tbody>'
  h += '  </table>'
  h += '</div>'
  h += '<div class="clearfix"></div>'

  if v.movements
    for movement in v.movements
      h += '<div class="jumbotron">'
      h += '  <div style="padding: 0 15px;">'
      h += '    <div class="form-horizontal">'
      h += '      <h3 class="heading-a" style="color: #16a085;">Movement</h3>'
      h += '    </div>'
      h += '    <table class="table" style="margin-bottom: 0 !important;">'
      h += '      <thead>'
      h += '        <tr>'
      h += '          <th>No. Movement</th>'
      h += '          <th>MOT</th>'
      h += '          <th>Vehicle</th>'
      h += '          <th>Status</th>'
      h += '          <th>Depart From</th>'
      h += '          <th>Depart On</th>'
      h += '          <th>Duration</th>'
      h += '          <th>Arrive At</th>'
      h += '          <th>Arrive On</th>'
      h += '        </tr>'
      h += '      </thead>'
      h += '      <tbody>'
      h += '        <tr style="background: #16a085; color: #fff;">'
      h += '          <td>' + movement.movement_num + '</td>'
      h += '          <td>' + movement.mot_type.ind_value_name + '</td>'
      h += '          <td>' + movement.mot.mot_cd + '</td>'
      h += '          <td>' + movement.movement_status.ind_value_name + '</td>'
      h += '          <td>' + movement.depart_location.location_cd + '</td>'
      h += '          <td></td>'
      h += '          <td></td>'
      h += '          <td>' + movement.arrive_location.location_cd + '</td>'
      h += '          <td></td>'
      h += '        </tr>'
      h += '      </tbody>'
      h += '    </table>'
      h += '    <div class="clearfix"></div><br />'

      if movement.cargos
        h += '    <div class="form-horizontal">'
        h += '      <h3 class="heading-a" style="color: #2980b9;">Cargo (s)</h3>'
        h += '    </div>'
        h += '    <table class="table" style="margin-bottom: 0 !important;">'
        h += '      <thead>'
        h += '        <tr>'
        h += '          <th>No. Cargo</th>'
        h += '          <th>Cargo Name</th>'
        h += '          <th>Strategy</th>'
        h += '          <th>Commodity</th>'
        h += '          <th>Quantity UOM</th>'
        h += '          <th>Pirce Currency</th>'
        h += '          <th>Price UOM</th>'
        h += '          <th>MTM Curve</th>'
        h += '          <th>Cargo Qty</th>'
        h += '        </tr>'
        h += '      </thead>'
        h += '      <tbody>'

        for cargo in movement.cargos
          console.log cargo
          h += '        <tr style="background: #2980b9; color: #fff;">'
          h += '          <td>' + cargo.cargo_num + '</td>'
          h += '          <td>' + cargo.cargo_name + '</td>'
          h += '          <td></td>'
          h += '          <td></td>'
          h += '          <td></td>'
          h += '          <td></td>'
          h += '          <td></td>'
          h += '          <td></td>'
          h += '          <td></td>'
          h += '        </tr>'

        h += '      </tbody>'
        h += '    </table>'

      h += '  </div>'
      h += '</div>'

  return h
