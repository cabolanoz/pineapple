# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  if $('.pnl_left_actions').length > 0 and $('.pnl_right_actions').length > 0
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

      if d.success == true
        $('.pnl_left_actions').removeClass('hidden')
      else
        $('.pnl_right_actions').removeClass('hidden')

  if $('#lnk_void_s').length > 0
    $('#lnk_void_s').on 'click', (e) ->
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

  if $('#lnk_break_allocation_s').length > 0
    $('#lnk_break_allocation_s').on 'click', (e) ->
      e.preventDefault()

      $.ajax('/traffic/transfermanager/validate_transfer_build_draw_match',
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
          show_confirm_dialog(new Object(title: 'Break allocation of draw ' + d.draw_num + ' from transfer ' + $('#transfer_num').val(), message_body: 'Are you sure about breaking this allocation?', param: d.draw_num, method: '/traffic/transfermanager/cancel_build_draw_match', message_response: '<strong>Allocation of draw successfully broken!</strong> Draw number:'))
        else
          $('#warning_container').html('<strong>' + d.message + '</strong>')
          $('.alert-warning').removeClass('hidden').addClass('show')

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
