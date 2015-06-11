# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

global_build_draw = new Object()

jQuery ->
  if $('#frm_adjustment').length > 0
    $('#frm_adjustment').parsley().subscribe('parsley:form:validate', (f) ->
      f.submitEvent.preventDefault()

      $('#error_container').find('.parsley-errors-custom').remove()

      $('.alert-danger').removeClass('show').addClass('hidden')

      if f.isValid('grp_adjustment', false)
        $('.alert-danger').removeClass('show').addClass('hidden')

        #Validate that there is no adjustments new in clx
        response = checkLevelQty($('#adjustment_level').val())
        band = true
        if !response.success
          html = ''
          html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
          html += ' <li class="parsley-custom-error-message"><strong>Error validating CXL qty.</strong> Please try again</li>'
          html += '</ul>'

          $('#error_container').append(html)

          $('.alert-danger').removeClass('hidden').addClass('show')

          band = false
        else if decimalAdjust('round', +response.responseJSON.before_qty, -2).toFixed(2) != decimalAdjust('round', +$('#lgd_after_adjustment_qty').text(), -2).toFixed(2)

          #Void Build to allow user to refresh window to get updated tag information
          $.ajax('/traffic/storageinspector/cancel_cargo_adjustment',
            data: {
            id: $('#lgd_build_draw').text()
            }
            type: 'POST'
            async: false
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

            #Show message or error
            html = ''
            html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
            html += ' <li class="parsley-custom-error-message"><strong>Level has been updated by another user.</strong> Please reload and try again </li>'
            html += ' <li class="parsley-custom-error-message"><strong>Adjustment build is now voided </strong></li>'
            html += '</ul>'
            html += '<a class="btn btn-error btn-sm" data-no-turbolink="true" href="' + window.location + '" role="button">Ok</a>'

            $('#error_container').append(html)

            $('.alert-danger').removeClass('hidden').addClass('show')

            band = false

            console.log 'voided'

        console.log 'validatin'
        if band
          create_adjustment()
        else
          return

      return
    )

    psc($('#adjustment_storage').val())

    # Storage change event
    $('#adjustment_storage').change ->
      psc($(this).val())

    # Level change event
    $('#adjustment_level').change ->
      cargo_num = $('#adjustment_level').val()

      if cargo_num
        $.ajax('/traffic/storageinspector/get_empty_cargo_adjustment',
          data: {
            cargo_num: cargo_num
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

          if d.success
            # Setting quantity value on hidden fields
            $('#before_qty').val(d.before_qty)
            $('#effective_dt').val(d.effective_dt)

            # Setting quantity value on legends
            $('#lgd_before_adjustment_qty').text(decimalAdjust('round', $('#before_qty').val(), -2).toFixed(2).toString())
            $('#lgd_after_adjustment_qty').text(decimalAdjust('round', $('#before_qty').val(), -2).toFixed(2).toString())

    # Gain/Loss qty
    $('#adjustment_qty').keyup (e) ->
      adjustment_qty = +$(this).val()

      if !isNaN(adjustment_qty)
        before_qty = +$('#before_qty').val()
        after_qty = before_qty + adjustment_qty

        $('#lgd_after_adjustment_qty').text(decimalAdjust('round', after_qty, -2).toFixed(2).toString())
      else
        before_qty = +$('#before_qty').val()

        $('#lgd_after_adjustment_qty').text(decimalAdjust('round', before_qty, -2).toFixed(2).toString())

    # Create adjustment
    $('#btn_create_adjustment').on 'click', (e) ->
      e.preventDefault()

      $('#error_container').find('.parsley-errors-custom').remove()

      $('.alert-danger').removeClass('show').addClass('hidden')

      if !$('#frm_adjustment').parsley().isValid('grp_adjustment', false)
        html = ''
        html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
        html += ' <li class="parsley-custom-error-message"><strong>Gain/Loss Qty</strong> is required</li>'
        html += '</ul>'

        $('#error_container').append(html)

        $('.alert-danger').removeClass('hidden').addClass('show')
        return

      #Validate that there is no adjustments new in clx
      response = checkLevelQty($('#adjustment_level').val())
      if !response.success
        html = ''
        html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
        html += ' <li class="parsley-custom-error-message"><strong>Error validating CXL qty.</strong> Please try again </li>'
        html += '</ul>'

        $('#error_container').append(html)

        $('.alert-danger').removeClass('hidden').addClass('show')

        return
      else if decimalAdjust('round', +response.responseJSON.before_qty, -2).toFixed(2) != decimalAdjust('round', +$('#lgd_before_adjustment_qty').text(), -2).toFixed(2)
        html = ''
        html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
        html += ' <li class="parsley-custom-error-message"><strong>Level has been updated by another user.</strong> Please reload and try again </li>'
        html += '</ul>'

        $('#error_container').append(html)

        $('.alert-danger').removeClass('hidden').addClass('show')

        return

      #Create adjustment
      $.ajax('/traffic/storageinspector/put_cargo_adjustment',
        data: {
          cargo_num: $('#adjustment_level').val()
          effective_dt: $('#effective_dt').val()
          actual_qty: $('#adjustment_qty').val()
        }
        type: 'POST'
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

        #Disabled Create Adjustment Btn
        $('#btn_create_adjustment').addClass('disabled')

        if d.success
          $('#lgd_build_draw').text(d.id)
          $('#lgd_before_gain_loss_qty').text(decimalAdjust('round', +$('#adjustment_qty').val(), -2).toFixed(2).toString())
          $('.gain-loss-legend').removeClass('hidden').addClass('show')

          global_build_draw = null
          global_build_draw = new Object()
          global_build_draw.build_draw_num = d.build_draw.build_draw_num
          global_build_draw.build_draw_ind = d.build_draw.build_draw_ind
          global_build_draw.location_num = d.build_draw.location_num
          global_build_draw.trade_num = d.build_draw.trade_num
          global_build_draw.obligation_num = d.build_draw.obligation_num
          global_build_draw.transfer_start_dt = d.build_draw.transfer_start_dt
          global_build_draw.transfer_end_dt = d.build_draw.transfer_end_dt
          global_build_draw.build_draw_qty = d.build_draw.build_draw_qty
          global_build_draw.open_qty = d.build_draw.open_qty
          global_build_draw.transfer_price = d.build_draw.transfer_price
          global_build_draw.per_unit_cost = d.build_draw.per_unit_cost
          global_build_draw.build_draw_type_ind = d.build_draw.build_draw_type_ind
          global_build_draw.strategy_num = d.build_draw.strategy_num
          global_build_draw.obligation_detail_num = d.build_draw.obligation_detail_num
          global_build_draw.transfer_num = d.build_draw.transfer_num
          global_build_draw.transfer_at_ind = d.build_draw.transfer_at_ind
          global_build_draw.transfer_price_status_ind = d.build_draw.transfer_price_status_ind
          global_build_draw.net_qty = d.build_draw.net_qty
          global_build_draw.cargo_qty = d.build_draw.cargo_qty
          global_build_draw.packaging_qty = d.build_draw.packaging_qty
          global_build_draw.base_vol = d.build_draw.base_vol
          global_build_draw.base_mass = d.build_draw.base_mass
          global_build_draw.filled_ind = d.build_draw.filled_ind
          global_build_draw.weighted_avg = d.build_draw.weighted_avg
          global_build_draw.import_ind = d.build_draw.import_ind
          global_build_draw.import_type_ind = d.build_draw.import_type_ind
          global_build_draw.mtm_price = d.build_draw.mtm_price
          global_build_draw.p_l_value = d.build_draw.p_l_value
          global_build_draw.price_locked_ind = d.build_draw.price_locked_ind
          global_build_draw.last_modify_dt = d.build_draw.last_modify_dt
          global_build_draw.modify_person_num = d.build_draw.modify_person_num
          # is_tag_qty_non_zero_ind
          global_build_draw.gain_loss_factor = d.build_draw.gain_loss_factor
          global_build_draw.transfer_cost = d.build_draw.transfer_cost
          global_build_draw.delivery_active_status_ind = d.build_draw.delivery_active_status_ind
          global_build_draw.delivery_dt_mtm_ind = d.build_draw.delivery_dt_mtm_ind
          # conf_warning_ind
          global_build_draw.transfer_split_ind = d.build_draw.transfer_split_ind
          global_build_draw.commodity_cost = d.build_draw.commodity_cost
          global_build_draw.sap_cur_bal_ind = d.build_draw.sap_cur_bal_ind
          global_build_draw.effective_dt = d.build_draw.effective_dt
          global_build_draw.cmdty_cd = d.build_draw.cmdty_cd
          global_build_draw.tag = []

    # Adjustment tag
    tbl_adjustment_tag = $('#tbl_adjustment_tag').dataTable
      aoColumnDefs: [
        {
          aTargets: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63]
          visible: false
        }
      ]
      info: false
      lengthChange: false
      lengthMenu: [10, 30, 50, -1]
      ordering: false

    # Void build/draw
    $('#btn_void_build_draw').on 'click', (e) ->
      e.preventDefault()

      build_draw_num = +$('#lgd_build_draw').text()

      if build_draw_num != -1
        show_confirm_dialog(new Object(title: 'Void Build/Draw ' + $('#lgd_build_draw').text(), message_body: 'Are you sure about voiding this build/draw?', param: $('#lgd_build_draw').text(), method: '/traffic/storageinspector/cancel_cargo_adjustment', message_response: '<strong>Build/Draw successfully voided!</strong> Build/Draw number:'))
      else
        $('.alert-danger').removeClass('show').addClass('hidden')
        $('.alert-success').removeClass('show').addClass('hidden')

        $('#error_container').html('')
        $('#success_container').html('')

        html = ''
        html += '<strong>Cannot void an unexisted Build/Draw!</strong>'

        $('#error_container').html(html)
        $('.alert-danger').removeClass('hidden').addClass('show')

    # Adding keyup function
    $.each tbl_adjustment_tag.$('input.col-44'), (k, v) ->
      $(v).keyup (e) ->
        new_value = $(this).val()
        $(this).attr('value', new_value)

    # Add motive
    $('#btn_add_motive').on 'click', (e) ->
      e.preventDefault()

###
#Function to check value with cxl level qty
###
checkLevelQty = (cargo_num)->
  #Validate that there is no adjustments new in clx
  $.ajax('/traffic/storageinspector/get_empty_cargo_adjustment',
    data: {
      cargo_num: cargo_num
    }
    type: 'GET'
    async: false
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
    return d
###
Perform change storage function
###
psc = (equipment_num) ->
  if equipment_num
    $.ajax '/traffic/storageinspector/get_level_by_equipment',
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
    $('#adjustment_level').empty()

decimalAdjust = (type, value, exp) ->
  # If the exp is undefined or zero...
  if typeof exp == 'undefined' or +exp == 0
    return Math[type](value)
  value = +value
  exp = +exp
  # If the value is not a number or the exp is not an integer...
  if isNaN(value) or !(typeof exp == 'number' and exp % 1 == 0)
    return NaN
  # Shift
  value = value.toString().split('e')
  value = Math[type](+(value[0] + 'e' + (if value[1] then (+value[1] - exp) else -exp)))
  # Shift back
  value = value.toString().split('e')
  return +(value[0] + 'e' + (if value[1] then (+value[1] + exp) else exp))

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
        html += '<a class="btn btn-success btn-sm" data-no-turbolink="true" href="' + window.location + '" role="button">Ok</a>'

        $('#success_container').html(html)

        $('.alert-success').removeClass('hidden').addClass('show')
      else
        $('#error_container').html('<strong>' + d.message + '</strong>')

        $('.alert-danger').removeClass('hidden').addClass('show')

###
Function create_transfer_from_trade_to_storage
###
create_adjustment = ->
  build = new Array()

  tbl_adjustment_tag = $('#tbl_adjustment_tag').dataTable()

  $(tbl_adjustment_tag.fnGetNodes()).each (k, v) ->
    aoData = tbl_adjustment_tag.fnGetData(this)

    aoElement = $(this).find('td > input.col-44')
    gain_loss_qty = $(aoElement).val()

    v_build = new Object()
    v_build.build_draw_num = $(aoData[0]).val()
    v_build.build_draw_ind = aoData[1]
    v_build.location_num = aoData[2]
    v_build.trade_num = aoData[3]
    v_build.obligation_num = aoData[4]
    v_build.transfer_start_dt = aoData[5]
    v_build.transfer_end_dt = aoData[6]
    v_build.build_draw_qty = aoData[7]
    v_build.open_qty = aoData[8]
    v_build.transfer_price = aoData[9]
    v_build.per_unit_cost = aoData[10]
    v_build.build_draw_type_ind = aoData[11]
    v_build.strategy_num = aoData[12]
    v_build.obligation_detail_num = aoData[13]
    v_build.transfer_num = aoData[14]
    v_build.transfer_at_ind = aoData[15]
    v_build.transfer_price_status_ind = aoData[16]
    v_build.net_qty = aoData[17]
    v_build.cargo_qty = aoData[18]
    v_build.packaging_qty = aoData[19]
    v_build.base_vol = aoData[20]
    v_build.base_mass = aoData[21]
    v_build.filled_ind = aoData[22]
    v_build.weighted_avg = aoData[23]
    v_build.import_ind = aoData[24]
    v_build.import_type_ind = aoData[25]
    v_build.mtm_price = aoData[26]
    v_build.p_l_value = aoData[27]
    v_build.price_locked_ind = aoData[28]
    v_build.last_modify_dt = aoData[29]
    v_build.modify_person_num = aoData[30]
    # is_tag_qty_non_zero_ind
    v_build.gain_loss_factor = aoData[31]
    v_build.transfer_cost = aoData[32]
    v_build.delivery_active_status_ind = aoData[33]
    v_build.delivery_dt_mtm_ind = aoData[34]
    # conf_warning_ind
    v_build.transfer_split_ind = aoData[35]
    v_build.commodity_cost = aoData[36]
    v_build.sap_cur_bal_ind = aoData[37]
    v_build.effective_dt = aoData[38]
    v_build.cmdty_cd = aoData[39]

    tag = new Array()

    v_tag = new Object()
    v_tag.build_draw_num = aoData[40]
    v_tag.tag_type_cd = aoData[41]
    v_tag.tag_type_ind = aoData[58]
    v_tag.bd_tag_num = aoData[42]
    v_tag.tag_gain_loss_qty_to_alloc = gain_loss_qty
    v_tag.tag_qty = $(aoData[49]).val()
    v_tag.tag_qty_uom_cd = $(aoData[50]).val()
    v_tag.modify_person_num = aoData[53]
    v_tag.tag_value1 = $(aoData[44]).val()
    v_tag.tag_value2 = $(aoData[45]).val()
    v_tag.tag_value3 = $(aoData[46]).val()
    v_tag.tag_value4 = $(aoData[47]).val()
    v_tag.tag_value7 = $(aoData[48]).val()
    v_tag.tag_value8 = aoData[54]
    v_tag.chop_id = $(aoData[43]).val()
    v_tag.tag_source_ind = aoData[55]
    v_tag.build_draw_type_ind = aoData[56]
    v_tag.build_draw_ind = aoData[57]
    v_tag.ref_bd_tag_num = aoData[59]
    v_tag.tag_alloc_qty = $(aoData[51]).val()
    v_tag.gl_ref_bd_tag_num = aoData[60]
    v_tag.split_src_tag_num = aoData[61]
    v_tag.adj_ref_build_draw_num = aoData[62]
    v_tag.tag_adj_qty = aoData[63]

    tag.push(v_tag)

    v_build.tag = tag

    build.push(v_build)

  build.push(global_build_draw)

  # console.log build

  $.ajax('/traffic/storageinspector/put_gain_loss_bd_tags_for_adj',
    data: {
      equipment_num: $('#adjustment_storage').val()
      cargo_num: $('#adjustment_level').val()
      gl_build_draw_num: $('#lgd_build_draw').text()
      gl_build_draw_qty: +$('#lgd_before_gain_loss_qty').text()
      gl_adjustment_reason: $('#adjustment_reason').val()
      build: build
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

    $('.alert-danger').removeClass('show').addClass('hidden')
    $('.alert-success').removeClass('show').addClass('hidden')

    $('#error_container').html('')
    $('#success_container').html('')

    if d.success == true
      html = ''
      html += '<strong>Adjustment successfully saved!</strong> Level number: ' + d.id
      html += '<div class="clearfix"></div>'
      html += '<br />'
      html += '<a class="btn btn-success btn-sm" data-no-turbolink="true" href="' + window.location + '" role="button">Ok</a>'

      $('#success_container').html(html)

      $('.alert-success').removeClass('hidden').addClass('show')
      $('#btn_create_adjustment').removeClass('disabled')
    else
      $('#error_container').html('<strong>' + d.message + '</strong>')

      $('.alert-danger').removeClass('hidden').addClass('show')
