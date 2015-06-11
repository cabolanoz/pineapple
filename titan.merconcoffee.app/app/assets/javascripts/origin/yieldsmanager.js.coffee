# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
	# Init Material Design
	if $.material
		$.material.init()

	#Initalizi click binds

	#Settings - Groups
	btnNewGroup()
	btnEditGroup()

	#Settings - Elements
	onChangeCbElementType()
	btnNewElement()

	#Settings - LineClass
	btnNewLineClass()
	btnEditLineClass()

	#Settings - StandardYields
	onChangeSYCbPhysicalState()
	onChangeSYCbGroup()
	onClickBtnNewSY()

	#1 - Purchasing Yields
	onEnterInputTradeNumber()
	onChangeScreeningValues()
	onChangeDefectValues()

	#Upload Standar file
	$('#btn_upload_yields').fileinput(
      allowedFileExtensions: ['xls', 'xlsx']
      browseClass: "btn btn-success"
      mainClass: "input-group-sm"
      showPreview: false
      uploadUrl: '/origin/yieldsmanager/upload_yields'
    ).on 'filebatchuploadsuccess', (event, data) ->
    	console.log 'El archivo se ha subido'

  #Upload Groups file
	$('#btn_upload_groups').fileinput(
      allowedFileExtensions: ['xls', 'xlsx']
      browseClass: "btn btn-success"
      mainClass: "input-group-sm"
      showPreview: false
      uploadUrl: '/origin/yieldsmanager/upload_groups'
    ).on 'filebatchuploadsuccess', (event, data) ->
    	console.log 'El archivo se ha subido'

  #Upload Elements file
	$('#btn_upload_elements').fileinput(
      allowedFileExtensions: ['xls', 'xlsx']
      browseClass: "btn btn-success"
      mainClass: "input-group-sm"
      showPreview: false
      uploadUrl: '/origin/yieldsmanager/upload_groups'
    ).on 'filebatchuploadsuccess', (event, data) ->
    	console.log 'El archivo se ha subido'

    $('#btn_upload_lineclass').fileinput(
      allowedFileExtensions: ['xls', 'xlsx']
      browseClass: "btn btn-success"
      mainClass: "input-group-sm"
      showPreview: false
      uploadUrl: '/origin/yieldsmanager/upload_lineclass'
    ).on 'filebatchuploadsuccess', (event, data) ->
    	console.log 'El archivo se ha subido'

	tbl = $('#tbl_groups').dataTable
		bProcessing: true
		bServerSide: true
		deferRender: true
		lengthChange: false
		lengthMenu: [10, 30, 50, -1]
		ordering: false
		sAjaxSource: $('#tbl_groups').data('source')
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
			$('#tbl_groups tbody').on 'mousedown', 'td:nth-child(n+2)', ->
				if event.which == 3
					tr = $(this).closest('tr')
					idGroup = tr.find('td:eq(0)').text()
					nameGroup = tr.find('td:eq(1)').text()
					$(tr).contextmenu
						target: '#groups_contextmenu'
						before: (e, context) ->
							e.preventDefault
							return true
						onItem: (context, e) ->
							if e.target.tagName != 'SPAN'
                switch e.target.id
                  when 'lnk_edit_group'
                  	$('.alert-warning').removeClass('show').addClass('hidden')
                  	$('.loading-spinner').removeClass('hidden').addClass('show')
                  	console.log 'edit'
                  	window.location.href = '/origin/yieldsmanager/' + idGroup + '/editGroup'

                  when 'lnk_void_group'
                  	$('.alert-warning').removeClass('show').addClass('hidden')
                  	console.log 'Voiding'
                  	show_confirm_dialog(new Object(title: 'Void Group ' + nameGroup, message_body: 'Are you sure about voiding this group?', param: idGroup, method: '/origin/yieldsmanager/cancel_group', message_response: '<strong>Group successfully voided!</strong> Group number:', ok_link: '/origin/yieldsmanager/groups'))

	tbl = $('#tbl_elements').dataTable
		bProcessing: true
		bServerSide: true
		deferRender: true
		lengthChange: false
		lengthMenu: [10, 30, 50, -1]
		ordering: false
		sAjaxSource: $('#tbl_elements').data('source')
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
			$('#tbl_elements tbody').on 'mousedown', 'td:nth-child(n+2)', ->
				# if event.which == 3
					# tr = $(this).closest('tr')
					# idGroup = tr.find('td:eq(0)').text()
					# nameGroup = tr.find('td:eq(1)').text()
					# $(tr).contextmenu
					# 	target: '#groups_contextmenu'
					# 	before: (e, context) ->
					# 		e.preventDefault
					# 		return true
					# 	onItem: (context, e) ->
					# 		if e.target.tagName != 'SPAN'
     #            switch e.target.id
     #              when 'lnk_edit_group'
     #              	$('.alert-warning').removeClass('show').addClass('hidden')
     #              	$('.loading-spinner').removeClass('hidden').addClass('show')
     #              	console.log 'edit'
     #              	window.location.href = '/origin/yieldsmanager/' + idGroup + '/editGroup'

     #              when 'lnk_void_group'
     #              	$('.alert-warning').removeClass('show').addClass('hidden')
     #              	console.log 'Voiding'
     #              	show_confirm_dialog(new Object(title: 'Void Group ' + nameGroup, message_body: 'Are you sure about voiding this group?', param: idGroup, method: '/origin/yieldsmanager/cancel_group', message_response: '<strong>Group successfully voided!</strong> Group number:', ok_link: '/origin/yieldsmanager/groups'))

	tbl = $('#tbl_lineclass').dataTable
		bProcessing: true
		bServerSide: true
		deferRender: true
		lengthChange: false
		lengthMenu: [10, 30, 50, -1]
		ordering: false
		sAjaxSource: $('#tbl_lineclass').data('source')
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
			$('#tbl_lineclass tbody').on 'mousedown', 'td:nth-child(n+2)', ->
				if event.which == 3
					tr = $(this).closest('tr')
					idLineclass = tr.find('td:eq(0)').text()
					$(tr).contextmenu
						target: '#lineclass_contextmenu'
						before: (e, context) ->
							e.preventDefault
							return true
						onItem: (context, e) ->
							if e.target.tagName != 'SPAN'
								switch e.target.id
									when 'lnk_edit_group'
										$('.alert-warning').removeClass('show').addClass('hidden')
										$('.loading-spinner').removeClass('hidden').addClass('show')
										console.log 'edit'
										window.location.href = '/origin/yieldsmanager/' + idLineclass + '/editLineClass'
									when 'lnk_void_group'
										$('.alert-warning').removeClass('show').addClass('hidden')
										console.log 'Voiding'
										show_confirm_dialog(new Object(title: 'Void Line Clase ' + idLineclass, message_body: 'Are you sure about voiding this line Class?', param: idLineclass, method: '/origin/yieldsmanager/cancel_lineclass', message_response: '<strong>Line Class successfully voided!</strong> LineClass number:', ok_link: '/origin/yieldsmanager/lineclass'))

	tbl = $('#tbl_standarYields').dataTable
		bProcessing: true
		bServerSide: true
		deferRender: true
		lengthChange: false
		lengthMenu: [10, 30, 50, -1]
		ordering: false
		sAjaxSource: $('#tbl_standarYields').data('source')
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
			$('#tbl_standarYields tbody').on 'mousedown', 'td:nth-child(n+2)', ->
				if event.which == 3
					tr = $(this).closest('tr')
					idStandardYields = tr.find('td:eq(0)').text()
					$(tr).contextmenu
						target: '#standardYields_contextmenu'
						before: (e, context) ->
							e.preventDefault
							return true
						onItem: (context, e) ->
							if e.target.tagName != 'SPAN'
								switch e.target.id
									when 'lnk_edit_group'
										$('.alert-warning').removeClass('show').addClass('hidden')
										$('.loading-spinner').removeClass('hidden').addClass('show')
										console.log 'edit'
										window.location.href = '/origin/yieldsmanager/' + idLineclass + '/editStandardYields'
									when 'lnk_void_group'
										$('.alert-warning').removeClass('show').addClass('hidden')
										console.log 'Voiding'
										show_confirm_dialog(new Object(title: 'Void Standard Yield ' + idStandardYields, message_body: 'Are you sure about voiding this Standard Yield?', param: idStandardYields, method: '/origin/yieldsmanager/cancel_standardyield', message_response: '<strong>Standar Yield successfully voided!</strong> ', ok_link: '/origin/yieldsmanager/standardyields'))


###
Initialize save new group
###
btnNewGroup = ->
	$('#btnNewGroup').bind 'click', (e) ->
		e.preventDefault()

		# console.log 'hola, quieres chat? hehehe'
		$.ajax('/origin/yieldsmanager/groupcreate',
			data: {
				description: $('#inputDescription').val()
				gold: $('#toggGold')[0].checked
				sum: $('#toggSum')[0].checked
				physicalState: $( "#cbPhysicalState option:selected" ).val()
				hasParen: $('#parent')[0].checked
				parent: $( "#cbParentGroup option:selected" ).val()
				calcType: $( "#cbCalcType option:selected" ).val()
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
		  show_save_group_response(d)

btnEditGroup = ->
	$('#btnEditGroup').bind 'click', (e) ->
		e.preventDefault()

		# console.log 'hola, quieres chat? hehehe'
		$.ajax('/origin/yieldsmanager/edit_group_by_id',
			data: {
				idGroup: $('#group_num').val()
				description: $('#inputDescription').val()
				gold: $('#toggGold')[0].checked
				sum: $('#toggSum')[0].checked
				physicalState: $( "#cbPhysicalState option:selected" ).val()
				hasParen: $('#parent')[0].checked
				parent: $( "#cbParentGroup option:selected" ).val()
				calcType: $( "#cbCalcType option:selected" ).val()
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
		  show_edit_group_response(d)

###########################################################################################
## Elements
onChangeCbElementType = ->
	$('#cbElementType_new').change ->
		value = $('#cbElementType_new').val()
		console.log value
		if value == "1"
			$('#inputElement_container').removeClass("hidden")
			$('#cbCommodity_container').addClass("hidden")
		else
			$('#inputElement_container').addClass("hidden")
			$('#cbCommodity_container').removeClass("hidden")

btnNewElement = ->
$('#btnNewElement').bind 'click', (e) ->
	e.preventDefault()
	$.ajax('/origin/yieldsmanager/elementcreate',
	data: {
		type: $( "#cbElementType_new option:selected" ).val()
		value:  if ($( "#cbElementType_new option:selected" ).val() == "1") then $('#inputElementDesc_new').val() else $( "#cbCommodity_new option:selected" ).val()
		group: $('#cbGroup_new option:selected').val()
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
		show_save_element_response(d)
###########################################################################################
###########################################################################################

###########################################################################################
## Line Class
btnEditLineClass = ->
	$('#btnEditLineClass').bind 'click', (e) ->
		e.preventDefault()

		# console.log 'hola, quieres chat? hehehe'
		$.ajax('/origin/yieldsmanager/edit_lineclass_by_id',
			data: {
				idLineClass: $('#lineclass').val()
				physicalState: $( "#cbPhysicalState option:selected" ).val()
				groupNum: $( "#cbGroup option:selected" ).val()
				element: $( "#cbElement option:selected" ).val()
				forpay: $('#forpay')[0].checked
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
		  show_edit_lineclass_response(d)

btnNewLineClass = ->
	$('#btnNewLineClass').bind 'click', (e) ->
		e.preventDefault()

		# console.log 'hola, quieres chat? hehehe'
		$.ajax('/origin/yieldsmanager/new_lineclass',
			data: {
				physicalState: $( "#cbPhysicalState option:selected" ).val()
				groupNum: $( "#cbGroup option:selected" ).val()
				element: $( "#cbElement option:selected" ).val()
				forpay: $('#forpay')[0].checked
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
		  show_save_lineclass_response(d)


###########################################################################################
## Line Class
onChangeSYCbPhysicalState = ->
	$('#cbPhysicalState').change ->
		physicalState = $('#cbPhysicalState').val()
		group = $('#cbGroup').val()
		loadElements(physicalState,group)

onChangeSYCbGroup = ->
	$('#cbGroup').change ->
		physicalState = $('#cbPhysicalState').val()
		group = $('#cbGroup').val()
		loadElements(physicalState,group)
		
loadElements = (physicalStateNum,groupNum) ->
	$.ajax('/origin/yieldsmanager/load_elements',
		data: {
			physicalState: physicalStateNum
			group: groupNum
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
	  if d.response
        html = ''

        for i in d.response
          html += '<tr>'
          html += ' <td>' + i.YE_Id + '</td>'
          html += ' <td>' + i.YE_Element + '</td>'
          html += ' <td><input class="ps-values" value="' + ('') + '" /></td>'
          html += '</tr>'

        $('#tbl_St_elements tbody').empty()
        $('#tbl_St_elements').append(html)

onClickBtnNewSY = ->
	$('#btnNewStandardYields').bind 'click', (e) ->
		alert 'Save standard'


	  
		


###########################################################################################
## Purchasing Yields
onEnterInputTradeNumber = ->
	$('#txtTradeNumber').bind 'keypress', (e) ->
		if e.which == 13
			$.ajax('/origin/yieldsmanager/getTrade',
			data: {
				trade: $('#txtTradeNumber').val()
			}
			type: 'GET'
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
				#fill labels

				$('#txtPYCommodity').val(d.obj[0].cmdty_cd)
				$('#txtPYQuantity').val(d.obj[0].trade_qty)
				$('#txtPYUom').val(d.obj[0].qty_uom_cd)

onChangeScreeningValues = ->
	$('.pyscreening-values').change (e) ->
		updateScreening()
	$('#txtPYScreeningWeight').change (e) ->
		updateScreening()

updateScreening = ->
	sum = 0.00 

	$('input.pyscreening-values').each (index,value) ->
		if value.value
			sum += parseFloat(value.value)
			#console.log sum

	#Calc percentaje
	sample = $('#txtPYScreeningWeight').val()
	

	if sample != null 
		percentaje =  (sum/sample)*100
		console.log percentaje
		$('#sumPyScreening').text(sum)
		$('#sumPyScreening').removeClass("hidden")

		if sample != ""
			$('#totalPyScreening').text(percentaje + "%")
			$('#totalPyScreening').removeClass("hidden")
		else
			$('#totalPyScreening').text("0%")
			$('#totalPyScreening').addClass("hidden")
		
	else
		$('#sumPyScreening').text("0")
		$('#totalPyScreening').text("0%")
		$('#totalPyScreening').addClass("hidden")
		$('#sumPyScreening').addClass("hidden")


onChangeDefectValues = ->
	$('.pyDefect-values').change (e) ->
		updateDefects()
	$('#txtPYDefectWeight').change (e) ->
		updateDefects()

updateDefects = ->
	sum = 0.00 

	$('input.pyDefect-values').each (index,value) ->
		if value.value
			sum += parseFloat(value.value)
			#console.log sum

	#Calc percentaje
	sample = $('#txtPYDefectWeight').val()

	if sample != null 
		percentaje =  (sum/sample)*100
		$('#sumPyDefects').text(sum)
		$('#sumPyDefects').removeClass("hidden")

		if sample != ""
			$('#totalPyDefects').text(percentaje + "%")
			$('#totalPyDefects').removeClass("hidden")
		else
			$('#totalPyDefects').text("0%")
			$('#totalPyDefects').addClass("hidden")
		
	else
		$('#sumPyDefects').text("0")
		$('#totalPyDefects').text("0%")
		$('#totalPyDefects').addClass("hidden")
		$('#sumPyDefects').addClass("hidden")



###########################################################################################
###########################################################################################






show_save_group_response = (r) ->
  $('.alert-danger').removeClass('show').addClass('hidden')
  $('.alert-success').removeClass('show').addClass('hidden')

  $('#error_container').html('')
  $('#success_container').html('')

  if r.success == true
    html = ''
    html += '<strong>Group successfully saved!</strong>'
    html += '<div class="clearfix"></div>'
    html += '<br />'
    html += '<a class="btn btn-success btn-sm" data-no-turbolink="true" href="/origin/yieldsmanager/groups" role="button" style="margin-right: 10px;">Groups</a>'


    $('#success_container').html(html)

    $('.alert-success').removeClass('hidden').addClass('show')
  else
    $('#error_container').html('<strong>' + r.message + '</strong>')

    $('.alert-danger').removeClass('hidden').addClass('show')

show_edit_group_response = (r) ->
  $('.alert-danger').removeClass('show').addClass('hidden')
  $('.alert-success').removeClass('show').addClass('hidden')

  $('#error_container').html('')
  $('#success_container').html('')

  if r.success == true
    html = ''
    html += '<strong>Group successfully edited!</strong>'
    html += '<div class="clearfix"></div>'
    html += '<br />'
    html += '<a class="btn btn-success btn-sm" data-no-turbolink="true" href="/origin/yieldsmanager/groups" role="button" style="margin-right: 10px;">Groups</a>'


    $('#success_container').html(html)

    $('.alert-success').removeClass('hidden').addClass('show')
  else
    $('#error_container').html('<strong>' + r.message + '</strong>')

    $('.alert-danger').removeClass('hidden').addClass('show')

show_save_lineclass_response = (r) ->
  $('.alert-danger').removeClass('show').addClass('hidden')
  $('.alert-success').removeClass('show').addClass('hidden')

  $('#error_container').html('')
  $('#success_container').html('')

  if r.success == true
    html = ''
    html += '<strong>Line Class successfully created!</strong>'
    html += '<div class="clearfix"></div>'
    html += '<br />'
    html += '<a class="btn btn-success btn-sm" data-no-turbolink="true" href="/origin/yieldsmanager/lineclass" role="button" style="margin-right: 10px;">Line Class</a>'


    $('#success_container').html(html)

    $('.alert-success').removeClass('hidden').addClass('show')
  else
    $('#error_container').html('<strong>' + r.message + '</strong>')

    $('.alert-danger').removeClass('hidden').addClass('show')

show_edit_lineclass_response = (r) ->
  $('.alert-danger').removeClass('show').addClass('hidden')
  $('.alert-success').removeClass('show').addClass('hidden')

  $('#error_container').html('')
  $('#success_container').html('')

  if r.success == true
    html = ''
    html += '<strong>Line Class successfully edited!</strong>'
    html += '<div class="clearfix"></div>'
    html += '<br />'
    html += '<a class="btn btn-success btn-sm" data-no-turbolink="true" href="/origin/yieldsmanager/lineclass" role="button" style="margin-right: 10px;">Line Class</a>'


    $('#success_container').html(html)

    $('.alert-success').removeClass('hidden').addClass('show')
  else
    $('#error_container').html('<strong>' + r.message + '</strong>')

    $('.alert-danger').removeClass('hidden').addClass('show')

show_save_element_response = (r) ->
  $('.alert-danger').removeClass('show').addClass('hidden')
  $('.alert-success').removeClass('show').addClass('hidden')

  $('#error_container').html('')
  $('#success_container').html('')

  if r.success == true
    html = ''
    html += '<strong>Element successfully saved!</strong>'
    html += '<div class="clearfix"></div>'
    html += '<br />'
    html += '<a class="btn btn-success btn-sm" data-no-turbolink="true" href="/origin/yieldsmanager/elements" role="button" style="margin-right: 10px;">Elements</a>'


    $('#success_container').html(html)

    $('.alert-success').removeClass('hidden').addClass('show')
  else
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
        html += '<a class="btn btn-success btn-sm" data-no-turbolink="true" href="'+obj.ok_link+'" role="button">Ok</a>'

        $('#success_container').html(html)

        $('.alert-success').removeClass('hidden').addClass('show')
      else
        $('#error_container').html('<strong>' + d.message + '</strong>')

        $('.alert-danger').removeClass('hidden').addClass('show')
