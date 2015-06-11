# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  tbl = $('#tbl_trade').DataTable
    bProcessing: true
    bServerSide: true
    deferRender: true
    lengthChange: false
    lengthMenu: [10, 30, 50, -1]
    ordering: false
    sAjaxSource: $('#tbl_trade').data('source')
    scrollX: true
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
