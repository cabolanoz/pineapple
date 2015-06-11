# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ft_storage_type = ''
ft_storage = ''
ft_level = ''
ft_location = ''
ft_owner = ''
ft_company = ''
ft_open_qty = 'SUM([OPS_BUILD_DRAW].open_qty) > 0'

jQuery ->
  ft_company = $('#inventory_internal_company').val()

  $('#my_tab a').on 'click', (e) ->
    e.preventDefault()

    $(this).tab('show')

  # Inventory detail
  tbl_inventory_dtl = $('#tbl_inventory_dtl').dataTable
    aoColumnDefs: [
      {
        aTargets: [3]
        visible: false
      }
    ]
    bProcessing: true
    bServerSide: true
    deferRender: true
    lengthChange: false
    lengthMenu: [15, 30, 45, -1]
    ordering: false
    sAjaxSource: $('#tbl_inventory_dtl').data('source')
    searching: false
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
    fnServerParams: (aoData) ->
      if ft_storage_type
        aoData.push
          name: 'sSearch_C1'
          value: ft_storage_type

      if ft_storage
        aoData.push
          name: 'sSearch_C2'
          value: ft_storage

      if ft_level
        aoData.push
          name: 'sSearch_C3'
          value: ft_level

      if ft_location
        aoData.push
          name: 'sSearch_C4'
          value: ft_location

      if ft_owner
        aoData.push
          name: 'sSearch_C5'
          value: ft_owner

      if ft_company
        aoData.push
          name: 'sSearch_C6'
          value: ft_company

      aoData.push
        name: 'sSearch_C7'
        value: ft_open_qty

      return
    footerCallback: (row, data, start, end, display) ->
      api = this.api()

      if data.length > 0
        # Total Qty
        global_total_qty = api.column(9).data().reduce((a, b) ->
          return parseFloat(a) + parseFloat(b)
        )

        page_total_qty = api.column(9, { page: 'current' }).data().reduce((a, b) ->
          return parseFloat(a) + parseFloat(b)
        )

        $(api.column(9).footer()).html('' + page_total_qty.toFixed(2))

        # Total Bags
        global_total_bag = api.column(11).data().reduce((a, b) ->
          return parseFloat(a) + parseFloat(b)
        )

        page_total_bag = api.column(11, { page: 'current' }).data().reduce((a, b) ->
          return parseFloat(a) + parseFloat(b)
        )

        $(api.column(11).footer()).html('' + page_total_bag)
      else
        $(api.column(9).footer()).html('0')
        $(api.column(11).footer()).html('0')

  # Adding contextual menu for inventory detail table
  $('#tbl_inventory_dtl tbody').on 'mousedown', 'td', ->
    if event.which == 3
      tr = $(this).closest('tr')
      row = tbl_inventory_dtl.DataTable().row(tr)

      $(tr).contextmenu
        target: '#inventory_dtl_contextmenu'
        before: (e, context) ->
          e.preventDefault

          span = $('#inventory_dtl_contextmenu').find('span')[0]
          if span
            # console.log row.data()[0]
            $(span).text($(row.data()[1]).text())

          return true
        onItem: (context, e) ->
          if e.target.tagName != 'SPAN'
            switch e.target.id
              when 'lnk_transfer_in' then window.open('/traffic/transfermanager/new', '_blank')
              when 'lnk_transfe_out' then window.open('/traffic/transfermanager/new', '_blank')
              when 'lnk_edit_tag' then window.location.href = '/traffic/transfermanager/' + $(row.data()[0]).text() + '/builddraw'
              when 'lnk_create_transfer' then window.location.href = '/traffic/transfermanager/new'
              when 'lnk_edit_transfer' then window.location.href = '/traffic/transfermanager/' + $(row.data()[1]).text() + '/edit'
              when 'lnk_do_adjustment' then window.open('/traffic/storageinspector/' + $(row.data()[0]).text() + '/adjustment', '_blank')
              when 'lnk_update_location' then console.log 'Update Location'

  # Inventory summary
  tbl_inventory_hdr = $('#tbl_inventory_hdr').dataTable
    aoColumnDefs: [
      {
        aTargets: [1]
        visible: false
      }
    ]
    bProcessing: true
    bServerSide: true
    deferRender: true
    lengthChange: false
    lengthMenu: [15, 30, 45, -1]
    ordering: false
    sAjaxSource: $('#tbl_inventory_hdr').data('source')
    searching: false
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
    fnServerParams: (aoData) ->
      if ft_storage_type
        aoData.push
          name: 'sSearch_C1'
          value: ft_storage_type

      if ft_storage
        aoData.push
          name: 'sSearch_C2'
          value: ft_storage

      if ft_level
        aoData.push
          name: 'sSearch_C3'
          value: ft_level

      if ft_owner
        aoData.push
          name: 'sSearch_C5'
          value: ft_owner

      if ft_company
        aoData.push
          name: 'sSearch_C6'
          value: ft_company

      aoData.push
        name: 'sSearch_C7'
        value: ft_open_qty

      return
    footerCallback: (row, data, start, end, display) ->
      api = this.api()

      if data.length > 0
        # Total Qty
        global_total_qty = api.column(6).data().reduce((a, b) ->
          return parseFloat(a) + parseFloat(b)
        )

        page_total_qty = api.column(6, { page: 'current' }).data().reduce((a, b) ->
          return parseFloat(a) + parseFloat(b)
        )

        $(api.column(6).footer()).html('' + page_total_qty.toFixed(2))

        # Total Bags
        global_total_bag = api.column(8).data().reduce((a, b) ->
          return parseFloat(a) + parseFloat(b)
        )

        page_total_bag = api.column(8, { page: 'current' }).data().reduce((a, b) ->
          return parseFloat(a) + parseFloat(b)
        )

        $(api.column(8).footer()).html('' + page_total_bag)
      else
        $(api.column(6).footer()).html('0')
        $(api.column(8).footer()).html('0')

  $('#inventory_storage_type').change ->
    storage_type_cd = $(this).val()

    if storage_type_cd
      $.ajax '/origin/inventorymanager/get_storage_by_type',
        dataType: 'script'
        data: {
          storage_type_cd: storage_type_cd
        }
        beforeSend: (xhr) ->
          ###
          Start progress animation
          ###
          $('.loading-spinner').removeClass('hidden').addClass('show')
    else
      $('#inventory_storage').empty()
      $('#inventory_storage').append($('<option></option>').attr('value', '').text('Which storage?'))

  $('#inventory_storage').change ->
    equipment_num = $(this).val()

    if equipment_num
      $.ajax '/origin/inventorymanager/get_level_by_equipment',
        dataType: 'script'
        data: {
          equipment_num: equipment_num
        }
        beforeSend: (xhr) ->
          ###
          Start progress animation
          ###
          $('.loading-spinner').removeClass('hidden').addClass('show')
    else
      $('#inventory_level').empty()
      $('#inventory_level').append($('<option></option>').attr('value', '').text('Which level?'))

  $('#inventory_open_qty').change ->
    if $(this).is(':checked')
      ft_open_qty = 'SUM([OPS_BUILD_DRAW].open_qty) > 0'
    else
      ft_open_qty = 'SUM([OPS_BUILD_DRAW].open_qty) <= 0'

  $('#btn_filter').on 'click', (e) ->
    e.preventDefault()

    ft_storage_type = $('#inventory_storage_type').val()
    ft_storage = $('#inventory_storage').val()
    ft_level = $('#inventory_level').val()
    ft_location = $('#inventory_location').val()
    ft_owner = $('#inventory_owner').val()
    ft_company = $('#inventory_internal_company').val()

    tbl_inventory_dtl.fnDraw()
    tbl_inventory_hdr.fnDraw()

    $('#btn_export_dtl').attr('href', '/origin/inventorymanager/inventory_dtl.xls?sSearch_C1=' + ft_storage_type + '&sSearch_C2=' + ft_storage + '&sSearch_C3=' + ft_level + '&sSearch_C4=' + ft_location + '&sSearch_C5=' + ft_owner + '&sSearch_C6=' + ft_company + '&sSearch_C7=' + ft_open_qty)
