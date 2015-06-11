# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $('#btn_close_modal').on 'click', (e) ->
    e.preventDefault()
    $('.modal').removeClass('show').addClass('hidden')

  $('.alert-danger > button[type="button"]').on 'click', (e) ->
    e.preventDefault()
    $('.alert-danger').removeClass('show').addClass('hidden')

  $('.alert-warning > button[type="button"]').on 'click', (e) ->
    e.preventDefault()
    $('.alert-warning').removeClass('show').addClass('hidden')

  tbl = $('#tbl_transfer').DataTable
    aoColumnDefs: [
      {
        aTargets: [12, 13, 14, 15, 16]
        sClass: 'info'
      }
      {
        aTargets: [17, 18, 19, 20, 21]
        sClass: 'success'
      }
    ]
    bProcessing: true
    bServerSide: true
    columns: [
      { width: '100px' }
      { width: '75px' }
      { width: '120px' }
      { width: '100px' }
      { width: '100px' }
      { width: '100px' }
      { width: '120px' }
      { width: '100px' }
      { width: '110px' }
      { width: '75px' }
      { width: '75px' }
      { width: '100px' }
      { width: '80px' }
      { width: '130px' }
      { width: '100px' }
      { width: '130px' }
      { width: '100px' }
      { width: '80px' }
      { width: '130px' }
      { width: '100px' }
      { width: '130px' }
      { width: '100px' }
    ]
    deferRender: true
    lengthChange: false
    lengthMenu: [10, 30, 50, -1]
    ordering: false
    sAjaxSource: $('#tbl_transfer').data('source')
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

      $('#tbl_transfer tbody').on 'mousedown', 'td:nth-child(n+2)', ->
        if event.which == 3
          tr = $(this).closest('tr')
          row = tbl.row(tr)

          $(tr).contextmenu
            target: '#transfer_contextmenu'
            before: (e, context) ->
              e.preventDefault

              span = $('#transfer_contextmenu').find('span')[0]
              if span
                $(span).text($(row.data()[0]).text())

              return true
            onItem: (context, e) ->
              if e.target.tagName != 'SPAN'
                switch e.target.id
                  when 'lnk_edit'
                    $('.alert-warning').removeClass('show').addClass('hidden')

                    if $(row.data()[1]).text() != 'Void'
                      $.ajax('/traffic/transfermanager/validate_transfer_build_draw_tags',
                        data: {
                          id: $(row.data()[0]).text()
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
                          window.location.href = '/traffic/transfermanager/' + $(row.data()[0]).text() + '/edit'
                        else
                          $('#warning_container').html('<strong>One or more tags are currently allocated, please do a break allocation first before editing.</strong>')
                          $('.alert-warning').removeClass('hidden').addClass('show')
                    else
                      html = ''
                      html += '<strong>Ooops!</strong> Cannot edit a voided transfer'
                      $('#warning_container').html(html)
                      $('.alert-warning').removeClass('hidden').addClass('show')
                  when 'lnk_void'
                    $('.alert-warning').removeClass('show').addClass('hidden')

                    if $(row.data()[1]).text() != 'Void'
                      $.ajax('/traffic/transfermanager/validate_transfer_build_draw_tags',
                        data: {
                          id: $(row.data()[0]).text()
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
                          show_confirm_dialog(new Object(title: 'Void Transfer ' + $(row.data()[0]).text(), message_body: 'Are you sure about voiding this transfer?', param: $(row.data()[0]).text(), method: '/traffic/transfermanager/cancel_transfer', message_response: '<strong>Transfer successfully voided!</strong> Transfer number:'))
                        else
                          $('#warning_container').html('<strong>' + d.message + '</strong>')
                          $('.alert-warning').removeClass('hidden').addClass('show')
                    else
                      html = ''
                      html += '<strong>Ooops!</strong> Transfer already voided'
                      $('#warning_container').html(html)
                      $('.alert-warning').removeClass('hidden').addClass('show')
                  when 'lnk_allocate'
                    $('.alert-warning').removeClass('show').addClass('hidden')

                    if $(row.data()[1]).text() != 'Void'
                      window.location.href = '/traffic/transfermanager/' + $(row.data()[0]).text() + '/allocation'
                    else
                      html = ''
                      html += '<strong>Ooops!</strong> Cannot allocate a voided transfer'
                      $('#warning_container').html(html)
                      $('.alert-warning').removeClass('hidden').addClass('show')
                  when 'lnk_break_allocation'
                    $('.alert-warning').removeClass('show').addClass('hidden')

                    if $(row.data()[1]).text() != 'Void'
                      $.ajax('/traffic/transfermanager/validate_transfer_build_draw_match',
                        data: {
                          id: $(row.data()[0]).text()
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
                          show_confirm_dialog(new Object(title: 'Break allocation of draw ' + d.draw_num + ' from transfer ' + $(row.data()[0]).text(), message_body: 'Are you sure about breaking this allocation?', param: d.draw_num, method: '/traffic/transfermanager/cancel_build_draw_match', message_response: '<strong>Allocation of draw successfully broken!</strong> Draw number:'))
                        else
                          $('#warning_container').html('<strong>' + d.message + '</strong>')
                          $('.alert-warning').removeClass('hidden').addClass('show')
                    else
                      html = ''
                      html += '<strong>Ooops!</strong> Cannot break allocation from a voided transfer'
                      $('#warning_container').html(html)
                      $('.alert-warning').removeClass('hidden').addClass('show')

  # Adding tab functionality on trade from
  if $('#transfer_trade_from_tab').length > 0
    $('#transfer_trade_from_tab a').on 'click', (e) ->
      e.preventDefault()
      $(this).tab('show')

  # Adding tab functionality on trade to
  if $('#transfer_trade_to_tab').length > 0
    $('#transfer_trade_to_tab a').on 'click', (e) ->
      e.preventDefault()
      $(this).tab('show')

  # Adding tab functionality on storage from
  if $('#transfer_storage_from_tab').length > 0
    $('#transfer_storage_from_tab a').on 'click', (e) ->
      e.preventDefault()
      $(this).tab('show')

  # Adding tab functionality on storage to
  if $('#transfer_storage_to_tab').length > 0
    $('#transfer_storage_to_tab a').on 'click', (e) ->
      e.preventDefault()
      $(this).tab('show')

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
        html += '<a class="btn btn-success btn-sm" data-no-turbolink="true" href="/traffic/transfermanager" role="button">Ok</a>'

        $('#success_container').html(html)

        $('.alert-success').removeClass('hidden').addClass('show')
      else
        $('#error_container').html('<strong>' + d.message + '</strong>')

        $('.alert-danger').removeClass('hidden').addClass('show')
