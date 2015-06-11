# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  ###
  If transfer form is found, then we attach some other functions to input fields
  ###
  tef = document.getElementById('frm_edit_transfer')

  if tef

    it()

    $('#frm_edit_transfer').parsley().subscribe('parsley:form:validate', (f) ->
      f.submitEvent.preventDefault()

      $('#error_container').find('.parsley-errors-custom').remove()

      $('.alert-danger').removeClass('show').addClass('hidden')

      # Validate there are tags when transer from is a trade
      if $('#from_type_ind_e').val() == '0' and $('#tbl_transfer_tag_e > tbody > tr').length <= 0
        html = ''
        html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
        html += ' <li class="parsley-custom-error-message"><strong>Tags</strong> are required</li>'
        html += '</ul>'

        $('#error_container').append(html)

        $('.alert-danger').removeClass('hidden').addClass('show')

        return

      udf_from_success = true

      $('#pnl_udf_from table tbody tr').each ->
        r = $(this)

        udf_value = r.find('.col-2').val()

        if (!udf_value or udf_value == "") and udf_from_success
          udf_from_success = false

          return false

      udf_to_success = true

      $('#pnl_udf_to table tbody tr').each ->
        r = $(this)

        udf_value = r.find('.col-2').val()

        if (!udf_value or udf_value == "") and udf_to_success
          udf_to_success = false

          return false

      if !udf_from_success or !udf_to_success
        html = ''
        html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
        html += ' <li class="parsley-custom-error-message"><strong>UDFs cannot have empty values</strong></li>'
        html += '</ul>'

        $('#error_container').append(html)

        $('.alert-danger').removeClass('hidden').addClass('show')

        return

      if f.isValid('grp_transfer', false)
        if $('#from_type_ind_e').val() == '0' and $('#to_type_ind_e').val() == '1' # Transfer from trade to storage
          edit_transfer_from_trade_to_storage()
        else if $('#from_type_ind_e').val() == '0' and $('#to_type_ind_e').val() == '2' # Transfer from trade to vessel
          edit_transfer_from_trade_to_vessel()
        else if $('#from_type_ind_e').val() == '1' and $('#to_type_ind_e').val() == '0' # Transfer from storage to trade
          edit_transfer_from_storage_to_trade()
        else if $('#from_type_ind_e').val() == '1' and $('#to_type_ind_e').val() == '1' # Tansfer from storage to storage
          edit_transfer_from_storage_to_storage()
        else if $('#from_type_ind_e').val() == '1' and $('#to_type_ind_e').val() == '2' # Transfer from storage to vessel
          edit_transfer_from_storage_to_vessel()
        else if $('#from_type_ind_e').val() == '2' and $('#to_type_ind_e').val() == '0' # Transfer from vessel to trade
          edit_transfer_from_vessel_to_trade()
        else if $('#from_type_ind_e').val() == '2' and $('#to_type_ind_e').val() == '1' # Transfer from vessel to storage
          edit_transfer_from_vessel_to_storage()
        else
          console.log 'The combination of transfer you selected does not exist!'
        return

      $('.alert-danger').removeClass('hidden').addClass('show')
      return
    )

    #Setting converiton factor depending of the transfer type from and to
    if $('#from_type_ind_e').val() == '0' and $('#to_type_ind_e').val() == '1' # Transfer from trade to storage
      isk('from')
      get_conversion_factor_by_uom($('#from_contract_qty_uom_cd_e')[0].textContent,'from')
      get_conversion_factor_by_uom($('#to_storage_qty_uom_cd_e')[0].textContent,'to')
    else if $('#from_type_ind_e').val() == '0' and $('#to_type_ind_e').val() == '2' # Transfer from trade to vessel
      isk('from')
      get_conversion_factor_by_uom($('#from_contract_qty_uom_cd_e')[0].textContent,'from')
    else if $('#from_type_ind_e').val() == '1' and $('#to_type_ind_e').val() == '0' # Transfer from storage to trade
      isk('to')
      get_conversion_factor_by_uom($('#to_contract_qty_uom_cd_e')[0].textContent,'to')
      get_conversion_factor_by_uom($('#from_storage_qty_uom_cd_e')[0].textContent,'from')
    else if $('#from_type_ind_e').val() == '1' and $('#to_type_ind_e').val() == '1' # Tansfer from storage to storage
      get_conversion_factor_by_uom($('#from_storage_qty_uom_cd_e')[0].textContent,'from')
      get_conversion_factor_by_uom($('#to_storage_qty_uom_cd_e')[0].textContent,'to')
    else if $('#from_type_ind_e').val() == '1' and $('#to_type_ind_e').val() == '2' # Transfer from storage to vessel
      get_conversion_factor_by_uom($('#from_storage_qty_uom_cd_e')[0].textContent,'from')
    else if $('#from_type_ind_e').val() == '2' and $('#to_type_ind_e').val() == '0' # Transfer from vessel to trade
      isk('to')
      get_conversion_factor_by_uom($('#to_contract_qty_uom_cd_e')[0].textContent,'to')
    else if $('#from_type_ind_e').val() == '2' and $('#to_type_ind_e').val() == '1' # Transfer from vessel to storage
      get_conversion_factor_by_uom($('#to_storage_qty_uom_cd_e')[0].textContent,'to')
    else
      console.log 'The combination of transfer you selected does not exist!'

    if $('#pnl_udf_from table tbody tr').length > 0
      cuv('from')
      iura('from')

    if $('#pnl_udf_to table tbody tr').length > 0
      cuv('to')
      iura('to')

    # UDF functionality for from
    iua('from')

    # UDF functionality for to
    iua('to')

    $('#lnk_void_e').on 'click', (e) ->
      e.preventDefault()

      $.ajax('/traffic/transfermanager/validate_transfer_build_draw_tags',
        data: {
          id: $('#transfer_num').val()
        }
        type: 'GET'
        beforeSend: (xhr) ->
          ###
          Start progress animation
          ###
          $('.loading-spinner').removeClass('hidden').addClass('show')
      ).done (d) ->
        ###
        End progress animation
        ###
        $('.loading-spinner').removeClass('show').addClass('hidden')

        $('.alert-warning').removeClass('show').addClass('hidden')
        $('#warning_container').html('')

        if d.success == true
          show_confirm_dialog(new Object(title: 'Void Transfer ' + $('#transfer_num').val(), message_body: 'Are you sure about voiding this transfer?', param: $('#transfer_num').val(), method: '/traffic/transfermanager/cancel_transfer', message_response: '<strong>Transfer successfully voided!</strong> Transfer number:'))
        else
          $('#warning_container').html('<strong>' + d.message + '</strong>')
          $('.alert-warning').removeClass('hidden').addClass('show')

    if $('#from_type_ind_e').val() == '1'
      isc('from')
      ilc('from')

    if $('#to_type_ind_e').val() == '1'
      isc('to')
      ilc('to')

    $('#btn_add_tag_e').on 'click', (e) ->
      html = ''
      html += '<tr class="info">'
      html += ' <td class="col-1 hidden"></td>'
      html += ' <td class="col-2 hidden">'+$('#build_num_e').val()+'</td>'
      html += ' <td class="col-3 hidden">'+$('#to_storage_e').val()+'</td>'
      html += ' <td class="col-4 hidden">'+$('#s_to_level_e').val()+'</td>'
      html += ' <td class="col-5 ">Chop Data</td>'
      html += ' <td class="col-6"></td>'
      html += ' <td class="col-7"><input class="form-control col-7" value=""></td>'
      html += ' <td class="col-8"><input class="form-control col-8" value=""></td>'
      html += ' <td class="col-9"><input class="form-control col-9" value=""></td>'
      html += ' <td class="col-10"> <input class="form-control col-10" value=""></td>'
      html += ' <td class="col-11"><input class="form-control col-11" value="" disabled></td>'
      html += ' <td class="col-12"><input class="form-control col-12" value="" disabled></td>'
      html += ' <td class="col-13"> <input class="form-control col-13" value=""></td>'
      html += ' <td class="col-14"><input class="form-control col-14" value=""></td>'
      html += ' <td class="col-15"><input class="form-control col-15" value=""></td>'
      html += ' <td class="col-16">'+$('#to_storage_qty_uom_cd_e').text()+'</td>'
      html += ' <td class="col-17">0.00</td>'
      html += ' <td class="col-18 hidden">0</td>'
      html += ' <td><i class="glyphicon glyphicon-trash" data-placement="bottom" data-toggle="tooltip" style="cursor: pointer; margin-top: 8px;" title="Remove Tag"></i></td>'
      html += '</tr>'

      $('#tbl_transfer_tag_e').append(html)

      it()

    $('#btn_remove_tag_e').on 'click', (e) ->
      $('#tbl_transfer_tag_e > tbody').empty()

###
Change UDFs values
###
cuv = (source) ->
  tr = $(if source == 'from' then '#pnl_udf_from table tbody tr' else '#pnl_udf_to table tbody tr')

  $.each tr, (k, v) ->
    v_select = $(v).find('select.col-1')
    v_input = $(v).find('input.col-2')

    v_select_val = v_select.val()
    v_input_val = v_input.val()

    td = $(v).find('input.col-2').closest('td')
    td.empty()

    opt = $('option:selected', v_select)

    ref_value_ind = opt.attr('data-ref-value-ind')
    type_ind = opt.attr('data-type-ind')

    html = ''

    switch type_ind
      when '0'
        if ref_value_ind == '1'
          $.ajax('/common/util/get_udf_values_by_code',
            data: {
              udf_cd: v_select_val
            }
            beforeSend: (xhr) ->
              ###
              Start progress animation
              ###
              $('.loading-spinner').removeClass('hidden').addClass('show')
          ).done (d) ->
            ###
            Hide progress animation
            ###
            $('.loading-spinner').removeClass('show').addClass('hidden')

            if d
              html += '<select class="col-2 form-control">'

              $.each d, (k, v) ->
                html += '<option ' + (if v_input_val == v.udf_reference_value then "selected" else "") + ' value="' + v.udf_reference_value + '">' + v.udf_reference_value + "</option>"

              html += '</select>'

              td.append(html)
        else
          html += '<input class="col-2 form-control" type="text" value="' + v_input_val + '" />'
      when '1' then html += '<input class="col-2 form-control" type="text" />'
      when '2' then html += '<input class="col-2 form-control" min="0" type="number" step="any" value="' + v_input_val + '" />'
      when '3' then html += '<select class="col-2 form-control"><option ' + (if v_input_val == "YES" then "selected" else "") + ' value="YES">YES</option><option ' + (if v_input_val == "NO" then "selected" else "") + ' value="NO">NO</option></select>'
      when '4' then html += '<input class="col-2 form-control" type="date" value="' + v_input_val + '" />'

    if ref_value_ind != '1'
      td.append(html)

###
Initialize UDF action
###
iua = (source) ->
  if $(if source == 'from' then '#pnl_udf_from' else '#pnl_udf_to').length > 0
    $(if source == 'from' then '#pnl_udf_from button' else '#pnl_udf_to button').unbind('click')

    $(if source == 'from' then '#pnl_udf_from button' else '#pnl_udf_to button').bind 'click', (e) ->
      e.preventDefault()

      html = ''
      html += '<tr class="warning">'
      html += ' <td>'
      html += '   <select class="col-1 form-control">'

      options = $(if source == 'from' then '#from_type_udf_e option' else '#to_type_udf_e option').clone()
      $.each options, (k, v) ->
        data = $(v).data()

        html += '     <option data-ref-value-ind="' + data.refValueInd + '" data-type-ind="' + data.typeInd + '" value="' + $(v)[0].value + '">' + $(v).html() + '</option>'

      html += '   </select>'
      html += ' </td>'
      html += ' <td><input class="col-2 form-control" /></td>'
      html += ' <td><i class="glyphicon glyphicon-trash" style="cursor: pointer; margin-top: 8px;"></i></td>'
      html += '</tr>'

      $(if source == 'from' then '#pnl_udf_from table' else '#pnl_udf_to table').append(html)

      tr = $(if source == 'from' then '#pnl_udf_from table tbody tr:last' else '#pnl_udf_to table tbody tr:last')

      iuca(tr, source)
      iura(source)

###
Initialize UDF change type action
###
iuca = (tr, source) ->
  # console.log $(tr.find('select.col-1')).val()
  $(tr.find('select.col-1')).change ->
    val = $(this).val()

    td = tr.find('.col-2').closest('td')
    td.empty()

    opt = $('option:selected', this)

    ref_value_ind = opt.attr('data-ref-value-ind')
    type_ind = opt.attr('data-type-ind')

    html = ''

    switch type_ind
      when '0'
        if ref_value_ind == '1'
          $.ajax('/common/util/get_udf_values_by_code',
            data: {
              udf_cd: val
            }
            beforeSend: (xhr) ->
              ###
              Start progress animation
              ###
              $('.loading-spinner').removeClass('hidden').addClass('show')
          ).done (d) ->
            ###
            Hide progress animation
            ###
            $('.loading-spinner').removeClass('show').addClass('hidden')

            if d
              html += '<select class="col-2 form-control">'

              $.each d, (k, v) ->
                html += '<option value="' + v.udf_reference_value + '">' + v.udf_reference_value + "</option>"

              html += '</select>'

              td.append(html)
        else
          html += '<input class="col-2 form-control" type="text" />'
      when '1' then html += '<input class="col-2 form-control" type="text" />'
      when '2' then html += '<input class="col-2 form-control" type="number" />'
      when '3' then html += '<select class="col-2 form-control"><option value="YES">YES</option><option value="NO">NO</option></select>'
      when '4' then html += '<input class="col-2 form-control" type="date" />'

    if ref_value_ind != '1'
      td.append(html)

###
Initialize UDF remove action
###
iura = (source) ->
  $((if source == 'from' then '#pnl_udf_from' else '#pnl_udf_to') + ' table > tbody > tr > td').on 'click', 'i.glyphicon-trash', (e) ->
    e.preventDefault()

    tr = $(this).closest('tr')
    tr.remove()

    return false

###
Initialize schedule keyup function
###
isk = (source) ->
  $(if source == 'from' then '#from_scheduled_qty_e' else '#to_scheduled_qty_e').keyup ->
    open_qty = parseFloat($(if source == 'from' then '#from_open_qty_e' else '#to_open_qty_e').val())
    scheduled_qty = parseFloat($(this).val())

    if scheduled_qty <= open_qty
      $(if source == 'from' then '#from_nominal_qty_e' else '#to_nominal_qty_e').val($(this).val())

    else
      $(this).val('0.00')
      $(if source == 'from' then '#from_nominal_qty_e' else '#to_nominal_qty_e').val('0.00')

    #Calulate Converted Qty
    if source == 'from'
      calculateConvertQty(source)

###
Initialize tooltips from tags table
###
it = ->
  # Currently commented because it covers the remove action
  # $('#tbl_transfer_tag > tbody > tr > td > i[data-toggle="tooltip"]').tooltip()

  # Adding remove row event
  $('#tbl_transfer_tag_e > tbody > tr > td').on 'click', 'i.glyphicon-trash', (e) ->
    e.preventDefault()

    tr = $(this).closest('tr')
    tr.remove()

    return false

###
Initialize storage change function
###
isc = (source) ->
  $(document).on 'change', (if source == 'from' then '#from_storage_e' else '#to_storage_e'), (e) ->
    $.ajax '/traffic/transfermanager/' + (if source == 'from' then 'get_level_by_equipment_from' else 'get_level_by_equipment_to'),
      dataType: 'script'
      data: {
        query: $(if source == 'from' then '#from_storage_e' else '#to_storage_e').val()
      }
      beforeSend: (xhr) ->
        ###
        Start progress animation
        ###
        $('.loading-spinner').removeClass('hidden').addClass('show')
      success: (d) ->

        opt = $('option:selected', $(if source == 'from' then '#s_from_level_e' else '#s_to_level_e'))

        value = opt.attr('uom_cd')
        console.log value
        # Get conversion factor
        if value != undefined
          get_conversion_factor_by_uom_and_update(value, source)

###
Initialize level change function
###
ilc = (source) ->
  $(document).on 'change', (if source == 'from' then '#s_from_level_e' else '#s_to_level_e'), (e) ->
    $.ajax('/common/util/get_level_by_cargo',
      data: {
        id: $(if source == 'from' then '#s_from_level_e' else '#s_to_level_e').val()
      }
      beforeSend: (xhr) ->
        ###
        Start progress animation
        ###
        $('.loading-spinner').removeClass('hidden').addClass('show')
    ).done (d) ->
      ###
      Hide progress animation
      ###
      $('.loading-spinner').removeClass('show').addClass('hidden')

      if d
        $(if source == 'from' then '#s_from_commodity_e' else '#s_to_commodity_e').val(d.cmdty_cd)
        $(if source == 'from' then '#from_storage_qty_uom_cd_e' else '#to_storage_qty_uom_cd_e').text(d.qty_uom_cd)

        #Change tag Qty Uom to tags
        $('#tbl_transfer_tag_e tbody tr').each ->
          r = $(this)
          r.find('td.col-16').text(d.qty_uom_cd)

        # Get conversion factor
        get_conversion_factor_by_uom_and_update(d.qty_uom_cd, source)

  $(if source == 'from' then '#from_storage_qty_e' else '#to_storage_qty_e').keyup ->

    if source == 'from'
      calculateConvertQty(source)

###
Function edit_transfer_from_trade_to_storage
###
edit_transfer_from_trade_to_storage = ->
  $.ajax('/common/util/get_obligation_detail_by_obligation_and_transfer',
    data: {
      obligation_num: $('#obligation_num_e').val()
      transfer_num: $('#transfer_num').val()
    }
    type: 'GET'
    beforeSend: (xhr) ->
      $('.overlay').removeClass('hidden').addClass('show')

      ###
      Start progress animation
      ###
      $('.loading-spinner').removeClass('hidden').addClass('show')
  ).done (response) ->
    # Collect tags
    tag = new Array()

    $('#tbl_transfer_tag_e tbody tr').each ->
      r = $(this)

      v_tag = new Object()

      if ($('#initial_equipment_num_to').val() != $('#to_storage_e').val()) or ($('#initial_cargo_num_to').val() != $('#s_to_level_e').val())
        v_tag.bd_tag_num = ''
        v_tag.cargo_num = $('#s_to_level_e').val()
        v_tag.chop_id = ''
        v_tag.tag_source_ind = ''
        v_tag.validate_reqd_soft_ind = 1
        v_tag.build_draw_type_ind = ''
        v_tag.build_draw_ind = ''
        v_tag.tag_adj_qty = ''
      else
        v_tag.bd_tag_num = r.find('td.col-1').text()
        v_tag.cargo_num = r.find('td.col-4').text()
        v_tag.chop_id = r.find('td.col-6').text()
        v_tag.tag_source_ind = 0
        v_tag.validate_reqd_soft_ind = 0
        v_tag.build_draw_type_ind = 2
        v_tag.build_draw_ind = 0
        v_tag.tag_adj_qty = 0

      v_tag.build_draw_num = r.find('td.col-2').text()
      v_tag.equipment_num = r.find('td.col-3').text()
      v_tag.tag_type_cd = r.find('td.col-5').text()
      v_tag.tag_value1 = r.find('td.col-7 input').val()
      v_tag.tag_value2 = r.find('td.col-8 input').val()
      v_tag.tag_value3 = r.find('td.col-9 input').val()
      v_tag.tag_value4 = r.find('td.col-10 input').val()
      v_tag.tag_value7 = r.find('td.col-13 input').val()
      v_tag.tag_value8 = r.find('td.col-14 input').val()
      v_tag.tag_qty_uom_cd = r.find('td.col-16').text()
      v_tag.tag_alloc_qty = r.find('td.col-17').text()
      v_tag.tag_qty = r.find('td.col-15 input').val()
      v_tag.split_src_tag_num = r.find('td.col-18').text()

      tag.push(v_tag)

    # Collect UDFs
    udf = new Array()

    $('#pnl_udf_from table tbody tr').each ->
      r = $(this)

      opt = $('option:selected', r.find('select.col-1'))

      type_ind = opt.attr('data-type-ind')

      v_udf = new Object()
      v_udf.udf_cd = r.find('select.col-1').val()

      udf_value = r.find('.col-2').val()

      if type_ind == '4'
        dt = new Date(udf_value)

        day = dt.getDate() + 1
        month = dt.getMonth() + 1
        year = dt.getFullYear()

        v_udf.udf_value = month + '/' + day + '/' + year
      else
        v_udf.udf_value = udf_value

      v_udf.to_from_ind = 1

      udf.push(v_udf)

    $('#pnl_udf_to table tbody tr').each ->
      r = $(this)

      opt = $('option:selected', r.find('select.col-1'))

      type_ind = opt.attr('data-type-ind')

      v_udf = new Object()
      v_udf.udf_cd = r.find('select.col-1').val()

      udf_value = r.find('.col-2').val()

      if type_ind == '4'
        dt = new Date(udf_value)

        day = dt.getDate() + 1
        month = dt.getMonth() + 1
        year = dt.getFullYear()

        v_udf.udf_value = month + '/' + day + '/' + year
      else
        v_udf.udf_value = udf_value

      v_udf.to_from_ind = 0

      udf.push(v_udf)

    $.ajax('/traffic/transfermanager/edit_transfer_from_trade_to_storage',
      data: {
        transfer_num: $('#transfer_num').val()
        from_type_ind: $('#from_type_ind_e').val()
        to_type_ind: $('#to_type_ind_e').val()
        location_num: $('#location_num_e').val()
        operator_person_num: $('#operator_person_num_e').val()
        transfer_comm_dt: $('#transfer_comm_dt_e').val()
        transfer_comp_dt: $('#transfer_comp_dt_e').val()
        application_dt: $('#application_dt_e').val()
        obligation_num: $('#obligation_num_e').val()
        from_qty: $('#from_scheduled_qty_e').val()
        from_uom: $('#from_open_qty_uom_cd_e').text()
        to_equipment_num: $('#to_storage_e').val()
        to_cargo_num: $('#s_to_level_e').val()
        to_qty: $('#to_storage_qty_e').val()
        to_uom: $('#to_storage_qty_uom_cd_e').text()
        term_section_cd: $('#term_section_cd_e').val()
        effective_dt: $('#effective_dt_e').val()
        build_num: $('#build_num_e').val()
        bl_num_cd: $('#bl_num_cd_e').val()
        bl_dt: $('#bl_dt_e').val()
        from_internal_company_num: $('#from_internal_company_num_e').val()
        to_internal_company_num: $('#to_internal_company_num_e').val()
        obligation_detail_num: response.obligation_dtl[0].obligation_detail_num
        title_transfer_loc_num: response.obligation_dtl[0].title_transfer_loc_num
        title_transfer_dt: response.obligation_dtl[0].title_transfer_dt
        importer_exporter_ind: response.obligation_dtl[0].importer_exporter_ind
        cross_conv_factor: response.obligation_dtl[0].cross_conv_factor
        loi_status_ind: response.obligation_dtl[0].loi_status_ind
        trade_price: $('#trade_price_e').val()
        trade_price_uom_cd: $('#trade_price_uom_cd_e').val()
        trade_price_curr_cd: $('#trade_price_curr_cd_e').val()
        settlement_amount: response.stl_item_hdr[0].extended_amt
        price: response.obligation_dtl[0].price
        tag: tag
        lockinfo: $('#lockinfo').val()
        daily_build_draw_num: $('#daily_build_draw_num_e_to').val()
        daily_detail_dt: $('#daily_detail_dt_e_to').val()
        daily_cargo_num: $('#daily_cargo_num_e_to').val()
        daily_equipment_num: $('#daily_equipment_num_e_to').val()
        daily_cmdty_cd: $('#daily_cmdty_cd_e_to').val()
        daily_trade_num: $('#daily_trade_num_e_to').val()
        daily_term_section_cd: $('#daily_term_section_cd_e_to').val()
        daily_detail_qty: $('#daily_detail_qty_e_to').val()
        daily_detail_mass_qty: $('#daily_detail_mass_qty_e_to').val()
        daily_detail_vol_qty: $('#daily_detail_vol_qty_e_to').val()
        daily_company_num: $('#daily_company_num_e_to').val()
        udf: udf
      }
      type: 'POST'
    ).done (d) ->
      ###
      Hide progress animation
      ###
      $('.loading-spinner').removeClass('show').addClass('hidden')

      show_save_transfer_response(d)

###
Function edit_transfer_from_trade_to_vessel
###
edit_transfer_from_trade_to_vessel = ->
  console.log 'edit_transfer_from_trade_to_vessel'

###
Function edit_transfer_from_storage_to_trade
###
edit_transfer_from_storage_to_trade = ->
  $.ajax('/common/util/get_obligation_detail_by_obligation_and_transfer',
    data: {
      obligation_num: $('#obligation_num_e').val()
      transfer_num: $('#transfer_num').val()
    }
    type: 'GET'
    beforeSend: (xhr) ->
      $('.overlay').removeClass('hidden').addClass('show')

      ###
      Start progress animation
      ###
      $('.loading-spinner').removeClass('hidden').addClass('show')
  ).done (response) ->
    # Collect UDFs
    udf = new Array()

    $('#pnl_udf_from table tbody tr').each ->
      r = $(this)

      opt = $('option:selected', r.find('select.col-1'))

      type_ind = opt.attr('data-type-ind')

      v_udf = new Object()
      v_udf.udf_cd = r.find('select.col-1').val()

      udf_value = r.find('.col-2').val()

      if type_ind == '4'
        dt = new Date(udf_value)

        day = dt.getDate() + 1
        month = dt.getMonth() + 1
        year = dt.getFullYear()

        v_udf.udf_value = month + '/' + day + '/' + year
      else
        v_udf.udf_value = udf_value

      v_udf.to_from_ind = 1

      udf.push(v_udf)

    $('#pnl_udf_to table tbody tr').each ->
      r = $(this)

      opt = $('option:selected', r.find('select.col-1'))

      type_ind = opt.attr('data-type-ind')

      v_udf = new Object()
      v_udf.udf_cd = r.find('select.col-1').val()

      udf_value = r.find('.col-2').val()

      if type_ind == '4'
        dt = new Date(udf_value)

        day = dt.getDate() + 1
        month = dt.getMonth() + 1
        year = dt.getFullYear()

        v_udf.udf_value = month + '/' + day + '/' + year
      else
        v_udf.udf_value = udf_value

      v_udf.to_from_ind = 0

      udf.push(v_udf)

    #Add uom Convertion and muliply/divide
    #Get information of convertion factor and convertion indicator
    #Three cases
    #1. When uom from and to are equal cxl multiply or divide by 1
    #2. When to is MT it divide the from value with its convertion factor
    #3. When from are to are different it multiply the from value 
    # using a factor calculated (to_convertion_factor / from_convertion_factor)
    if($('#from_storage_qty_uom_cd_e').text()==$('#to_open_qty_uom_cd_e').text())
      uom_conv_factor = 1
      uom_conv_factor_ind = 0 #Multiply
    else if ($('#to_open_qty_uom_cd_e').text()=='MT')
      uom_conv_factor = $('#from_convertion_factor').val()
      uom_conv_factor_ind = 1 #Divide
    else
      uom_conv_factor = parseFloat($('#to_convertion_factor').val())/parseFloat($('#from_convertion_factor').val())
      uom_conv_factor_ind = 0 #multiply

    $.ajax('/traffic/transfermanager/edit_transfer_from_storage_to_trade',
      data: {
        transfer_num: $('#transfer_num').val()
        from_type_ind: $('#from_type_ind_e').val()
        to_type_ind: $('#to_type_ind_e').val()
        location_num: $('#location_num_e').val()
        operator_person_num: $('#operator_person_num_e').val()
        transfer_comm_dt: $('#transfer_comm_dt_e').val()
        transfer_comp_dt: $('#transfer_comp_dt_e').val()
        application_dt: $('#application_dt_e').val()
        obligation_num: $('#obligation_num_e').val()
        from_equipment_num: $('#from_storage_e').val()
        from_cargo_num: $('#s_from_level_e').val()
        from_qty: $('#from_storage_qty_e').val()
        from_uom: $('#from_storage_qty_uom_cd_e').text()
        to_qty: $('#to_scheduled_qty_e').val()
        to_uom: $('#to_open_qty_uom_cd_e').text()
        term_section_cd: $('#term_section_cd_e').val()
        effective_dt: $('#effective_dt_e').val()
        draw_num: $('#draw_num_e').val()
        bl_num_cd: $('#bl_num_cd_e').val()
        bl_dt: $('#bl_dt_e').val()
        from_internal_company_num: $('#from_internal_company_num_e').val()
        to_internal_company_num: $('#to_internal_company_num_e').val()
        obligation_detail_num: response.obligation_dtl[0].obligation_detail_num
        title_transfer_loc_num: response.obligation_dtl[0].title_transfer_loc_num
        title_transfer_dt: response.obligation_dtl[0].title_transfer_dt
        importer_exporter_ind: response.obligation_dtl[0].importer_exporter_ind
        cross_conv_factor: response.obligation_dtl[0].cross_conv_factor
        loi_status_ind: response.obligation_dtl[0].loi_status_ind
        trade_price_uom_cd: $('#trade_price_uom_cd_e').val()
        trade_price_curr_cd: $('#trade_price_curr_cd_e').val()
        daily_build_draw_num: $('#daily_build_draw_num_e_from').val()
        daily_detail_dt: $('#daily_detail_dt_e_from').val()
        daily_cargo_num: $('#daily_cargo_num_e_from').val()
        daily_equipment_num: $('#daily_equipment_num_e_from').val()
        daily_cmdty_cd: $('#daily_cmdty_cd_e_from').val()
        daily_trade_num: $('#daily_trade_num_e_from').val()
        daily_term_section_cd: $('#daily_term_section_cd_e_from').val()
        daily_detail_qty: $('#daily_detail_qty_e_from').val()
        daily_detail_mass_qty: $('#daily_detail_mass_qty_e_from').val()
        daily_detail_vol_qty: $('#daily_detail_vol_qty_e_from').val()
        daily_company_num: $('#daily_company_num_e_from').val()
        lockinfo: $('#lockinfo').val()
        udf: udf
        uom_conv_factor: uom_conv_factor
        uom_conv_factor_ind: uom_conv_factor_ind
      }
      type: 'POST'
    ).done (d) ->
      ###
      Hide progress animation
      ###
      $('.loading-spinner').removeClass('show').addClass('hidden')

      show_save_transfer_response(d)

###
Function edit_transfer_from_storage_to_storage
###
edit_transfer_from_storage_to_storage = ->
  transfer_daily_detail = new Array()

  v_daily_detail1 = new Object()
  v_daily_detail1.build_draw_num = $('#daily_build_draw_num_e_from').val()
  v_daily_detail1.daily_detail_dt = $('#daily_detail_dt_e_from').val()
  v_daily_detail1.cargo_num = $('#daily_cargo_num_e_from').val()
  v_daily_detail1.equipment_num = $('#daily_equipment_num_e_from').val()
  v_daily_detail1.cmdty_cd = $('#daily_cmdty_cd_e_from').val()
  v_daily_detail1.daily_detail_qty = $('#daily_detail_qty_e_from').val()
  v_daily_detail1.daily_detail_mass_qty = $('#daily_detail_mass_qty_e_from').val()
  v_daily_detail1.daily_detail_vol_qty = $('#daily_detail_vol_qty_e_from').val()
  v_daily_detail1.build_draw_ind = $('#daily_build_draw_ind_e_from').val()

  transfer_daily_detail.push(v_daily_detail1)

  v_daily_detail2 = new Object()
  v_daily_detail2.build_draw_num = $('#daily_build_draw_num_e_to').val()
  v_daily_detail2.daily_detail_dt = $('#daily_detail_dt_e_to').val()
  v_daily_detail2.cargo_num = $('#daily_cargo_num_e_to').val()
  v_daily_detail2.equipment_num = $('#daily_equipment_num_e_to').val()
  v_daily_detail2.cmdty_cd = $('#daily_cmdty_cd_e_to').val()
  v_daily_detail2.daily_detail_qty = $('#daily_detail_qty_e_to').val()
  v_daily_detail2.daily_detail_mass_qty = $('#daily_detail_mass_qty_e_to').val()
  v_daily_detail2.daily_detail_vol_qty = $('#daily_detail_vol_qty_e_to').val()
  v_daily_detail2.build_draw_ind = $('#daily_build_draw_ind_e_to').val()

  transfer_daily_detail.push(v_daily_detail2)

  # Collect UDFs
  udf = new Array()

  $('#pnl_udf_from table tbody tr').each ->
    r = $(this)

    opt = $('option:selected', r.find('select.col-1'))

    type_ind = opt.attr('data-type-ind')

    v_udf = new Object()
    v_udf.udf_cd = r.find('select.col-1').val()

    udf_value = r.find('.col-2').val()

    if type_ind == '4'
      dt = new Date(udf_value)

      day = dt.getDate() + 1
      month = dt.getMonth() + 1
      year = dt.getFullYear()

      v_udf.udf_value = month + '/' + day + '/' + year
    else
      v_udf.udf_value = udf_value

    v_udf.to_from_ind = 1

    udf.push(v_udf)

  $('#pnl_udf_to table tbody tr').each ->
    r = $(this)

    opt = $('option:selected', r.find('select.col-1'))

    type_ind = opt.attr('data-type-ind')

    v_udf = new Object()
    v_udf.udf_cd = r.find('select.col-1').val()

    udf_value = r.find('.col-2').val()

    if type_ind == '4'
      dt = new Date(udf_value)

      day = dt.getDate() + 1
      month = dt.getMonth() + 1
      year = dt.getFullYear()

      v_udf.udf_value = month + '/' + day + '/' + year
    else
      v_udf.udf_value = udf_value

    v_udf.to_from_ind = 0

    udf.push(v_udf)

  #Add uom Convertion and muliply/divide
  #Get information of convertion factor and convertion indicator
  #Three cases
  #1. When uom from and to are equal cxl multiply or divide by 1
  #2. When to is MT it divide the from value with its convertion factor
  #3. When from are to are different it multiply the from value 
  # using a factor calculated (to_convertion_factor / from_convertion_factor)
  if($('#from_storage_qty_uom_cd_e').text()==$('#to_storage_qty_uom_cd_e').text())
    uom_conv_factor = 1
    uom_conv_factor_ind = 0 #Multiply
  else if ($('#to_storage_qty_uom_cd_e').text()=='MT')
    uom_conv_factor = $('#from_convertion_factor').val()
    uom_conv_factor_ind = 1 #Divide
  else
    uom_conv_factor = parseFloat($('#to_convertion_factor').val())/parseFloat($('#from_convertion_factor').val())
    uom_conv_factor_ind = 0 #multiply

  $.ajax('/traffic/transfermanager/edit_transfer_from_storage_to_storage',
    data: {
      transfer_num: $('#transfer_num').val()
      from_type_ind: $('#from_type_ind_e').val()
      to_type_ind: $('#to_type_ind_e').val()
      location_num: $('#location_num_e').val()
      operator_person_num: $('#operator_person_num_e').val()
      transfer_comm_dt: $('#transfer_comm_dt_e').val()
      transfer_comp_dt: $('#transfer_comp_dt_e').val()
      application_dt: $('#application_dt_e').val()
      from_equipment_num: $('#from_storage_e').val()
      from_cargo_num: $('#s_from_level_e').val()
      from_qty: $('#from_storage_qty_e').val()
      from_uom: $('#from_storage_qty_uom_cd_e').text()
      to_equipment_num: $('#to_storage_e').val()
      to_cargo_num: $('#s_to_level_e').val()
      to_qty: $('#to_storage_qty_e').val()
      to_uom: $('#to_storage_qty_uom_cd_e').text()
      effective_dt: $('#effective_dt_e').val()
      build_num: $('#build_num_e').val()
      draw_num: $('#draw_num_e').val()
      bl_num_cd: $('#bl_num_cd_e').val()
      bl_dt: $('#bl_dt_e').val()
      from_internal_company_num: $('#from_internal_company_num_e').val()
      to_internal_company_num: $('#to_internal_company_num_e').val()
      transfer_daily_detail: transfer_daily_detail
      lockinfo: $('#lockinfo').val()
      udf: udf
      uom_conv_factor: uom_conv_factor
      uom_conv_factor_ind: uom_conv_factor_ind
    }
    type: 'POST'
    beforeSend: (xhr) ->
      $('.overlay').removeClass('hidden').addClass('show')

      ###
      Start progress animation
      ###
      $('.loading-spinner').removeClass('hidden').addClass('show')
  ).done (d) ->
    ###
    Hide progress animation
    ###
    $('.loading-spinner').removeClass('show').addClass('hidden')

    show_save_transfer_response(d)

###
Function edit_transfer_from_storage_to_vessel
###
edit_transfer_from_storage_to_vessel = ->
  console.log 'edit_transfer_from_storage_to_vessel'

###
Function edit_transfer_from_vessel_to_trade
###
edit_transfer_from_vessel_to_trade = ->
  console.log 'edit_transfer_from_vessel_to_trade'

###
Function edit_transfer_from_vessel_to_storage
###
edit_from_vessel_to_storage = ->
  console.log 'edit_transfer_from_vessel_to_storage'

show_save_transfer_response = (r) ->
  $('.alert-danger').removeClass('show').addClass('hidden')
  $('.alert-success').removeClass('show').addClass('hidden')

  $('#error_container').html('')
  $('#success_container').html('')

  if r.success == true
    html = ''
    html += '<strong>Transfer successfully edited!</strong> Transfer number: <a class="alert-link" data-no-turbolink="true" href="/traffic/transfermanager/' + r.id + '">' + r.id + '</a>'
    html += '<div class="clearfix"></div>'
    html += '<br />'
    html += '<a class="btn btn-success btn-sm" data-no-turbolink="true" href="/traffic/transfermanager/new" role="button" style="margin-right: 10px;">New Transfer</a>'
    html += '<a class="btn btn-warning btn-sm" data-no-turbolink="true" href="/traffic/transfermanager/' + r.id + '/edit" role="button" style="margin-right: 10px;">Edit Transfer</a>'
    html += '<a class="btn btn-primary btn-sm" data-no-turbolink="true" href="/traffic/transfermanager/' + r.id + '/allocation" role="button">Allocate Tags</a>'

    $('#success_container').html(html)

    $('.alert-success').removeClass('hidden').addClass('show')
  else
    $('.overlay').removeClass('show').addClass('hidden')

    $('#error_container').html('<strong>' + r.message + '</strong>')

    $('.alert-danger').removeClass('hidden').addClass('show')

show_confirm_dialog = (obj) ->
  $('#btn_save_modal').unbind('click')

  $('div.modal-header > h4.modal-title').text(obj.title)
  $('div.modal-body > p').text(obj.message_body)
  $('.modal').removeClass('hidden').addClass('show')

  $('#btn_save_modal').bind 'click', (e) ->
    $.ajax(obj.method,
      data: {
        id: obj.param
      }
      type: 'POST'
      beforeSend: (xhr) ->
        $('.modal').removeClass('show').addClass('hidden')
        $('.overlay').removeClass('hidden').addClass('show')

        ###
        Start progress animation
        ###
        $('.loading-spinner').removeClass('hidden').addClass('show')
    ).done (d) ->
      ###
      Hide progress animation
      ###
      $('.loading-spinner').removeClass('show').addClass('hidden')

      $('.alert-danger').removeClass('show').addClass('hidden')
      $('.alert-success').removeClass('show').addClass('hidden')

      $('#error_container').html('')
      $('#success_container').html('')

      if d.success == true
        html = ''
        html += obj.message_response + ' ' + d.id
        html += '<div class="clearfix"></div>'
        html += '<br />'
        html += '<a class="btn btn-success btn-sm" data-no-turbolink="true" href="/traffic/transfermanager/' + obj.param + '" role="button">Ok</a>'

        $('#success_container').html(html)

        $('.alert-success').removeClass('hidden').addClass('show')
      else
        $('#error_container').html('<strong>' + d.message + '</strong>')

        $('.alert-danger').removeClass('hidden').addClass('show')


####################################################################################################################
#Convertion function
get_conversion_factor_by_uom_and_update = (uom, source) ->
  $.ajax('/common/util/get_convertion_factor_by_uom',
    data: {
      uom_cd: uom
    }
    type: 'GET'
  ).done (d) ->
    ###
    End progress animation
    ###
    $('.loading-spinner').removeClass('show').addClass('hidden')

    if d.success == true
      $(if source == 'from' then '#from_convertion_factor' else '#to_convertion_factor').val(d.factor[0].uom_factor)
    else
      $(if source == 'from' then '#from_convertion_factor' else '#to_convertion_factor').val('')

    console.log 'Convertion factor for [' + source + '] side changed to ' + d.factor[0].uom_factor

    calculateConvertQty(source)

get_conversion_factor_by_uom = (uom, source) ->
  $.ajax('/common/util/get_convertion_factor_by_uom',
    data: {
      uom_cd: uom
    }
    type: 'GET'
  ).done (d) ->
    ###
    End progress animation
    ###
    $('.loading-spinner').removeClass('show').addClass('hidden')

    if d.success == true
      $(if source == 'from' then '#from_convertion_factor' else '#to_convertion_factor').val(d.factor[0].uom_factor)
    else
      $(if source == 'from' then '#from_convertion_factor' else '#to_convertion_factor').val(1)

    console.log 'Convertion factor for [' + source + '] side changed to ' + d.factor[0].uom_factor


####Funciton to set input with the converted value
calculateConvertQty = (source) ->

    from_convertion = parseFloat($('#from_convertion_factor').val())
    to_convertion = parseFloat($('#to_convertion_factor').val())
    value =

    convertQty = 0.00

    # Asign Value to convert
    switch $('#from_type_ind_e')[0].value
      when "0" then value = parseFloat($('#from_scheduled_qty_e').val())
      when "1" then value = parseFloat($('#from_storage_qty_e').val())

    # validate if all values are valid

    if isNaN(value)
      console.log 'Value is not valid' #User value
      return

    if isNaN(from_convertion)
      console.log 'Value from_convertion_factor is not valid' #from convertion value
      return

    if isNaN(to_convertion)
      console.log 'Value to_convertion_factor is not valid' #to convertion value
      return

    #Convert value
    switch $('#from_type_ind_e')[0].value
      when "0" then convertQty = ( parseFloat($('#from_scheduled_qty_e').val()) / from_convertion ) * (to_convertion)
      when "1" then convertQty = ( parseFloat($('#from_storage_qty_e').val()) / from_convertion ) * (to_convertion)

    switch $('#to_type_ind_e')[0].value
      when "0"
        $('#to_scheduled_qty_e').val(convertQty.toFixed(4))
        $('#to_nominal_qty_e').val(convertQty.toFixed(4))
      when "1"
        $('#to_storage_qty_e').val(convertQty.toFixed(4))
