# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  ###
  Get transfer form.
  If transfer form is found, then we attach some other functions to input fields
  ###
  tf = document.getElementById('frm_new_transfer')

  if tf
    $('#frm_new_transfer').parsley().subscribe('parsley:form:validate', (f) ->
      f.submitEvent.preventDefault()

      $('#error_container').find('.parsley-errors-custom').remove()

      $('.alert-danger').removeClass('show').addClass('hidden')

      # Validate there are tags when transer from is a trade
      if $('#from_type_ind').val() == '0' and $('#tbl_transfer_tag > tbody > tr').length <= 0
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

      # Validate that tags quantity match scheduled, storage and cargo quantity
      if $('#from_type_ind').val() == '0'
        tag_qty = 0

        $('#tbl_transfer_tag tbody tr').each ->
          r = $(this)

          tag_qty = tag_qty + parseFloat(r.find('input.col-10').val())

        if tag_qty <= 0
          html = ''
          html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
          html += ' <li class="parsley-custom-error-message"><strong>Tags Qty</strong> must be greater than zero</li>'
          html += '</ul>'

          $('#error_container').append(html)

          $('.alert-danger').removeClass('hidden').addClass('show')

          return

        if $('#to_type_ind').val() == '1'
          storage_qty = (if $('#to_storage_qty').val() then parseFloat($('#to_storage_qty').val()) else 0)

          if storage_qty <= 0
            html = ''
            html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
            html += ' <li class="parsley-custom-error-message"><strong>Storage Qty</strong> must be greater than zero</li>'
            html += '</ul>'

            $('#error_container').append(html)

            $('.alert-danger').removeClass('hidden').addClass('show')

            return

          if storage_qty != tag_qty
            html = ''
            html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
            html += ' <li class="parsley-custom-error-message"><strong>Storage & Tags Qty</strong> cannot be differents</li>'
            html += '</ul>'

            $('#error_container').append(html)

            $('.alert-danger').removeClass('hidden').addClass('show')

            return

        if $('#to_type_ind').val() == '2'
          cargo_qty = (if $('#to_cargo_qty').val() then parseFloat($('#to_cargo_qty').val()) else 0)

          if cargo_qty <= 0
            html = ''
            html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
            html += ' <li class="parsley-custom-error-message"><strong>Cargo Qty</strong> must be greater than zero</li>'
            html += '</ul>'

            $('#error_container').append(html)

            $('.alert-danger').removeClass('hidden').addClass('show')

            return

          if cargo_qty != tag_qty
            html = ''
            html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
            html += ' <li class="parsley-custom-error-message"><strong>Cargo & Tags Qty</strong> cannot be differents</li>'
            html += '</ul>'

            $('#error_container').append(html)

            $('.alert-danger').removeClass('hidden').addClass('show')

            return

      # Validate different levels from storage to storage
      if $('#from_type_ind').val() == '1' and $('#to_type_ind').val() == '1'
        from_level = $('#s_from_level').val()
        to_level = $('#s_to_level').val()

        if from_level == to_level
          html = ''
          html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
          html += ' <li class="parsley-custom-error-message"><strong>Levels from Storages</strong> cannot be equals</li>'
          html += '</ul>'

          $('#error_container').append(html)

          $('.alert-danger').removeClass('hidden').addClass('show')

          return

      if f.isValid('grp_transfer', false)
        if $('#from_type_ind').val() == '0' and $('#to_type_ind').val() == '1' # Transfer from trade to storage
          create_transfer_from_trade_to_storage()
        else if $('#from_type_ind').val() == '0' and $('#to_type_ind').val() == '2' # Transfer from trade to vessel
          create_transfer_from_trade_to_vessel()
        else if $('#from_type_ind').val() == '1' and $('#to_type_ind').val() == '0' # Transfer from storage to trade
          create_transfer_from_storage_to_trade()
        else if $('#from_type_ind').val() == '1' and $('#to_type_ind').val() == '1' # Tansfer from storage to storage
          create_transfer_from_storage_to_storage()
        else if $('#from_type_ind').val() == '1' and $('#to_type_ind').val() == '2' # Transfer from storage to vessel
          create_transfer_from_storage_to_vessel()
        else if $('#from_type_ind').val() == '2' and $('#to_type_ind').val() == '0' # Transfer from vessel to trade
          create_transfer_from_vessel_to_trade()
        else if $('#from_type_ind').val() == '2' and $('#to_type_ind').val() == '1' # Transfer from vessel to storage
          create_transfer_from_vessel_to_storage()
        else
          html = ''
          html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
          html += ' <li class="parsley-custom-error-message"><strong>The combination of transfer you selected does not exist!</strong</li>'
          html += '</ul>'

          $('#error_container').append(html)

          $('.alert-danger').removeClass('hidden').addClass('show')

        return

      $('.alert-danger').removeClass('hidden').addClass('show')
      return
    )

    $("#from_type_ind > option").each ->
      v = $(this).val()

      if v > 2
        $(this).attr('disabled', true)

    $("#to_type_ind > option").each ->
      v = $(this).val()

      if v > 2
        $(this).attr('disabled', true)

    ###
    Default actions initialization when the from panel is a trade
    ###
    ita('from')
    isk('from')

    ###
    Default actions initialization when the to panel is a storage
    ###
    isc('to')
    ilc('to')
    isqk('to')

    elf = document.querySelector('#from_type_pnl')
    elt = document.querySelector('#to_type_pnl')

    MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver

    observer = new MutationObserver((m) ->
      for v in m
        if v.type == 'childList'
          sourceid = $(v.target).attr('id')

          trade_el = $(v.target).find(if sourceid == 'from_type_pnl' then '#from_trade' else '#to_trade')
          storage_el = $(v.target).find(if sourceid == 'from_type_pnl' then '#from_storage' else '#to_storage')
          vessel_el = $(v.target).find(if sourceid == 'from_type_pnl' then '#from_itinerary' else '#to_itinerary')

          if trade_el.length > 0
            ita(if sourceid == 'from_type_pnl' then 'from' else 'to')
            isk(if sourceid == 'from_type_pnl' then 'from' else 'to')

          if storage_el.length > 0
            isc(if sourceid == 'from_type_pnl' then 'from' else 'to')
            ilc(if sourceid == 'from_type_pnl' then 'from' else 'to')
            isqk(if sourceid == 'from_type_pnl' then 'from' else 'to')

          if vessel_el.length > 0
            iia(if sourceid == 'from_type_pnl' then 'from' else 'to')

          iua('from')
          iua('to')
    )

    config = {
      attributes: true
      childList: true
      characterData: true
    }

    observer.observe(elf, config)
    observer.observe(elt, config)

    $('#btn_import_tag').fileinput(
      allowedFileExtensions: ['xls', 'xlsx']
      browseClass: "btn btn-success"
      mainClass: "input-group-sm"
      showPreview: false
      uploadUrl: '/traffic/transfermanager/import_tag_from_excel'
    ).on 'filebatchuploadsuccess', (event, data) ->
      if data.response
        html = ''

        for i in data.response
          html += '<tr class="info">'
          html += ' <td><input class="form-control col-1" disabled value="' + i.type + '" /></td>'
          html += ' <td><input class="form-control col-2" data-parsley-error-message="<strong>Container</strong> is required" data-parsley-errors-container="#error_container" data-parsley-group="grp_transfer" data-parsley-required="true" type="text" value="' + i.value1 + '" /></td>'
          html += ' <td><input class="form-control col-3" data-parsley-error-message="<strong>ICO</strong> is required" data-parsley-errors-container="#error_container" data-parsley-group="grp_transfer" data-parsley-required="true" type="text" value="' + i.value2 + '" /></td>'
          html += ' <td><input class="form-control col-4" value="' + (if i.value3 then i.value3 else '') + '" /></td>'
          html += ' <td><input class="form-control col-5" value="' + (if i.value4 then i.value4 else '') + '" /></td>'
          html += ' <td><input class="form-control col-6" disabled value="' + (if i.value5 then i.value5 else '') + '" /></td>'
          html += ' <td><input class="form-control col-7" disabled value="' + (if i.value6 then i.value6 else '') + '" /></td>'
          html += ' <td><input class="form-control col-8" value="' + (if i.value7 then i.value7 else '') + '" /></td>'
          html += ' <td><input class="form-control col-9" value="' + (if i.value8 then i.value8 else '') + '" /></td>'
          html += ' <td><input class="form-control col-10" data-parsley-error-message="<strong>Tag Qty</strong> is required" data-parsley-errors-container="#error_container" data-parsley-group="grp_transfer" data-parsley-required="true" type="text" value="' + i.tag_qty + '" /></td>'
          html += ' <td><input class="form-control col-11" data-parsley-error-message="<strong>Tag Qty UOM</strong> is required" data-parsley-errors-container="#error_container" data-parsley-group="grp_transfer" data-parsley-required="true" disabled type="text" value="' + i.value8 + '" /></td>'
          html += ' <td><i class="glyphicon glyphicon-trash" data-placement="bottom" data-toggle="tooltip" style="cursor: pointer; margin-top: 8px;" title="Remove Tag"></i></td>'
          html += ' <td></td>'
          html += '</tr>'

        $('#tbl_transfer_tag').append(html)

        it()

    $('#btn_add_tag').on 'click', (e) ->
      html = ''
      html += '<tr class="info">'
      html += ' <td><input class="form-control col-1" disabled value="Chop Data" /></td>'
      html += ' <td><input class="form-control col-2" data-parsley-error-message="<strong>Container</strong> is required" data-parsley-errors-container="#error_container" data-parsley-group="grp_transfer" data-parsley-required="true" type="text" /></td>'
      html += ' <td><input class="form-control col-3" data-parsley-error-message="<strong>ICO</strong> is required" data-parsley-errors-container="#error_container" data-parsley-group="grp_transfer" data-parsley-required="true" type="text" /></td>'
      html += ' <td><input class="form-control col-4" /></td>'
      html += ' <td><input class="form-control col-5" /></td>'
      html += ' <td><input class="form-control col-6" disabled /></td>'
      html += ' <td><input class="form-control col-7" disabled /></td>'
      html += ' <td><input class="form-control col-8" /></td>'
      html += ' <td><input class="form-control col-9" /></td>'
      html += ' <td><input class="form-control col-10" data-parsley-error-message="<strong>Tag Qty</strong> is required" data-parsley-errors-container="#error_container" data-parsley-group="grp_transfer" data-parsley-required="true" type="text" /></td>'
      html += ' <td><input class="form-control col-11" data-parsley-error-message="<strong>Tag Qty UOM</strong> is required" data-parsley-errors-container="#error_container" data-parsley-group="grp_transfer" data-parsley-required="true" disabled type="text" value="' + $('#to_storage_qty_uom_cd').text() + '" /></td>'
      html += ' <td><i class="glyphicon glyphicon-trash" data-placement="bottom" data-toggle="tooltip" style="cursor: pointer; margin-top: 8px;" title="Remove Tag"></i></td>'
      html += ' <td></td>'
      html += '</tr>'

      $('#tbl_transfer_tag').append(html)

      it()

    $('#btn_remove_tag').on 'click', (e) ->
      $('#tbl_transfer_tag > tbody').empty()

    # UDF functionality for from
    iua('from')

    # UDF functionality for to
    iua('to')

  return true

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

      options = $(if source == 'from' then '#from_type_udf option' else '#to_type_udf option').clone()
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
Initialize tooltips from tags table
###
it = ->
  # Currently commented because it covers the remove action
  # $('#tbl_transfer_tag > tbody > tr > td > i[data-toggle="tooltip"]').tooltip()

  # Adding remove row event
  $('#tbl_transfer_tag > tbody > tr > td').on 'click', 'i.glyphicon-trash', (e) ->
    e.preventDefault()

    tr = $(this).closest('tr')
    tr.remove()

    return false

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
      when '2' then html += '<input class="col-2 form-control" min="0" type="number" step="any" />'
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
Initialize trade autocomplete function
###
ita = (source) ->
  $(if source == 'from' then '#from_trade' else '#to_trade').autocomplete
    serviceUrl: '/common/util/' + (if source == 'from' then 'get_trade_buy_like_trade' else 'get_trade_sell_like_trade')
    minChars: 4
    beforeRender: (c) ->
      $('#from_to_trade_pnl').addClass('has-error')
    onSearchStart: (q) ->
      ###
      Start progress animation
      ###
      $('.loading-spinner').removeClass('hidden').addClass('show')
    onSearchComplete: (q, s) ->
      ###
      Hide progress animation
      ###
      $('.loading-spinner').removeClass('show').addClass('hidden')
    transformResult: (r) ->
      if r
        return {
          suggestions:
            $.map($.parseJSON(r), (v) ->
              return {
                value: v.trade_num.toString()
                data: {
                  internal_company_num: v.internal_company_num
                  obligation_num: v.obligation_hdr[0].obligation_num
                  trade_num: v.trade_num
                  commodity_cd: v.strategy.strategy_name
                  counterpart_cd: v.counterpart.company_num
                  counterpart_nm: v.counterpart.company_cd
                  contract_qty: v.obligation_hdr[0].contract_qty
                  open_qty: v.obligation_hdr[0].open_qty
                  location_num: v.obligation_hdr[0].location_num
                  uom_cd: v.obligation_hdr[0].contract_uom_cd
                  price: v.obligation_hdr[0].price
                  price_uom_cd: v.obligation_hdr[0].price_uom_cd
                  price_curr_cd: v.obligation_hdr[0].price_curr_cd
                  bbl_mt_factor: v.obligation_hdr[0].bbl_mt_factor
                }
              }
            )
        }
    formatResult: (s, cv) ->
      html = ''
      html += '<div style="display: inline;">'
      html += ' <span style="display: inline-block;"><strong>' + s.data.trade_num + '</strong></span>'
      html += ' <span style="color: #337ab7; display: inline-block;"><small>(Commodity)</small> ' + s.data.commodity_cd + '</span>'
      html += ' <span style="color: #337ab7; display: inline-block;"><small>(Counterpart)</small> ' + s.data.counterpart_nm + '</span>'
      html += '</div>'

      return html
    onSelect: (s) ->
      $('#from_to_trade_pnl').removeClass('has-error')

      $('#location_num').val(s.data.location_num)
      $('#internal_company_num').val(s.data.internal_company_num)
      $('#obligation_num').val(s.data.obligation_num)
      $('#price').val(s.data.price)
      $('#price_uom_cd').val(s.data.price_uom_cd)
      $('#price_curr_cd').val(s.data.price_curr_cd)
      $('#bbl_mt_factor').val(s.data.bbl_mt_factor)
      $(if source == 'from' then '#from_counterpart' else '#to_counterpart').val(s.data.counterpart_nm)
      $(if source == 'from' then '#from_open_qty' else '#to_open_qty').val(s.data.open_qty)
      $(if source == 'from' then '#from_open_qty_uom_cd' else '#to_open_qty_uom_cd').text(s.data.uom_cd)
      $(if source == 'from' then '#from_contract_qty' else '#to_contract_qty').val(s.data.contract_qty)
      $(if source == 'from' then '#from_contract_qty_uom_cd' else '#to_contract_qty_uom_cd').text(s.data.uom_cd)
      $(if source == 'from' then '#t_from_commodity' else '#t_to_commodity').val(s.data.commodity_cd)
      $(if source == 'from' then '#from_scheduled_qty_uom_cd' else '#to_scheduled_qty_uom_cd').text(s.data.uom_cd)
      $(if source == 'from' then '#from_nominal_qty_uom_cd' else '#to_nominal_qty_uom_cd').text(s.data.uom_cd)

      # Get conversion factor
      get_conversion_factor_by_uom(s.data.uom_cd, source)

      return true

###
Initialize schedule keyup function
###
isk = (source) ->
  $(if source == 'from' then '#from_scheduled_qty' else '#to_scheduled_qty').keyup ->
    open_qty = parseFloat($(if source == 'from' then '#from_open_qty' else '#to_open_qty').val())
    scheduled_qty = parseFloat($(this).val())

    if scheduled_qty <= open_qty
      $(if source == 'from' then '#from_nominal_qty' else '#to_nominal_qty').val($(this).val())
    else
      $(this).val('0.00')
      $(if source == 'from' then '#from_nominal_qty' else '#to_nominal_qty').val('0.00')

    #Calculate Converted Qty
    if source == 'from'
      calculateConvertQty(source)



calculateConvertQty = (source) ->
    # console.log 'Converting Qty to destination partial'

    from_convertion = parseFloat($('#from_convertion_factor').val())
    to_convertion = parseFloat($('#to_convertion_factor').val())
    value =

    convertQty = 0.00

    # Asign Value to convert
    switch $('#from_type_ind')[0].value
      when "0" then value = parseFloat($('#from_scheduled_qty').val())
      when "1" then value = parseFloat($('#from_storage_qty').val())

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
    switch $('#from_type_ind')[0].value
      when "0" then convertQty = ( parseFloat($('#from_scheduled_qty').val()) / from_convertion ) * (to_convertion)
      when "1" then convertQty = ( parseFloat($('#from_storage_qty').val()) / from_convertion ) * (to_convertion)

    switch $('#to_type_ind')[0].value
      when "0"
        $('#to_scheduled_qty').val(convertQty.toFixed(4))
        $('#to_nominal_qty').val(convertQty.toFixed(4))
      when "1"
        $('#to_storage_qty').val(convertQty.toFixed(4))

###
Initialize storage change function
###
isc = (source) ->
  psc(source)

  $(document).on 'change', (if source == 'from' then '#from_storage' else '#to_storage'), (e) ->
    psc(source)

###
Perform change storage function
###
psc = (source) ->
  $.ajax '/traffic/transfermanager/' + (if source == 'from' then 'get_level_by_equipment_from' else 'get_level_by_equipment_to'),
    dataType: 'script'
    data: {
      query: $(if source == 'from' then '#from_storage' else '#to_storage').val()
    }
    beforeSend: (xhr) ->
      ###
      Start progress animation
      ###
      $('.loading-spinner').removeClass('hidden').addClass('show')
    success: (d) ->

      opt = $('option:selected', $(if source == 'from' then '#s_from_level' else '#s_to_level'))

      value = opt.attr('uom_cd')
      # Get conversion factor
      if value != undefined
        get_conversion_factor_by_uom(value, source)


###
Initialize level change function
###
ilc = (source) ->
  $(document).on 'change', (if source == 'from' then '#s_from_level' else '#s_to_level'), (e) ->
    $.ajax('/common/util/get_level_by_cargo',
      data: {
        id: $(if source == 'from' then '#s_from_level' else '#s_to_level').val()
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
        $(if source == 'from' then '#s_from_commodity' else '#s_to_commodity').val(d.cmdty_cd)
        $(if source == 'from' then '#from_storage_qty_uom_cd' else '#to_storage_qty_uom_cd').text(d.qty_uom_cd)

        #Change tag Qty Uom to tags
        $('#tbl_transfer_tag tbody tr').each ->
          r = $(this)
          r.find('input.col-11').val(d.qty_uom_cd)

        # Get conversion factor
        get_conversion_factor_by_uom(d.qty_uom_cd, source)



###
Initialize storage qty key up function
###
isqk = (source) ->
   $(if source == 'from' then '#from_storage_qty' else '#to_storage_qty').keyup ->
     calculateConvertQty(source) if source == 'from'

###
Initialize itinerary autocomplete function
###
iia = (source) ->
  $(if source == 'from' then '#from_itinerary' else '#to_itinerary').autocomplete
    serviceUrl: '/common/util/get_movement_by_itinerary'
    minChars: 3
    beforeRender: (c) ->
      $('#from_to_vessel_pnl').addClass('has-error')
    onSearchStart: (q) ->
      ###
      Start progress animation
      ###
      $('.loading-spinner').removeClass('hidden').addClass('show')
    onSearchComplete: (q, s) ->
      ###
      Hide progress animation
      ###
      $('.loading-spinner').removeClass('show').addClass('hidden')
    transformResult: (r) ->
      if r
        return {
          suggestions:
            $.map($.parseJSON(r), (v) ->
              return {
                value: v.itinerary_num.toString()
                data: {
                  movement_num: v.movement_num
                  equipment_num: v.equipment_num
                  mot: v.mot.mot_cd
                  mot_type: v.mot_type.ind_value_name
                }
              }
            )
        }
    formatResult: (s, cv) ->
      html = ''
      html += '<div style="display: inline;">'
      html += ' <span style="display: inline-block;"><small>(Movement No.)</small><strong> ' + s.data.movement_num + '</strong></span>'
      html += ' <span style="color: #337ab7; display: inline-block;"><small>(MOT)</small> ' + s.data.mot_type + '</span>'
      html += ' <span style="color: #337ab7; display: inline-block;"><small>(Name)</small> ' + s.data.mot + '</span>'
      html += '</div>'

      return html
    onSelect: (s) ->
      $('#from_to_vessel_pnl').removeClass('has-error')

      $(if source == 'from' then '#from_vehicle' else '#to_vehicle').val(s.data.equipment_num)
      $(if source == 'from' then '#from_mot_type' else '#to_mot_type').val(s.data.mot_type)
      $(if source == 'from' then '#from_mot' else '#to_mot').val(s.data.mot)

      ifc(source, s.data.equipment_num)

      return true

###
Initialize filling cargo drop-down function
###
ifc = (source, equipment_num) ->
  $.ajax '/traffic/transfermanager/' + (if source == 'from' then 'get_cargo_by_equipment_from' else 'get_cargo_by_equipment_to'),
    dataType: 'script'
    data: {
      query: equipment_num
    }
    beforeSend: (xhr) ->
      ###
      Start progress animation
      ###
      $('.loading-spinner').removeClass('hidden').addClass('show')

get_conversion_factor_by_uom = (uom, source) ->

  if uom != '' and source != ''
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
  else
    console.log 'Cannot get convertion factor: Uom or type is not valid'

###
Function create_transfer_from_trade_to_storage
###
create_transfer_from_trade_to_storage = ->
  # Collect tags
  tag = new Array()

  $('#tbl_transfer_tag tbody tr').each ->
    r = $(this)

    v_tag = new Object()
    v_tag.equipment_num = $('#to_storage').val()
    v_tag.cargo_num = $('#s_to_level').val()
    v_tag.tag_type_cd = r.find('input.col-1').val()
    v_tag.tag_value1 = r.find('input.col-2').val()
    v_tag.tag_value2 = r.find('input.col-3').val()
    v_tag.tag_value3 = r.find('input.col-4').val()
    v_tag.tag_value4 = r.find('input.col-5').val()
    v_tag.tag_value7 = r.find('input.col-8').val()
    v_tag.tag_value8 = r.find('input.col-9').val()
    v_tag.tag_qty = r.find('input.col-10').val()
    v_tag.tag_qty_uom_cd = r.find('input.col-11').val()

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

  console.log 'caluculating convertion factor'
  #Add uom Convertion and muliply/divide
  #Get information of convertion factor and convertion indicator
  #Three cases
  #1. When uom from and to are equal cxl multiply or divide by 1
  #2. When to is MT it divide the from value with its convertion factor
  #3. When from are to are different it multiply the from value 
  # using a factor calculated (to_convertion_factor / from_convertion_factor)
  if($('#from_open_qty_uom_cd').text()==$('#to_storage_qty_uom_cd').text())
    uom_conv_factor = 1
    uom_conv_factor_ind = 0 #Multiply
  else if ($('#to_storage_qty_uom_cd').text()=='MT')
    uom_conv_factor = $('#from_convertion_factor').val()
    uom_conv_factor_ind = 1 #Divide
  else
    uom_conv_factor = parseFloat($('#to_convertion_factor').val())/parseFloat($('#from_convertion_factor').val())
    uom_conv_factor_ind = 0 #multiply

  console.log 'Finished calculating convertion factor'
  console.log uom_conv_factor + ' _ ' + uom_conv_factor_ind


  $.ajax('/traffic/transfermanager/create_transfer_from_trade_to_storage',
    data: {
      from_type_ind: $('#from_type_ind').val()
      to_type_ind: $('#to_type_ind').val()
      location_num: $('#location_num').val()
      operator_person_num: $('#operator_person_num').val()
      transfer_comm_dt: $('#transfer_comm_dt').val()
      transfer_comp_dt: $('#transfer_comp_dt').val()
      obligation_num: $('#obligation_num').val()
      from_qty: $('#from_scheduled_qty').val()
      from_uom: $('#from_open_qty_uom_cd').text()
      to_equipment_num: $('#to_storage').val()
      to_cargo_num: $('#s_to_level').val()
      to_qty: $('#to_storage_qty').val()
      to_uom: $('#to_storage_qty_uom_cd').text()
      effective_dt: $('#effective_dt').val()
      bl_num_cd: $('#bl_num_cd').val()
      bl_dt: $('#bl_dt').val()
      from_internal_company_num: $('#internal_company_num').val()
      to_internal_company_num: $('#to_internal_company_num').val()
      price: $('#price').val()
      price_uom_cd: $('#price_uom_cd').val()
      price_curr_cd: $('#price_curr_cd').val()
      bbl_mt_factor: $('#bbl_mt_factor').val()
      tag: tag
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
Function create_transfer_from_trade_to_vessel
###
create_transfer_from_trade_to_vessel = ->
  tag = new Array()

  $('#tbl_transfer_tag tbody tr').each ->
    r = $(this)

    v_tag = new Object()
    v_tag.equipment_num = $('#to_storage').val()
    v_tag.cargo_num = $('#s_to_level').val()
    v_tag.tag_type_cd = r.find('input.col-1').val()
    v_tag.tag_value1 = r.find('input.col-2').val()
    v_tag.tag_value2 = r.find('input.col-3').val()
    v_tag.tag_value3 = r.find('input.col-4').val()
    v_tag.tag_value4 = r.find('input.col-5').val()
    v_tag.tag_value7 = r.find('input.col-8').val()
    v_tag.tag_value8 = r.find('input.col-9').val()
    v_tag.tag_qty = r.find('input.col-10').val()
    v_tag.tag_qty_uom_cd = r.find('input.col-11').val()

    tag.push(v_tag)

###
Function create_transfer_from_storage_to_trade
###
create_transfer_from_storage_to_trade = ->
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
  if($('#from_storage_qty_uom_cd').text()==$('#to_open_qty_uom_cd').text())
    uom_conv_factor = 1
    uom_conv_factor_ind = 0 #Multiply
  else if ($('#to_open_qty_uom_cd').text()=='MT')
    uom_conv_factor = $('#from_convertion_factor').val()
    uom_conv_factor_ind = 1 #Divide
  else
    uom_conv_factor = parseFloat($('#to_convertion_factor').val())/parseFloat($('#from_convertion_factor').val())
    uom_conv_factor_ind = 0 #multiply

  $.ajax('/traffic/transfermanager/create_transfer_from_storage_to_trade',
    data: {
      from_type_ind: $('#from_type_ind').val()
      to_type_ind: $('#to_type_ind').val()
      location_num: $('#location_num').val()
      operator_person_num: $('#operator_person_num').val()
      transfer_comm_dt: $('#transfer_comm_dt').val()
      transfer_comp_dt: $('#transfer_comp_dt').val()
      obligation_num: $('#obligation_num').val()
      from_equipment_num: $('#from_storage').val()
      from_cargo_num: $('#s_from_level').val()
      from_qty: $('#from_storage_qty').val()
      from_uom: $('#from_storage_qty_uom_cd').text()
      to_qty: $('#to_scheduled_qty').val()
      to_uom: $('#to_open_qty_uom_cd').text()
      effective_dt: $('#effective_dt').val()
      bl_num_cd: $('#bl_num_cd').val()
      bl_dt: $('#bl_dt').val()
      from_internal_company_num: $('#from_internal_company_num').val()
      to_internal_company_num: $('#internal_company_num').val()
      price: $('#price').val()
      price_uom_cd: $('#price_uom_cd').val()
      price_curr_cd: $('#price_curr_cd').val()
      bbl_mt_factor: $('#bbl_mt_factor').val()
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
Function create_transfer_from_storage_to_storage
###
create_transfer_from_storage_to_storage = ->
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
  if($('#from_storage_qty_uom_cd').text()==$('#to_storage_qty_uom_cd').text())
    uom_conv_factor = 1
    uom_conv_factor_ind = 0 #Multiply
  else if ($('#to_storage_qty_uom_cd').text()=='MT')
    uom_conv_factor = $('#from_convertion_factor').val()
    uom_conv_factor_ind = 1 #Divide
  else
    uom_conv_factor = parseFloat($('#to_convertion_factor').val())/parseFloat($('#from_convertion_factor').val())
    uom_conv_factor_ind = 0 #multiply



  $.ajax('/traffic/transfermanager/create_transfer_from_storage_to_storage',
    data: {
      from_type_ind: $('#from_type_ind').val()
      to_type_ind: $('#to_type_ind').val()
      location_num: $('#location_num').val()
      operator_person_num: $('#operator_person_num').val()
      transfer_comm_dt: $('#transfer_comm_dt').val()
      transfer_comp_dt: $('#transfer_comp_dt').val()
      from_equipment_num: $('#from_storage').val()
      from_cargo_num: $('#s_from_level').val()
      from_qty: $('#from_storage_qty').val()
      from_uom: $('#from_storage_qty_uom_cd').text()
      to_equipment_num: $('#to_storage').val()
      to_cargo_num: $('#s_to_level').val()
      to_qty: $('#to_storage_qty').val()
      to_uom: $('#to_storage_qty_uom_cd').text()
      effective_dt: $('#effective_dt').val()
      bl_num_cd: $('#bl_num_cd').val()
      bl_dt: $('#bl_dt').val()
      from_internal_company_num: $('#from_internal_company_num').val()
      to_internal_company_num: $('#to_internal_company_num').val(),
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
Function create_transfer_from_storage_to_vessel
###
create_transfer_from_storage_to_vessel = ->
  console.log 'create_transfer_from_storage_to_vessel'

###
Function create_transfer_from_vessel_to_trade
###
create_transfer_from_vessel_to_trade = ->
  console.log 'create_transfer_from_vessel_to_trade'

###
Function create_transfer_from_vessel_to_storage
###
create_transfer_from_vessel_to_storage = ->
  console.log 'create_transfer_from_vessel_to_storage'

show_save_transfer_response = (r) ->
  $('.alert-danger').removeClass('show').addClass('hidden')
  $('.alert-success').removeClass('show').addClass('hidden')

  $('#error_container').html('')
  $('#success_container').html('')

  if r.success == true
    html = ''
    html += '<strong>Transfer successfully saved!</strong> Transfer number: <a class="alert-link" data-no-turbolink="true" href="/traffic/transfermanager/' + r.id + '">' + r.id + '</a>'
    html += '<div class="clearfix"></div>'
    html += '<br />'
    html += '<a class="btn btn-success btn-sm" data-no-turbolink="true" href="/traffic/transfermanager/new" role="button" style="margin-right: 10px;">New Transfer</a>'
    html += '<a class="btn btn-warning btn-sm" data-no-turbolink="true" href="/traffic/transfermanager/' + r.id + '/edit" role="button" style="margin-right: 10px;">Edit Transfer</a>'
    html += '<a class="btn btn-primary btn-sm" data-no-turbolink="true" href="/traffic/transfermanager/' + r.id + '/allocation" role="button">Allocate Tags</a>'

    $('#success_container').html(html)

    $('.alert-success').removeClass('hidden').addClass('show')
  else
    $('#error_container').html('<strong>' + r.message + '</strong>')

    $('.alert-danger').removeClass('hidden').addClass('show')
