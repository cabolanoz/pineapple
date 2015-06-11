# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  if $('#tbl_builddraw').length > 0
    if $('#tbl_builddraw > tbody > tr > td[colspan]').length <= 0
      tbl_builddraw = $('#tbl_builddraw').DataTable
        aoColumnDefs: [
          {
            aTargets: [8, 9]
            visible: false
          }
        ]
        info: false
        lengthChange: false
        lengthMenu: [6, 26, 46, -1]
        ordering: false
        paging: false
        searching: false

      row = tbl_builddraw.row(0)

      if ! row.child.isShown()
        h = ''
        h += '<div class="details-info-content-grey">'
        h += '  <div class="row">'
        h += '    <div class="col-md-12">'
        h += '      <table class="table" style="margin-bottom: 0 !important; width: 100% !important;">'
        h += '        <thead>'
        h += '          <tr>'
        h += '            <th>Type</th>'
        h += '            <th>Chop Id</th>'
        h += '            <th>Value 1 <small>(Container)</small></th>'
        h += '            <th>Value 2 <small>(ICO)</small></th>'
        h += '            <th>Value 3 <small>(Warehouse)</small></th>'
        h += '            <th>Value 4 <small>(ERW)</small></th>'
        h += '            <th>Value 7 <small>(Building)</small></th>'
        h += '            <th>Value 8 <small>(Comments)</small></th>'
        h += '            <th>Tag Qty</th>'
        h += '            <th>Qty UOM</th>'
        h += '            <th>Qty Allocated</th>'
        h += '            <th class="hidden">No. B.D. Tag</th>'
        h += '            <th class="hidden">Ref B.D. Tag</th>'
        h += '          </tr>'
        h += '        </thead>'
        h += '        <tbody>'

        $.each JSON.parse(row.data()[9]), (k, v) ->
          h += '<tr>'
          h += ' <td class="col-1" data-value="' + v.build_draw_num + '">' + v.tag_type_cd + '</td>'
          h += ' <td class="col-2">' + (if v.chop_id != null then v.chop_id else '') + '</td>'
          h += ' <td class="col-3">' + v.tag_value1 + '</td>'
          h += ' <td class="col-4">' + v.tag_value2 + '</td>'
          h += ' <td class="col-5">' + (if v.tag_value3 != null then v.tag_value3 else '') + '</td>'
          h += ' <td class="col-6">' + (if v.tag_value4 != null then v.tag_value4 else '') + '</td>'
          h += ' <td class="col-7">' + (if v.tag_value7 != null then v.tag_value7 else '') + '</td>'
          h += ' <td class="col-8">' + (if v.tag_value8 != null then v.tag_value8 else '') + '</td>'
          h += ' <td class="col-9">' + parseFloat(v.tag_qty).toFixed(2) + '</td>'
          h += ' <td class="col-10">' + v.tag_qty_uom_cd + '</td>'
          h += ' <td class="col-11">' + (if v.tag_alloc_qty != null then parseFloat(v.tag_alloc_qty).toFixed(2) else '0.00') + '</td>'
          h += ' <td class="col-12 hidden no-padding">' + v.bd_tag_num + '</td>'
          h += ' <td class="col-13 hidden no-padding">' + v.ref_bd_tag_num + '</td>'
          h += '</tr>'

        h += '        </tbody>'
        h += '      </table>'
        h += '    </div>'
        h += '  </div>'
        h += '</div>'

        row.child(h).show()
        $('#tbl_builddraw > tbody > tr:nth-child(n+2)').addClass('shown')

      $('#tbl_builddraw table tbody').on 'mousedown', 'td', ->
        if event.which == 3
          tr = $(this).closest('tr')

          $(tr).contextmenu
            target: '#transfer_tag_contextmenu'
            before: (e, context) ->
              e.preventDefault

              span = $('#transfer_tag_contextmenu').find('span')[0]
              if span
                $(span).text($(tr.find('td.col-12')[0]).text())

              return true
            onItem: (context, e) ->
              if e.target.tagName != 'SPAN'
                switch e.target.id
                  when 'lnk_edit_tag'
                    $('#pnl_edit_tag').toggle('slow')

                    # Unbind click event
                    $('#btn_edit_cancel_tag').unbind('click')
                    $('#btn_edit_save_tag').unbind('click')

                    # Populating tags table
                    tbody = $(tr).closest('tbody')
                    $.each tbody[0].rows, (k, v) ->
                      r = $(v)

                      h = ''
                      h += '<tr>'
                      h += '  <td class="hidden"><input class="form-control col-1" disabled type="text" value="' + $(r.find('td.col-12')[0]).text() + '" /></td>'
                      h += '  <td><input class="form-control col-2" disabled type="text" value="' + $(r.find('td.col-1')[0]).text() + '" /></td>'
                      h += '  <td><input class="form-control col-3" disabled type="text" value="' + $(r.find('td.col-2')[0]).text() + '" /></td>'
                      h += '  <td><input class="form-control col-4" type="text" value="' + $(r.find('td.col-3')[0]).text() + '" /></td>'
                      h += '  <td><input class="form-control col-5" type="text" value="' + $(r.find('td.col-4')[0]).text() + '" /></td>'
                      h += '  <td><input class="form-control col-6" type="text" value="' + $(r.find('td.col-5')[0]).text() + '" /></td>'
                      h += '  <td><input class="form-control col-7" type="text" value="' + $(r.find('td.col-6')[0]).text() + '" /></td>'
                      h += '  <td><input class="form-control col-8" type="text" value="' + $(r.find('td.col-7')[0]).text() + '" /></td>'
                      h += '  <td><input class="form-control col-9" type="text" value="' + $(r.find('td.col-8')[0]).text() + '" /></td>'
                      h += '  <td><input class="form-control col-10" disabled type="text" value="' + $(r.find('td.col-9')[0]).text() + '" /></td>'
                      h += '  <td><input class="form-control col-11" disabled type="text" value="' + $(r.find('td.col-10')[0]).text() + '" /></td>'
                      h += '  <td class="hidden"><input class="form-control col-12" disabled type="text" value="' + $(r.find('td.col-13')[0]).text() + '" /></td>'
                      h += '</tr>'

                      $('#tbl_tag_edit').append(h)

                    # Attach click event to cancel button when editing
                    $('#btn_edit_cancel_tag').bind 'click', (e) ->
                      # Hide split panel
                      $('#pnl_edit_tag').toggle('slow')

                      # Remove all content from tags table
                      $('#tbl_tag_edit > tbody').empty()

                    # Attach click event to save button when editing
                    $('#btn_edit_save_tag').bind 'click', (e) ->
                      tag = new Array()

                      #Get tag information
                      $('#tbl_tag_edit tbody tr').each (k, v) ->
                        r = $(this)

                        v_tag = new Object()
                        v_tag.bd_tag_num = r.find('input.col-1').val()
                        v_tag.tag_type_cd = r.find('input.col-2').val()
                        v_tag.chop_id = r.find('input.col-3').val()
                        v_tag.tag_value1 = r.find('input.col-4').val()
                        v_tag.tag_value2 = r.find('input.col-5').val()
                        v_tag.tag_value3 = r.find('input.col-6').val()
                        v_tag.tag_value4 = r.find('input.col-7').val()
                        v_tag.tag_value7 = r.find('input.col-8').val()
                        v_tag.tag_value8 = r.find('input.col-9').val()
                        v_tag.tag_qty = r.find('input.col-10').val()
                        v_tag.tag_qty_uom_cd = r.find('input.col-11').val()
                        v_tag.ref_bd_tag_num = r.find('input.col-12').val()

                        tag.push(v_tag)

                      #Get transfer information
                      $.ajax('/common/util/get_transfer_by_id',
                        data: {
                          transfer_num: $('#transfer_num').val()
                        }
                        type: 'GET'
                        beforeSend: (xhr) ->
                          $('.overlay').removeClass('hidden').addClass('show')

                          ###
                          Start progress animation
                          ###
                          $('.loading-spinner').removeClass('hidden').addClass('show')
                        ).done (d) ->
                          console.log 'Done getting transfer '
                          console.log d.transfer
                          console.log d.transfer.from_type_ind

                          if d.transfer.from_type_ind == 0 and d.transfer.to_type_ind == 1 # Transfer from trade to storage
                            edit_transfer_from_trade_to_storage(d.transfer,tag)
                          else if d.transfer.from_type_ind == 0 and d.transfer.to_type_ind == 2 # Transfer from trade to vessel
                            edit_transfer_from_trade_to_vessel(d.transfer,tag)
                          else if d.transfer.from_type_ind == 1 and d.transfer.to_type_ind == 0 # Transfer from storage to trade
                            edit_transfer_from_storage_to_trade(d.transfer,tag)
                          else if d.transfer.from_type_ind == 1 and d.transfer.to_type_ind == 1 # Tansfer from storage to storage
                            edit_transfer_from_storage_to_storage(d.transfer,tag)
                          else if d.transfer.from_type_ind == 1 and d.transfer.to_type_ind == 2 # Transfer from storage to vessel
                            edit_transfer_from_storage_to_vessel(d.transfer,tag)
                          else if d.transfer.from_type_ind == 2 and d.transfer.to_type_ind == 0 # Transfer from vessel to trade
                            edit_transfer_from_vessel_to_trade(d.transfer,tag)
                          else if d.transfer.from_type_ind == 2 and d.transfer.to_type_ind == 1 # Transfer from vessel to storage
                            edit_transfer_from_vessel_to_storage(d.transfer,tag)
                          else
                            console.log 'The combination of transfer you selected does not exist!'
                          
                                                    



                          # $.ajax('/traffic/transfermanager/put_build_draw_tags',
                          #   data: {
                          #     build_draw_num: $('#build_draw_num').val()
                          #     equipment_num: $('#equipment_num').val()
                          #     cargo_num: $('#cargo_num').val()
                          #     cmdty_cd: $('#cmdty_cd').val()
                          #     build_draw_qty: $('#build_draw_qty').val()
                          #     tag: tag
                          #   }
                          #   type: 'POST'
                          #   beforeSend: (xhr) ->
                          #     $('.overlay').removeClass('hidden').addClass('show')

                          #     ###
                          #     Start progress animation
                          #     ###
                          #     $('.loading-spinner').removeClass('hidden').addClass('show')
                          # ).done (d) ->
                          #   ###
                          #   Hide progress animation
                          #   ###
                          #   $('.loading-spinner').removeClass('show').addClass('hidden')

                          #   $('.alert-danger').removeClass('show').addClass('hidden')
                          #   $('.alert-success').removeClass('show').addClass('hidden')

                          #   $('#error_container').html('')
                          #   $('#success_container').html('')

                          #   if d.success == true
                          #     html = ''
                          #     html += '<strong>Tags successfully edited!</strong> Cargo number: ' + d.id
                          #     html += '<div class="clearfix"></div>'
                          #     html += '<br />'
                          #     html += '<a class="btn btn-success btn-sm" data-no-turbolink="true" href="' + window.location + '" role="button">Continue</a>'

                          #     $('#success_container').html(html)

                          #     $('.alert-success').removeClass('hidden').addClass('show')
                          #   else
                          #     $('#error_container').html('<strong>' + d.message + '</strong>')

                          #     $('.alert-danger').removeClass('hidden').addClass('show')

                  when 'lnk_split_tag'
                    obj = new Object()
                    obj.bd_tag_num = $(tr.find('td.col-12')[0]).text()
                    obj.build_draw_num = $('#build_draw_num').val()
                    obj.ref_bd_tag_num = $(tr.find('td.col-13')[0]).text()
                    obj.equipment_num = $('#equipment_num').val()
                    obj.cargo_num = $('#cargo_num').val()
                    obj.tag_type_cd = $(tr.find('td.col-1')[0]).text()
                    obj.tag_value1 = $(tr.find('td.col-3')[0]).text()
                    obj.tag_value2 = $(tr.find('td.col-4')[0]).text()
                    obj.tag_value3 = $(tr.find('td.col-5')[0]).text()
                    obj.tag_value4 = $(tr.find('td.col-6')[0]).text()
                    obj.tag_value7 = $(tr.find('td.col-7')[0]).text()
                    obj.tag_value8 = $(tr.find('td.col-8')[0]).text()
                    obj.tag_qty = $(tr.find('td.col-9')[0]).text()
                    obj.tag_qty_uom_cd = $(tr.find('td.col-10')[0]).text()
                    obj.chop_id = $(tr.find('td.col-2')[0]).text()
                    obj.tag_alloc_qty = $(tr.find('td.col-11')[0]).text()

                    $('#pnl_split_tag').toggle('slow')

                    # Unbind click event
                    $('#btn_split_add_tag').unbind('click')
                    $('#btn_split_cancel_tag').unbind('click')
                    $('#btn_split_save_tag').unbind('click')

                    # Populating tags table
                    h = ''
                    h += '<tr>'
                    h += ' <td><input class="form-control col-1" disabled value="Chop Data" /></td>'
                    h += ' <td><input class="form-control col-2" disabled type="text" value="' + $(tr.find('td.col-2')[0]).text() + '" /></td>'
                    h += ' <td><input class="form-control col-3" type="text" value="' + $(tr.find('td.col-9')[0]).text() + '" /></td>'
                    h += '</tr>'
                    h += '<tr>'
                    h += ' <td><input class="form-control col-1" disabled value="Chop Data" /></td>'
                    h += ' <td><input class="form-control col-2" disabled type="text" value="' + $(tr.find('td.col-2')[0]).text() + '" /></td>'
                    h += ' <td><input class="form-control col-3" type="text" value="0.00" /></td>'
                    h += '</tr>'

                    $('#tbl_tag_split').append(h)

                    # Attach click event to add tag button when splitting
                    $('#btn_split_add_tag').bind 'click', (e) ->
                      html = ''
                      html += '<tr>'
                      html += ' <td><input class="form-control col-1" disabled value="Chop Data" /></td>'
                      html += ' <td><input class="form-control col-2" disabled type="text" value="' + $(tr.find('td.col-2')[0]).text() + '" /></td>'
                      html += ' <td><input class="form-control col-3" type="text" value="0.00" /></td>'
                      html += '</tr>'

                      $('#tbl_tag_split').append(html)

                    # Attach click event to cancel button when splitting
                    $('#btn_split_cancel_tag').bind 'click', (e) ->
                      # Hide split panel
                      $('#pnl_split_tag').toggle('slow')

                      # Remove all content from tags table
                      $('#tbl_tag_split > tbody').empty()

                    # Attach click event to save button when splitting
                    $('#btn_split_save_tag').bind 'click', (e) ->
                      tag = new Array()

                      ################################################################################################################
                      ################################################################################################################
                      # Validations

                      $('#error_container').empty() #clean validator

                      # 1. First tag should be equal or grater than qty allocated
                      firstElement = $('#tbl_tag_split tbody tr:nth-child(1)').find('input.col-3').val();
                      if firstElement < obj.tag_alloc_qty
                        html = ''
                        html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
                        html += ' <li class="parsley-custom-error-message"><strong>First Tag cannot be lower than allocated qty.</strong></li>'
                        html += '</ul>'

                        $('#error_container').append(html)

                        $('.alert-danger').removeClass('hidden').addClass('show')
                        return

                      # 2. Sum of tags qty cannot be grater than the tag qty to split or have min value 0.01
                      sumQty = 0.00
                      hasMinValue = false
                      $('#tbl_tag_split tbody tr:nth-child(n)').each (k, v) ->
                        r = $(this)

                        #check if tag has minimun value 0.01
                        if parseFloat(r.find('input.col-3').val()).toFixed(4) <= 0.0100
                          hasMinValue = true
                          return

                        sumQty += +(parseFloat(r.find('input.col-3').val()).toFixed(4))

                      #If a tag has minimun value
                      if hasMinValue
                        html = ''
                        html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
                        html += ' <li class="parsley-custom-error-message"><strong>Qty cannot be less or equal to 0.01.</strong></li>'
                        html += '</ul>'

                        $('#error_container').append(html)

                        $('.alert-danger').removeClass('hidden').addClass('show')

                        return

                      #If sum is deferent from tag quantity send error
                      if +sumQty.toFixed(4) != +obj.tag_qty
                        html = ''
                        html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
                        html += ' <li class="parsley-custom-error-message"><strong>Qty should be equal to tag quantity.</strong></li>'
                        html += '</ul>'

                        $('#error_container').append(html)

                        $('.alert-danger').removeClass('hidden').addClass('show')
                        return

                      # END VALIDATIONS
                      ################################################################################################################
                      ################################################################################################################

                      $('#tbl_tag_split tbody tr:nth-child(n+2)').each (k, v) ->
                        r = $(this)

                        v_tag = new Object()
                        v_tag.bd_tag_num = ((k + 2) * -1)
                        v_tag.ref_bd_tag_num = obj.ref_bd_tag_num
                        v_tag.tag_type_cd = obj.tag_type_cd
                        v_tag.tag_value1 = obj.tag_value1
                        v_tag.tag_value2 = obj.tag_value2
                        v_tag.tag_value3 = obj.tag_value3
                        v_tag.tag_value4 = obj.tag_value4
                        v_tag.tag_value7 = obj.tag_value7
                        v_tag.tag_value8 = obj.tag_value8
                        v_tag.tag_qty_uom_cd = obj.tag_qty_uom_cd
                        v_tag.chop_id = obj.chop_id
                        v_tag.tag_qty = r.find('input.col-3').val()
                        v_tag.split_src_tag_num = obj.bd_tag_num

                        tag.push(v_tag)

                      $.ajax('/traffic/transfermanager/split_build_draw_tag',
                        data: {
                          build_draw_num: $('#build_draw_num').val()
                          equipment_num: $('#equipment_num').val()
                          cargo_num: $('#cargo_num').val()
                          cmdty_cd: $('#cmdty_cd').val()
                          build_draw_qty: $('#build_draw_qty').val()
                          bd_tag_num: obj.bd_tag_num
                          ref_bd_tag_num: obj.ref_bd_tag_num
                          tag_type_cd: obj.tag_type_cd
                          tag_value1: obj.tag_value1
                          tag_value2: obj.tag_value2
                          tag_value3: obj.tag_value3
                          tag_value4: obj.tag_value4
                          tag_value7: obj.tag_value7
                          tag_value8: obj.tag_value8
                          tag_qty_uom_cd: obj.tag_qty_uom_cd
                          chop_id: obj.chop_id
                          tag_alloc_qty: obj.tag_alloc_qty
                          tag_qty: $('#tbl_tag_split tbody tr:nth-child(1)').find('input.col-3').val()
                          tag: tag
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
                          html += '<strong>Tags successfully splitted!</strong> Transfer number: <a class="alert-link" data-no-turbolink="true" href="/traffic/transfermanager/' + d.id + '">' + d.id + '</a>'
                          html += '<div class="clearfix"></div>'
                          html += '<br />'
                          html += '<a class="btn btn-success btn-sm" data-no-turbolink="true" href="' + window.location + '" role="button">Continue</a>'

                          $('#success_container').html(html)

                          $('.alert-success').removeClass('hidden').addClass('show')
                        else
                          $('#error_container').html('<strong>' + d.message + '</strong>')

                          $('.alert-danger').removeClass('hidden').addClass('show')

                  when 'lnk_delete_tag' then console.log 'delete tag'

###
Function edit_transfer_from_trade_to_storage
###
edit_transfer_from_trade_to_storage = (transfer,tags)->
  $.ajax('/common/util/get_obligation_detail_by_obligation_and_transfer',
    data: {
      obligation_num: transfer.obligation_num
      transfer_num: transfer.transfer_num
    }
    type: 'GET'
    beforeSend: (xhr) ->
      $('.overlay').removeClass('hidden').addClass('show')

      ###
      Start progress animation
      ###
      $('.loading-spinner').removeClass('hidden').addClass('show')
  ).done (response) ->

    list = Array()
    for tag in tags

      #Get tag information
      $.ajax('/common/util/get_tag_by_id',
        data: {
          bd_tag_num: tag.bd_tag_num
        }
        type: 'GET'
        async: false
      ).done (response) ->

        v_tag = new Object()

        v_tag.bd_tag_num = response.tag.bd_tag_num
        v_tag.cargo_num = response.tag.cargo_num
        v_tag.chop_id = response.tag.chop_id
        v_tag.tag_source_ind = response.tag.tag_source_ind
        v_tag.validate_reqd_soft_ind = response.tag.validate_reqd_soft_ind
        v_tag.build_draw_type_ind = response.tag.build_draw_type_ind
        v_tag.build_draw_ind = response.tag.build_draw_ind
        v_tag.tag_adj_qty = response.tag.tag_adj_qty
        v_tag.build_draw_num = response.tag.build_draw_num
        v_tag.equipment_num = response.tag.equipment_num
        v_tag.tag_type_cd = response.tag.tag_type_cd
        v_tag.tag_value1 = tag.tag_value1
        v_tag.tag_value2 = tag.tag_value2
        v_tag.tag_value3 = tag.tag_value3
        v_tag.tag_value4 = tag.tag_value4
        v_tag.tag_value7 = tag.tag_value7
        v_tag.tag_value8 = tag.tag_value8
        v_tag.tag_qty_uom_cd = response.tag.tag_qty_uom_cd  
        v_tag.tag_alloc_qty = response.tag.tag_alloc_qty  
        v_tag.tag_qty = response.tag.tag_qty 
        v_tag.split_src_tag_num = response.tag.split_src_tag_num 

        list.push(v_tag)
    
    # Collect UDFs
    udf = ''
    $.ajax('/common/util/get_transfer_ud',
      data: {
        transfer_num: transfer.transfer_num
      }
      type: 'GET'
      async: false
    ).done (response) ->
      udf = response.udf

    # Collect obligation hdr
    obligHdr = ''
    $.ajax('/common/util/get_obligation_hdr_by_num',
      data: {
        obligation_num: transfer.obligation_num
      }
      type: 'GET'
      async: false
    ).done (response) ->
      obligHdr = response.hdr

    # Collect obligation dtl
    obligDtl = ''
    $.ajax('/common/util/get_obligation_dtl_by_num',
      data: {
        obligation_num: transfer.obligation_num
      }
      type: 'GET'
      async: false
    ).done (response) ->
      obligDtl = response.dtl

    # Collect obligation daily
    daily = ''
    $.ajax('/common/util/get_obligation_daily_by_num',
      data: {
        transfer_num: transfer.transfer_num
      }
      type: 'GET'
      async: false
    ).done (response) ->
      daily = response.daily

    
    $.ajax('/traffic/transfermanager/edit_transfer_from_trade_to_storage',
      data: {
        transfer_num: transfer.transfer_num
        from_type_ind: transfer.from_type_ind
        to_type_ind: transfer.to_type_ind
        location_num: transfer.location_num
        operator_person_num: transfer.operator_person_num
        transfer_comm_dt: transfer.transfer_comm_dt
        transfer_comp_dt: transfer.transfer_comp_dt
        application_dt: transfer.application_dt
        obligation_num: transfer.obligation_num
        from_qty: transfer.from_qty
        from_uom: transfer.from_uom_cd
        to_equipment_num: transfer.to_equipment_num
        to_cargo_num: transfer.to_cargo_num
        to_qty: transfer.to_qty
        to_uom: transfer.to_uom_cd
        term_section_cd: daily.term_section_cd
        effective_dt: transfer.effective_dt
        build_num: transfer.build_num
        bl_num_cd: transfer.bl_num_cd
        bl_dt: transfer.bl_dt
        from_internal_company_num: transfer.from_inv_owner_company_num
        to_internal_company_num: transfer.to_inv_owner_company_num
        obligation_detail_num: obligDtl.obligation_detail_num
        title_transfer_loc_num: obligDtl.title_transfer_loc_num
        title_transfer_dt: obligDtl.title_transfer_dt
        importer_exporter_ind: obligDtl.importer_exporter_ind
        cross_conv_factor: obligDtl.cross_conv_factor
        loi_status_ind: obligDtl.loi_status_ind
        trade_price: obligHdr.std_price
        trade_price_uom_cd: obligHdr.std_price_uom_cd
        trade_price_curr_cd: obligHdr.std_price_curr_cd
        settlement_amount: response.stl_item_hdr[0].extended_amt
        price: obligDtl.price
        tag: list
        lockinfo: $('#lock_info').val()
        daily_build_draw_num: daily.build_draw_num
        daily_detail_dt: daily.daily_detail_dt
        daily_cargo_num: daily.cargo_num
        daily_equipment_num: daily.equipment_num
        daily_cmdty_cd: daily.cmdty_cd
        daily_trade_num: daily.trade_num
        daily_term_section_cd: daily.term_section_cd
        daily_detail_qty: daily.daily_detail_qty
        daily_detail_mass_qty: daily.daily_detail_mass_qty
        daily_detail_vol_qty: daily.daily_detail_vol_qty
        daily_company_num: daily.company_num
        udf: udf
      }
      type: 'POST'
    ).done (d) ->
      ###
      Hide progress animation
      ###
      $('.loading-spinner').removeClass('show').addClass('hidden')

      show_save_build_response(d,transfer)

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
    udf = ''
    $.ajax('/common/util/get_transfer_ud',
      data: {
        transfer_num: transfer.transfer_num
      }
      type: 'GET'
      async: false
    ).done (response) ->
      udf = response.udf

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
        lockinfo: $('#lock_info').val()
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

      #show_save_transfer_response(d)

###
Function edit_transfer_from_storage_to_storage
Param tags is the build tags. Later we needd to get tags from draw
to include in the xml
###
edit_transfer_from_storage_to_storage = (transfer,tags) ->
  console.log 'Editing storage to storage'

  # Collect obligation daily
  transfer_daily_detail = new Array()
  
  $.ajax('/common/util/get_obligation_daily_by_num',
    data: {
      transfer_num: transfer.transfer_num
    }
    type: 'GET'
    async: false
  ).done (response) ->
    
    for value in response.daily
      console.log value
 
      v_daily_detail1 = new Object()
      v_daily_detail1.build_draw_num = value.build_draw_num
      v_daily_detail1.daily_detail_dt = value.daily_detail_dt
      v_daily_detail1.cargo_num = value.cargo_num
      v_daily_detail1.equipment_num = value.equipment_num
      v_daily_detail1.cmdty_cd = value.cmdty_cd
      v_daily_detail1.daily_detail_qty = value.daily_detail_qty
      v_daily_detail1.daily_detail_mass_qty = value.daily_detail_mass_qty
      v_daily_detail1.daily_detail_vol_qty = value.daily_detail_vol_qty
      v_daily_detail1.build_draw_ind = value.build_draw_ind

      transfer_daily_detail.push(v_daily_detail1)

  # Collect UDFs
  udf = ''
  $.ajax('/common/util/get_transfer_ud',
    data: {
      transfer_num: transfer.transfer_num
    }
    type: 'GET'
    async: false
  ).done (response) ->
    udf = response.udf

  lstTags = Array()
  for tag in tags

    #Get tag information
    $.ajax('/common/util/get_tag_by_id',
      data: {
        bd_tag_num: tag.bd_tag_num
      }
      type: 'GET'
      async: false
    ).done (response) ->

      v_tag = new Object()

      v_tag.bd_tag_num = response.tag.bd_tag_num
      v_tag.build_draw_num = response.tag.build_draw_num
      v_tag.equipment_num = response.tag.equipment_num
      v_tag.cargo_num = response.tag.cargo_num
      v_tag.tag_type_cd = response.tag.tag_type_cd
      v_tag.tag_type_ind = response.tag.tag_type_ind
      v_tag.tag_value1 = tag.tag_value1
      v_tag.tag_value2 = tag.tag_value2
      v_tag.tag_value3 = tag.tag_value3
      v_tag.tag_value4 = tag.tag_value4
      v_tag.tag_value7 = tag.tag_value7
      v_tag.tag_value8 = tag.tag_value8
      v_tag.tag_qty_uom_cd = response.tag.tag_qty_uom_cd 
      v_tag.chop_id = response.tag.chop_id 
      v_tag.tag_qty = response.tag.tag_qty 
      v_tag.tag_source_ind = response.tag.tag_source_ind
      v_tag.split_src_tag_num = response.tag.split_src_tag_num 
      v_tag.validate_reqd_soft_ind = response.tag.validate_reqd_soft_ind
      v_tag.build_draw_type_ind = response.tag.build_draw_type_ind
      v_tag.build_draw_ind = response.tag.build_draw_ind
      v_tag.tag_adj_qty = response.tag.tag_adj_qty
      v_tag.ref_bd_tag_num = value.ref_bd_tag_num
      
      lstTags.push(v_tag)

  #Get tag information
  $.ajax('/common/util/get_tags_from_build_draw',
    data: {
      build_draw_num: transfer.draw_num
    }
    type: 'GET'
    async: false
  ).done (response) ->

    for value in response.tags
      v_tag = new Object()

      v_tag.bd_tag_num = value.bd_tag_num
      v_tag.build_draw_num = value.build_draw_num
      v_tag.equipment_num = value.equipment_num
      v_tag.cargo_num = value.cargo_num
      v_tag.tag_type_cd = value.tag_type_cd
      v_tag.tag_type_ind = value.tag_type_ind
      v_tag.tag_value1 = value.tag_value1
      v_tag.tag_value2 = value.tag_value2
      v_tag.tag_value3 = value.tag_value3
      v_tag.tag_value4 = value.tag_value4
      v_tag.tag_value7 = value.tag_value7
      v_tag.tag_value8 = value.tag_value8
      v_tag.tag_qty_uom_cd = value.tag_qty_uom_cd 
      v_tag.chop_id = value.chop_id 
      v_tag.tag_qty = value.tag_qty 
      v_tag.tag_source_ind = value.tag_source_ind
      v_tag.split_src_tag_num = value.split_src_tag_num 
      v_tag.validate_reqd_soft_ind = value.validate_reqd_soft_ind
      v_tag.build_draw_type_ind = value.build_draw_type_ind
      v_tag.build_draw_ind = value.build_draw_ind
      v_tag.tag_adj_qty = value.tag_adj_qty
      v_tag.ref_bd_tag_num = value.ref_bd_tag_num
      
      lstTags.push(v_tag)

      console.log v_tag

      
  $.ajax('/traffic/transfermanager/edit_transfer_from_storage_to_storage',
    data: {
      transfer_num: transfer.transfer_num
      from_type_ind: transfer.from_type_ind
      to_type_ind: transfer.to_type_ind
      location_num: transfer.location_num
      operator_person_num: transfer.operator_person_num
      transfer_comm_dt: transfer.transfer_comm_dt
      transfer_comp_dt: transfer.transfer_comp_dt
      application_dt: transfer.application_dt
      from_equipment_num: transfer.from_equipment_num
      from_cargo_num: transfer.from_cargo_num
      from_qty: transfer.from_qty
      from_uom: transfer.from_uom_cd
      to_equipment_num: transfer.to_equipment_num
      to_cargo_num: transfer.to_cargo_num
      to_qty: transfer.to_qty
      to_uom: transfer.to_uom_cd
      effective_dt: transfer.effective_dt
      build_num: transfer.build_num
      draw_num: transfer.draw_num
      bl_num_cd: transfer.bl_num_cd
      bl_dt: transfer.bl_dt
      from_internal_company_num: transfer.from_inv_owner_company_num
      to_internal_company_num: transfer.to_inv_owner_company_num
      transfer_daily_detail: transfer_daily_detail
      lockinfo: $('#lockinfo').val()
      tag: lstTags
      udf: udf
      uom_conv_factor: transfer.uom_conv_factor
      uom_conv_factor_ind: transfer.uom_conv_factor_ind
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

    show_save_build_response(d,transfer)

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

show_save_build_response = (r,transfer) ->
  $('.alert-danger').removeClass('show').addClass('hidden')
  $('.alert-success').removeClass('show').addClass('hidden')

  $('#error_container').html('')
  $('#success_container').html('')

  console.log 'Imprimir'
  console.log transfer

  if r.success == true
    html = ''
    html += '<strong>Tags successfully edited!</strong> Build Number: <a class="alert-link" data-no-turbolink="true" href="/traffic/transfermanager/' + transfer.build_num + '/builddraw">' + transfer.build_num + '</a>'
    html += '<div class="clearfix"></div>'
    html += '<br />'
    html += '<a class="btn btn-success btn-sm" data-no-turbolink="true" href="/traffic/transfermanager/' + transfer.build_num + '/builddraw" role="button" style="margin-right: 10px;">Continue</a>'
    html += '<a class="btn btn-warning btn-sm" data-no-turbolink="true" href="/traffic/transfermanager/' + transfer.transfer_num + '/edit" role="button" style="margin-right: 10px;">Edit Transfer</a>'

    $('#success_container').html(html)

    $('.alert-success').removeClass('hidden').addClass('show')
  else
    $('.overlay').removeClass('show').addClass('hidden')

    $('#error_container').html('<strong>' + r.message + '</strong>')

    $('.alert-danger').removeClass('hidden').addClass('show')

