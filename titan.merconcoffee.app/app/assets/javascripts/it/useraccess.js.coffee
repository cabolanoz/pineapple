# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  if $('#tbl_active_directory > tbody > tr > td[colspan]').length <= 0
    tbl_user_dt = $('#tbl_active_directory').DataTable
      info: false
      lengthChange: false
      lengthMenu: [15, 30, 45, -1]

  if $('#user_tab').length > 0
    $('#user_tab a').on 'click', (e) ->
      e.preventDefault()
      $(this).tab('show')

  timeline_block = $('.cd-timeline-block')

  if timeline_block.length > 0
    timeline_block.each ->
      if $(this).offset().top > $(window).scrollTop() + $(window).height() * 0.75
        $(this).find('.cd-timeline-img, .cd-timeline-content').addClass('is-hidden')

    $(window).on 'scroll', ->
      timeline_block.each ->
        if $(this).offset().top <= $(window).scrollTop() + $(window).height() * 0.75 and $(this).find('.cd-timeline-img').hasClass('is-hidden')
          $(this).find('.cd-timeline-img, .cd-timeline-content').removeClass('is-hidden').addClass('bounce-in')

    $('.glyphicon-menu-left').click ->
      $('.btn-menu-left').removeClass('show').addClass('hidden')

      $('.pnl-left-tl').toggle('slow')
      $('.pnl-right-tl').toggle('slow')

    $('.cd-timeline-content a').on 'click', (e) ->
      e.preventDefault()

      val = $(this).attr('data-source')
      dt = $(this).attr('data-time')

      rp = $('.pnl-right-tl')
      rp.html('')

      $('.pnl-left-tl').toggle('slow')
      $('.pnl-right-tl').toggle('slow', ->
        $.ajax('/common/util/get_transaction_log_by_id',
          data: {
            id: val
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

          rp.append(d(data, dt))

          $('.btn-menu-left').removeClass('hidden').addClass('show')
        .fail ->
          rp.html('<h1 style="color: #ed321d;>Unable To Retrieve Transaction Log Data!</h1>')
      )

d = (v, dt) ->
  request = v.xml_request
  request = replace_all(request, "<", "&lt;")
  request = replace_all(request, ">", "&gt;")

  response = v.xml_response
  response = replace_all(response, "<", "&lt;")
  response = replace_all(response, ">", "&gt;")

  h = ''
  h += '<h3>Cesar Bolanos <small>did</small> ' + v.description + ' <small>with</small> ' + v.cxl_user_name + ' <small>user to CXL</small></h3>'
  h += '<div class="clearfix"></div>'
  h += '<h5>' + dt + '</h5>'
  h += '<div class="clearfix"></div>'
  h += '<br />'
  h += '<div class="col-md-6">'
  h += '  <div class="form-horizontal">'
  h += '    <h3 class="heading-a">XML Request</h3>'
  h += '    <div class="clearfix"></div>'
  h += '    <pre>' +  request + '</pre>'
  h += '  </div>'
  h += '</div>'
  h += '<div class="col-md-6">'
  h += '  <div class="form-horizontal">'
  h += '    <h3 class="heading-a">XML Response</h3>'
  h += '    <div class="clearfix"></div>'
  h += '    <pre>' + response + '</pre>'
  h += '  </div>'
  h += '</div>'

  return h

replace_all = (s, search, replace) ->
  return s.replace(new RegExp(escape_reg_exp(search), 'g'), replace)

escape_reg_exp = (s) ->
  return s.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1")
