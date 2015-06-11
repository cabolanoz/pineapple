# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  # Draw table
  if $('#tbl_allocation_draw > tbody > tr > td[colspan]').length <= 0
    tbl_a_d = $('#tbl_allocation_draw').DataTable
      aoColumnDefs: [
        {
          aTargets: [9]
          visible: false
        }
      ]
      info: false
      lengthChange: false
      lengthMenu: [6, 26, 46, -1]
      ordering: false

    $('#tbl_allocation_draw tbody').on 'click', 'tr', ->
      draw_qty = +tbl_a_d.row($(this)).data()[3]

      if $(this).hasClass('selected')
        $(this).removeClass('selected')
        $('#lgd_draw_qty').text('0.00')
      else
        $(this).addClass('selected')
        $('#lgd_draw_qty').text(draw_qty)

  # Build table
  if $('#tbl_allocation_build > tbody > tr > td[colspan]').length <= 0
    tbl_a_b = $('#tbl_allocation_build').DataTable
      aoColumnDefs: [
        {
          aTargets: [9, 10]
          visible: false
        }
      ]
      info: false
      lengthChange: false
      lengthMenu: [6, 26, 46, -1]
      ordering: false
      fnDrawCallback: ->
        $('#tbl_allocation_build tbody tr').on 'mousedown', 'td', ->
          if event.which == 3
            tr = $(this).closest('tr')
            row = tbl_a_b.row(tr)

            $(tr).contextmenu
              target: '#transfer_allocate_tag_contextmenu'
              before: (e, context) ->
                e.preventDefault

                span = $('#transfer_allocate_tag_contextmenu').find('span')[0]
                if span
                  $(span).text($(row.data()[0]).text())

                return true
              onItem: (context, e) ->
                if e.target.tagName != 'SPAN'
                  switch e.target.id
                    when 'lnk_edit_tag' then window.location.href = '/traffic/transfermanager/' + $(row.data()[0]).text() + '/builddraw'
                    when 'lnk_split_tag' then window.location.href = '/traffic/transfermanager/' + $(row.data()[0]).text() + '/builddraw'

    $('#tbl_allocation_build tbody').on 'click', 'tr', ->
      build_qty_total = +$('#lgd_build_qty').text()
      build_qty_selected = +tbl_a_b.row($(this)).data()[5]

      if $(this).hasClass('selected')
        tags = JSON.parse(tbl_a_b.row($(this)).data()[10])

        if tags.length > 0
          rtta(tags)
        else
          $('#lgd_build_qty').text(build_qty_total - build_qty_selected)

        $(this).removeClass('selected')
      else
        $(this).addClass('selected')
        atta(JSON.parse(tbl_a_b.row($(this)).data()[10]))
        $('#lgd_build_qty').text(build_qty_total + build_qty_selected)

  # Save allocation
  if $('#tbl_allocation_build > tbody > tr > td[colspan]').length <= 0 and $('#tbl_allocation_draw > tbody > tr > td[colspan]').length <= 0
    $('#btn_save_allocation').on 'click', (e) ->
      $('#error_container').find('.parsley-errors-custom').remove()
      $('.alert-danger').removeClass('show').addClass('hidden')

      if $('#tbl_allocation_tag > tbody > tr').length <= 0
        html = ''
        html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
        html += ' <li class="parsley-custom-error-message"><strong>Tags</strong> are required</li>'
        html += '</ul>'

        $('#error_container').append(html)

        $('.alert-danger').removeClass('hidden').addClass('show')

        return

      draw_row = $('#tbl_allocation_draw').DataTable().row('.selected')

      if draw_row.length <= 0
        html = ''
        html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
        html += ' <li class="parsley-custom-error-message"><strong>A draw is required!</strong> Please select a draw from draws table</li>'
        html += '</ul>'

        $('#error_container').append(html)

        $('.alert-danger').removeClass('hidden').addClass('show')

        return

      draw_row_data = draw_row.data()

      build_rows_data = $('#tbl_allocation_build').DataTable().rows('.selected').data()

      v_b = true
      sumQtyToAllocate = 0.00

      #######################################################################
      # 1. Validate if qty to allocate of each tag is equal to qty available
      $.each build_rows_data, (k, v) ->
        tag_rows = $('#tbl_allocation_tag tbody tr').find('td[data-value="' + $(v[0]).text() + '"]').closest('tr')

        if tag_rows.length > 0
          tag_rows.each ->
            r = $(this)

            qty_to_allocate = +r.find('input.col-13').val()

            if qty_to_allocate and qty_to_allocate != 'NaN' and qty_to_allocate > 0
              # sum qty to allocate to other validation
              sumQtyToAllocate += (+r.find('input.col-13').val())

              # validate if qty to allocate is equal to qty available
              if +r.find('input.col-13').val() != +r.find('input.col-12').val() and +r.find('input.col-13').val() > 0
                html = ''
                html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
                html += ' <li class="parsley-custom-error-message"><strong>Qty to Allocate should be equal to Qty Available!</strong> Please split tag of build ' + $(v[0]).text() + '</li>'
                html += '</ul>'

                $('#error_container').append(html)

                $('.alert-danger').removeClass('hidden').addClass('show')

                v_b = false

                return

      #######################################################################
      # Final Validator. If band is true means it pass all validation
      if !v_b
        return

      # END Validation 1
      #######################################################################

      #######################################################################
      # 2. Validate if sum of qty to Allocate is different from draw qty
      if !(sumQtyToAllocate == Math.abs(+draw_row_data[3]))
        html = ''
        html += '<ul class="parsley-errors-list filled parsley-errors-custom">'
        html += ' <li class="parsley-custom-error-message"><strong>Qty to Allocate should be equal to draw quantity!</strong></li>'
        html += '</ul>'

        $('#error_container').append(html)

        $('.alert-danger').removeClass('hidden').addClass('show')

        v_b = false

        return
      # END Validation 2
      #######################################################################

      #######################################################################
      # Final Validator. If band is true means it pass all validation
      if !v_b
        return

      builds = new Array()

      qty_to_alloc = 0

      $.each build_rows_data, (k, v) ->
        tag_rows = $('#tbl_allocation_tag tbody tr').find('td[data-value="' + $(v[0]).text() + '"]').closest('tr')

        if tag_rows.length > 0
          p_qty_to_alloc = 0

          tags = new Array()

          tag_rows.each ->
            r = $(this)

            i_qty_to_allocate = +r.find('input.col-13').val()

            if i_qty_to_allocate and i_qty_to_allocate != 'NaN' and i_qty_to_allocate > 0
              v_tag = new Object()
              v_tag.build_draw_num = $(v[0]).text()
              v_tag.tag_type_cd = r.find('input.col-1').val()
              v_tag.ref_bd_tag_num = r.find('input.col-15').val()
              v_tag.bd_tag_num = r.find('input.col-14').val()
              v_tag.tag_value1 = r.find('input.col-3').val()
              v_tag.tag_value2 = r.find('input.col-4').val()
              v_tag.tag_value3 = r.find('input.col-5').val()
              v_tag.tag_value4 = r.find('input.col-6').val()
              v_tag.tag_value7 = r.find('input.col-7').val()
              v_tag.tag_value8 = r.find('input.col-8').val()
              v_tag.tag_alloc_qty = r.find('input.col-11').val()
              v_tag.qty_to_alloc = r.find('input.col-13').val()
              v_tag.tag_qty = r.find('input.col-9').val()
              v_tag.tag_qty_uom_cd = r.find('input.col-10').val()
              v_tag.tag_source_ind = r.find('input.col-16').val()
              v_tag.chop_id = r.find('input.col-2').val()

              p_qty_to_alloc += parseFloat(r.find('input.col-13').val())
              qty_to_alloc += parseFloat(r.find('input.col-13').val())

              tags.push(v_tag)

          if tags.length > 0
            v_build = new Object()

            v_build.build_num = $(v[0]).text()
            v_build.build_qty = p_qty_to_alloc
            v_build.build_dt = format_date(new Date(v[2]))
            v_build.tag = tags

            builds.push(v_build)

      $.ajax('/traffic/transfermanager/put_build_draw_match',
        data: {
          equipment_num: $('#equipment_num').val()
          cargo_num: $('#cargo_num').val()
          strategy_num: $('#strategy_num').val()
          qty_to_alloc: qty_to_alloc
          draw_num: draw_row_data[0]
          draw_qty: draw_row_data[3]
          draw_dt: format_date(new Date(draw_row_data[1]))
          build: builds
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

        # console.log d

        $('.alert-danger').removeClass('show').addClass('hidden')
        $('.alert-success').removeClass('show').addClass('hidden')

        $('#error_container').html('')
        $('#success_container').html('')

        if d.success == true
          html = ''
          html += '<strong>Tags successfully allocated!</strong> Build/Draw number: ' + d.id
          html += '<div class="clearfix"></div>'
          html += '<br />'
          html += '<a class="btn btn-success btn-sm" data-no-turbolink="true" href="' + window.location + '" role="button">Continue</a>'

          $('#success_container').html(html)

          $('.alert-success').removeClass('hidden').addClass('show')
        else
          $('.overlay').removeClass('show').addClass('hidden')

          $('#error_container').html('<strong>' + d.message + '</strong>')

          $('.alert-danger').removeClass('hidden').addClass('show')

atta = (t) ->
  if t.length > 0
    $.each t, (k, v) ->
      if (parseFloat(v.tag_qty) - (if v.tag_alloc_qty != null then parseFloat(v.tag_alloc_qty) else 0)) > 0
        html = ''
        html += '<tr>'
        html += ' <td><input class="col-17 form-control" disabled value="' + v.build_draw_num + '" /></td>'
        html += ' <td data-value="' + v.build_draw_num + '"><input class="col-1 form-control" disabled value="' + v.tag_type_cd + '" /></td>'
        html += ' <td><input class="col-2 form-control" disabled value="' + (if v.chop_id != null then v.chop_id else '') + '" /></td>'
        html += ' <td><input class="col-3 form-control" disabled value="' + v.tag_value1 + '" /></td>'
        html += ' <td><input class="col-4 form-control" disabled value="' + v.tag_value2 + '" /></td>'
        html += ' <td><input class="col-5 form-control" disabled value="' + (if v.tag_value3 != null then v.tag_value3 else '') + '" /></td>'
        html += ' <td><input class="col-6 form-control" disabled value="' + (if v.tag_value4 != null then v.tag_value4 else '') + '" /></td>'
        html += ' <td><input class="col-7 form-control" disabled value="' + (if v.tag_value7 != null then v.tag_value7 else '') + '" /></td>'
        html += ' <td><input class="col-8 form-control" disabled value="' + (if v.tag_value8 != null then v.tag_value8 else '') + '" /></td>'
        html += ' <td class="hidden"><input class="col-9 form-control" disabled value="' + parseFloat(v.tag_qty) + '" /></td>'
        html += ' <td class="hidden"><input class="col-10 form-control" disabled value="' + v.tag_qty_uom_cd + '" /></td>'
        html += ' <td><input class="col-11 form-control" disabled value="' + (if v.tag_alloc_qty != null then parseFloat(v.tag_alloc_qty) else '0.00') + '" /></td>'
        html += ' <td><input class="col-12 form-control" disabled value="' + (parseFloat(v.tag_qty) - (if v.tag_alloc_qty != null then parseFloat(v.tag_alloc_qty) else 0)) + '" /></td>'
        html += ' <td><input class="col-13 form-control" data-parsley-error-message="<strong>Qty To Allocate</strong> is required" data-parsley-errors-container="#error_container" data-parsley-group="grp_transfer" data-parsley-trigger="keyup" data-parsley-type="number" data-parsley-required="true" data-parsley-validation-threshold="1" type="text" value="' + (parseFloat(v.tag_qty) - (if v.tag_alloc_qty != null then parseFloat(v.tag_alloc_qty) else 0)) + '" /></td>'
        html += ' <td class="hidden"><input class="col-14 form-control" disabled value="' + v.bd_tag_num + '" /></td>'
        html += ' <td class="hidden"><input class="col-15 form-control" disabled value="' + v.ref_bd_tag_num + '" /></td>'
        html += ' <td class="hidden"><input class="col-16 form-control" disabled value="' + v.tag_source_ind + '" /></td>'
        html += '</tr>'

        $('#tbl_allocation_tag').append(html)

        $('#tbl_allocation_tag tbody tr td input.col-13').keyup (e) ->
          tr = $(this).closest('tr')

          available_qty = +tr.find('input.col-12').val()
          tag_qty = +$(this).val()

          if tag_qty != 'NaN' and tag_qty > 0 and tag_qty <= available_qty
            build_qty = 0

            $('#tbl_allocation_tag tbody tr').each ->
              row = $(this)

              build_qty += +row.find('input.col-13').val()

            $('#lgd_build_qty').text(build_qty)
          else
            codes = [13, 16, 17, 18, 27, 37, 38, 39, 40]

            kc = e.keyCode

            if kc not in codes
              $(this).val(0)

              build_qty = 0

              $('#tbl_allocation_tag tbody tr').each ->
                row = $(this)

                build_qty += +row.find('input.col-13').val()

              $('#lgd_build_qty').text(build_qty)

rtta = (t) ->
  if t.length > 0
    build_qty_total = +$('#lgd_build_qty').text()

    build_qty = 0

    tr = $('#tbl_allocation_tag tbody tr').find('td[data-value="' + t[0].build_draw_num + '"]').closest('tr')

    $.each tr, (k, v) ->
      available_qty = +$(v).find('input.col-12').val()
      allocate_qty = +$(v).find('input.col-13').val()

      if (available_qty - allocate_qty) > 0
        build_qty += allocate_qty
      else
        build_qty += available_qty

    $('#lgd_build_qty').text(build_qty_total - build_qty)

    tr.fadeOut(400, ->
      tr.remove()
    )

format_date = (dt) ->
  year = dt.getFullYear().toString()
  month = dt.getMonth() + 1
  day = dt.getDate()

  return year + (if month < 10 then '0' + month.toString() else month.toString()) + (if day < 10 then '0' + day.toString() else day.toString())
