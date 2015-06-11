class Traffic::TransfermanagerController < ApplicationController

  # ============================================================================
  # index
  # params:
  # return: HTML
  # ============================================================================
  def index
    respond_to do |format|
      format.html
      format.datatable { render :json => TransfersDatatable.new(view_context) }
    end
  end

  # ============================================================================
  # new
  # params:
  # return: HTML
  # ============================================================================
  def new
    respond_to do |format|
      format.html
    end
  end

  # ============================================================================
  # create_transfer_from_trade_to_storage
  # params:
  #   :from_type_ind => 0 | 1 | 2
  #   :to_type_ind => 0 | 1 | 2
  # return: JSON
  # ============================================================================
  def create_transfer_from_trade_to_storage
    # Let's authenticate on CXL before sending any XML
    auth_response = ApplicationHelper.authenticate

    if auth_response['success'] == true
      klazz = XmlMapper.new
      klazz.file_name = 'put_transfer_from_trade_to_storage_new'
      klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
      klazz.val2 = params[:from_type_ind]
      klazz.val3 = params[:to_type_ind]
      klazz.val4 = params[:location_num]
      klazz.val5 = params[:operator_person_num]
      klazz.val6 = Date.parse(params[:transfer_comm_dt]).strftime('%Y%m%d')
      klazz.val7 = Date.parse(params[:transfer_comp_dt]).strftime('%Y%m%d')
      klazz.val8 = params[:obligation_num]
      klazz.val9 = params[:from_qty]
      klazz.val10 = params[:from_uom]
      klazz.val11 = params[:to_equipment_num]
      klazz.val12 = params[:to_cargo_num]
      klazz.val13 = params[:to_qty]
      klazz.val14 = params[:to_uom]
      klazz.val15 = Date.parse(params[:effective_dt]).strftime('%Y%m%d')
      klazz.val16 = params[:bl_num_cd]
      klazz.val17 = Date.parse(params[:bl_dt]).strftime('%Y%m%d')
      klazz.val18 = params[:from_internal_company_num]
      klazz.val19 = params[:to_internal_company_num]
      klazz.val20 = params[:price]
      klazz.val21 = params[:price_uom_cd]
      klazz.val22 = params[:price_curr_cd]
      klazz.val23 = params[:bbl_mt_factor]

      tag = []

      params[:tag].map do |t|
        v_tag = {
          :val1 => t[1]['equipment_num'],
          :val2 => t[1]['cargo_num'],
          :val3 => t[1]['tag_type_cd'],
          :val4 => t[1]['tag_value1'],
          :val5 => t[1]['tag_value2'],
          :val6 => t[1]['tag_value3'],
          :val7 => t[1]['tag_value4'],
          :val8 => t[1]['tag_value7'],
          :val9 => t[1]['tag_value8'],
          :val10 => t[1]['tag_qty'],
          :val11 => t[1]['tag_qty_uom_cd']
        }

        tag.push(v_tag)
      end

      klazz.val24 = tag

      udf = []

      if !params[:udf].blank?
        params[:udf].map do |u|
          v_udf = {
            :val1 => u[1]['udf_cd'],
            :val2 => u[1]['udf_value'],
            :val3 => u[1]['to_from_ind']
          }

          udf.push(v_udf)
        end
      end

      klazz.val25 = udf

      xml_parse = klazz.do_parse

      # Build SOAP helper with proper service, method and XML
      ss = SoapSender.new
      ss.service = APP_SERVICE['transfer']['service_name']
      ss.method = APP_SERVICE['transfer']['save_method']
      ss.session = auth_response['session']
      ss.xml_resource = xml_parse
      ss.sender = session[:username][0].to_s

      # Send SOAP request to server
      xml_from_response = ss.do_request

      if xml_from_response[:success]
        # Build XML decode helper
        decode = XmlDecode.new
        decode.method = APP_SERVICE['transfer']['r_save_method']

        # Decode authentication response
        xml_decode = decode.do_decode(xml_from_response[:soap_response])

        # Find id created
        id = decode.get_tag_content(xml_decode, 'transfer_num')

        # Insert new transaction log
        transaction_log = TransactionLog.new do |t|
          t.user_name = session[:username][0].to_s
          t.cxl_user_name = Rails.application.secrets[:cxl_user_name]
          t.description = APP_SERVICE['transfer']['service_name'] + "::" + APP_SERVICE['transfer']['save_method']
          t.xml_request = (Nokogiri.XML(xml_parse)).to_s
          t.xml_response = xml_decode.to_s
          t.execution_date = DateTime.now
          t.level_response = (id != nil ? "SUCCESS - 200" : "ERROR - 400")
        end

        transaction_log.save

        if id != nil
          render :json => { :success => true, :id => id }
        else
          render :json => { :success => false, :message => 'Unable to save transfer. Please contact your system administrator.'  }
        end
      else
        # Find faultstring
        faultstring = decode.get_tag_content(Nokogiri.XML(xml_from_response[:soap_response]), 'faultstring')

        render :json => { :success => false, :message => faultstring }
      end
    else
      render :json => { :success => false, :message => 'Unable to authenticate to CXL.' }
    end
  end

  # ============================================================================
  # edit_transfer_from_trade_to_storage
  # params:
  #   :transfer_num => [Number]
  #   :from_type_ind => 0 | 1 | 2
  #   :to_type_ind => 0 | 1 | 2
  # return: JSON
  # ============================================================================
  def edit_transfer_from_trade_to_storage
    # Let's authenticate on CXL before sending any XML
    auth_response = ApplicationHelper.authenticate

    if auth_response['success'] == true
      klazz = XmlMapper.new
      klazz.file_name = 'validate_build_draw_tags_trade_to_storage'
      klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
      klazz.val2 = params[:transfer_num]
      klazz.val3 = params[:from_type_ind]
      klazz.val4 = params[:to_type_ind]
      klazz.val5 = params[:location_num]
      klazz.val6 = params[:operator_person_num]
      klazz.val7 = Date.parse(params[:transfer_comm_dt]).strftime('%Y%m%d')
      klazz.val8 = Date.parse(params[:transfer_comp_dt]).strftime('%Y%m%d')
      klazz.val9 = Date.parse(params[:application_dt]).strftime('%Y%m%d')
      klazz.val10 = params[:obligation_num]
      klazz.val11 = params[:from_qty]
      klazz.val12 = params[:from_uom]
      klazz.val13 = params[:to_equipment_num]
      klazz.val14 = params[:to_cargo_num]
      klazz.val15 = params[:to_qty]
      klazz.val16 = params[:to_uom]
      klazz.val17 = params[:term_section_cd]
      klazz.val18 = Date.parse(params[:effective_dt]).strftime('%Y%m%d')
      klazz.val19 = params[:build_num]
      klazz.val20 = params[:bl_num_cd]
      klazz.val21 = Date.parse(params[:bl_dt]).strftime('%Y%m%d')
      klazz.val22 = params[:from_internal_company_num]
      klazz.val23 = params[:to_internal_company_num]
      klazz.val24 = params[:obligation_detail_num]
      klazz.val25 = params[:title_transfer_loc_num]
      klazz.val26 = Date.parse(params[:title_transfer_dt]).strftime('%Y%m%d')
      klazz.val27 = params[:importer_exporter_ind]
      klazz.val28 = params[:cross_conv_factor]
      klazz.val29 = params[:loi_status_ind]
      klazz.val30 = params[:trade_price]
      klazz.val31 = params[:trade_price_uom_cd]
      klazz.val32 = params[:trade_price_curr_cd]
      klazz.val33 = params[:settlement_amount]
      klazz.val34 = params[:price]

      tag = []

      params[:tag].map do |t|
        v_tag = {
          :val1 => t[1]['bd_tag_num'],
          :val2 => t[1]['build_draw_num'],
          :val3 => t[1]['equipment_num'],
          :val4 => t[1]['cargo_num'],
          :val5 => t[1]['tag_type_cd'],
          :val6 => t[1]['tag_value1'],
          :val7 => t[1]['tag_value2'],
          :val8 => t[1]['tag_value3'],
          :val9 => t[1]['tag_value4'],
          :val10 => t[1]['tag_value7'],
          :val11 => t[1]['tag_value8'],
          :val12 => t[1]['tag_qty_uom_cd'],
          :val13 => t[1]['chop_id'],
          :val14 => t[1]['tag_alloc_qty'],
          :val15 => t[1]['tag_qty'],
          :val16 => t[1]['tag_source_ind'],
          :val17 => t[1]['split_src_tag_num'],
          :val18 => t[1]['validate_reqd_soft_ind'],
          :val19 => t[1]['build_draw_type_ind'],
          :val20 => t[1]['build_draw_ind'],
          :val21 => t[1]['tag_adj_qty']
        }

        tag.push(v_tag)
      end

      klazz.val35 = tag

      xml_parse = klazz.do_parse

      # Build SOAP helper with proper service, method and XML
      ss = SoapSender.new
      ss.service = APP_SERVICE['tag']['service_name']
      ss.method = APP_SERVICE['tag']['validate_transfer_method']
      ss.session = auth_response['session']
      ss.xml_resource = xml_parse
      ss.sender = session[:username][0].to_s

      # Send SOAP request to server
      xml_from_response = ss.do_request

      # Build XML decode helper
      decode = XmlDecode.new
      decode.method = APP_SERVICE['tag']['r_validate_transfer_method']

      # Decode authentication response
      xml_decode = decode.do_decode(xml_from_response[:soap_response])

      # Find message_string
      message_string = decode.get_tag_content(xml_decode, 'message_string')

      if message_string == 'Transfer Tags Validated successfully.'
        klazz.file_name = 'put_transfer_from_trade_to_storage_edit'
        klazz.val36 = params[:lockinfo]
        klazz.val37 = params[:daily_build_draw_num]
        klazz.val38 = Date.parse(params[:daily_detail_dt]).strftime('%Y%m%d')
        klazz.val39 = params[:daily_cargo_num]
        klazz.val40 = params[:daily_equipment_num]
        klazz.val41 = params[:daily_cmdty_cd]
        klazz.val42 = params[:daily_trade_num]
        klazz.val43 = params[:daily_term_section_cd]
        klazz.val44 = params[:daily_detail_qty]
        klazz.val45 = params[:daily_detail_mass_qty]
        klazz.val46 = params[:daily_detail_vol_qty]
        klazz.val47 = params[:daily_company_num]

        udf = []

        if !params[:udf].blank?
          params[:udf].map do |u|
            v_udf = {
              :val1 => u[1]['udf_cd'],
              :val2 => u[1]['udf_value'],
              :val3 => u[1]['to_from_ind']
            }

            udf.push(v_udf)
          end
        end

        klazz.val48 = udf

        xml_parse = klazz.do_parse

        # Send SOAP request to server
        ss.service = APP_SERVICE['transfer']['service_name']
        ss.method = APP_SERVICE['transfer']['save_method']
        ss.xml_resource = xml_parse

        # Send SOAP request to server
        xml_from_response = ss.do_request

        if xml_from_response[:success]
          # Build XML decode helper
          decode.method = APP_SERVICE['transfer']['r_save_method']

          # Decode authentication response
          xml_decode = decode.do_decode(xml_from_response[:soap_response])

          # Find id
          id = decode.get_tag_content(xml_decode, 'transfer_num')

          # Insert new transaction log
          transaction_log = TransactionLog.new do |t|
            t.user_name = session[:username][0].to_s
            t.cxl_user_name = Rails.application.secrets[:cxl_user_name]
            t.description = APP_SERVICE['transfer']['service_name'] + "::" + APP_SERVICE['transfer']['save_method']
            t.xml_request = (Nokogiri.XML(xml_parse)).to_s
            t.xml_response = xml_decode.to_s
            t.execution_date = DateTime.now
            t.level_response = (id != nil ? "SUCCESS - 200" : "ERROR - 400")
          end

          transaction_log.save

          if id != nil
            render :json => { :success => true, :id => id }
          else
            render :json => { :success => false, :message => 'Unable to edit transfer. Please contact your system administrator.'  }
          end
        else
          # Find faultstring
          faultstring = decode.get_tag_content(Nokogiri.XML(xml_from_response[:soap_response]), 'faultstring')

          render :json => { :success => false, :message => faultstring }
        end
      else
        render :json => { :success => false, :message => message_string }
      end
    else
      render :json => { :success => false, :message => 'Unable to authenticate to CXL.' }
    end
  end

  # ============================================================================
  # crate_transfer_from_trade_to_vessel
  # params:
  #   :from_type_ind => 0 | 1 | 2
  #   :to_type_ind => 0 | 1 | 2
  # return: JSON
  # ============================================================================
  def create_transfer_from_trade_to_vessel
    # Let's authenticate on CXL before sending any XML
    auth_response = ApplicationHelper.authenticate

    if auth_response['success'] == true

    else
      render :json => { :success => false }
    end
  end

  # ============================================================================
  # create_transfer_from_storage_to_trade
  # params:
  #   :from_type_ind => 0 | 1 | 2
  #   :to_type_ind => 0 | 1 | 2
  # return: JSON
  # ============================================================================
  def create_transfer_from_storage_to_trade
    # Let's authenticate on CXL before sending any XML
    auth_response = ApplicationHelper.authenticate

    if auth_response['success'] == true
      klazz = XmlMapper.new
      klazz.file_name = 'put_transfer_from_storage_to_trade_new'
      klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
      klazz.val2 = params[:from_type_ind]
      klazz.val3 = params[:to_type_ind]
      klazz.val4 = params[:location_num]
      klazz.val5 = params[:operator_person_num]
      klazz.val6 = Date.parse(params[:transfer_comm_dt]).strftime('%Y%m%d')
      klazz.val7 = Date.parse(params[:transfer_comp_dt]).strftime('%Y%m%d')
      klazz.val8 = params[:obligation_num]
      klazz.val9 = params[:from_equipment_num]
      klazz.val10 = params[:from_cargo_num]
      klazz.val11 = params[:from_qty]
      klazz.val12 = params[:from_uom]
      klazz.val13 = params[:to_qty]
      klazz.val14 = params[:to_uom]
      klazz.val15 = Date.parse(params[:effective_dt]).strftime('%Y%m%d')
      klazz.val16 = params[:bl_num_cd]
      klazz.val17 = Date.parse(params[:bl_dt]).strftime('%Y%m%d')
      klazz.val18 = params[:from_internal_company_num]
      klazz.val19 = params[:to_internal_company_num]
      klazz.val20 = params[:price]
      klazz.val21 = params[:price_uom_cd]
      klazz.val22 = params[:price_curr_cd]
      klazz.val23 = params[:bbl_mt_factor]
      klazz.val25 = params[:uom_conv_factor]
      klazz.val26 = params[:uom_conv_factor_ind]

      udf = []

      if !params[:udf].blank?
        params[:udf].map do |u|
          v_udf = {
            :val1 => u[1]['udf_cd'],
            :val2 => u[1]['udf_value'],
            :val3 => u[1]['to_from_ind']
          }

          udf.push(v_udf)
        end
      end

      klazz.val24 = udf

      xml_parse = klazz.do_parse

      # Build SOAP helper with proper service, method and XML
      ss = SoapSender.new
      ss.service = APP_SERVICE['transfer']['service_name']
      ss.method = APP_SERVICE['transfer']['save_method']
      ss.session = auth_response['session']
      ss.xml_resource = xml_parse
      ss.sender = session[:username][0].to_s

      # Send SOAP request to server
      xml_from_response = ss.do_request

      if xml_from_response[:success]
        # Build XML decode helper
        decode = XmlDecode.new
        decode.method = APP_SERVICE['transfer']['r_save_method']

        # Decode authentication response
        xml_decode = decode.do_decode(xml_from_response[:soap_response])

        # Find id created
        id = decode.get_tag_content(xml_decode, 'transfer_num')

        # Insert new transaction log
        transaction_log = TransactionLog.new do |t|
          t.user_name = session[:username][0].to_s
          t.cxl_user_name = Rails.application.secrets[:cxl_user_name]
          t.description = APP_SERVICE['transfer']['service_name'] + "::" + APP_SERVICE['transfer']['save_method']
          t.xml_request = (Nokogiri.XML(xml_parse)).to_s
          t.xml_response = xml_decode.to_s
          t.execution_date = DateTime.now
          t.level_response = (id != nil ? "SUCCESS - 200" : "ERROR - 400")
        end

        transaction_log.save

        if id != nil
          render :json => { :success => true, :id => id }
        else
          render :json => { :success => false, :message => 'Unable to save transfer. Please contact your system administrator.'  }
        end
      else
        # Find faultstring
        faultstring = decode.get_tag_content(Nokogiri.XML(xml_from_response[:soap_response]), 'faultstring')

        render :json => { :success => false, :message => faultstring }
      end
    else
      render :json => { :success => false, :message => 'Unable to authenticate to CXL.' }
    end
  end

  # ============================================================================
  # edit_transfer_from_storage_to_trade
  # params:
  #   :from_type_ind => 0 | 1 | 2
  #   :to_type_ind => 0 | 1 | 2
  # return: JSON
  # ============================================================================
  def edit_transfer_from_storage_to_trade
    # Let's authenticate on CXL before sending any XML
    auth_response = ApplicationHelper.authenticate

    if auth_response['success'] == true
      klazz = XmlMapper.new
      klazz.file_name = 'put_transfer_from_storage_to_trade_edit'
      klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
      klazz.val2 = params[:transfer_num]
      klazz.val3 = params[:from_type_ind]
      klazz.val4 = params[:to_type_ind]
      klazz.val5 = params[:location_num]
      klazz.val6 = params[:operator_person_num]
      klazz.val7 = Date.parse(params[:transfer_comm_dt]).strftime('%Y%m%d')
      klazz.val8 = Date.parse(params[:transfer_comp_dt]).strftime('%Y%m%d')
      klazz.val9 = Date.parse(params[:application_dt]).strftime('%Y%m%d')
      klazz.val10 = params[:obligation_num]
      klazz.val11 = params[:from_equipment_num]
      klazz.val12 = params[:from_cargo_num]
      klazz.val13 = params[:from_qty]
      klazz.val14 = params[:from_uom]
      klazz.val15 = params[:to_qty]
      klazz.val16 = params[:to_uom]
      klazz.val17 = params[:term_section_cd]
      klazz.val18 = Date.parse(params[:effective_dt]).strftime('%Y%m%d')
      klazz.val19 = params[:draw_num]
      klazz.val20 = params[:bl_num_cd]
      klazz.val21 = Date.parse(params[:bl_dt]).strftime('%Y%m%d')
      klazz.val22 = params[:from_internal_company_num]
      klazz.val23 = params[:to_internal_company_num]
      klazz.val24 = params[:obligation_detail_num]
      klazz.val25 = params[:title_transfer_loc_num]
      klazz.val26 = Date.parse(params[:title_transfer_dt]).strftime('%Y%m%d')
      klazz.val27 = params[:importer_exporter_ind]
      klazz.val28 = params[:cross_conv_factor]
      klazz.val29 = params[:loi_status_ind]
      klazz.val30 = params[:trade_price_uom_cd]
      klazz.val31 = params[:trade_price_curr_cd]
      klazz.val32 = params[:daily_build_draw_num]
      klazz.val33 = Date.parse(params[:daily_detail_dt]).strftime('%Y%m%d')
      klazz.val34 = params[:daily_cargo_num]
      klazz.val35 = params[:daily_equipment_num]
      klazz.val36 = params[:daily_cmdty_cd]
      klazz.val37 = params[:daily_trade_num]
      klazz.val38 = params[:daily_term_section_cd]
      klazz.val39 = params[:daily_detail_qty]
      klazz.val40 = params[:daily_detail_mass_qty]
      klazz.val41 = params[:daily_detail_vol_qty]
      klazz.val42 = params[:daily_company_num]
      klazz.val43 = params[:lockinfo]
      klazz.val45 = params[:uom_conv_factor]
      klazz.val46 = params[:uom_conv_factor_ind]

      udf = []

      if !params[:udf].blank?
        params[:udf].map do |u|
          v_udf = {
            :val1 => u[1]['udf_cd'],
            :val2 => u[1]['udf_value'],
            :val3 => u[1]['to_from_ind']
          }

          udf.push(v_udf)
        end
      end

      klazz.val44 = udf

      xml_parse = klazz.do_parse

      # Build SOAP helper with proper service, method and XML
      ss = SoapSender.new
      ss.service = APP_SERVICE['transfer']['service_name']
      ss.method = APP_SERVICE['transfer']['save_method']
      ss.session = auth_response['session']
      ss.xml_resource = xml_parse
      ss.sender = session[:username][0].to_s

      # Send SOAP request to server
      xml_from_response = ss.do_request

      if xml_from_response[:success]
        # Build XML decode helper
        decode = XmlDecode.new
        decode.method = APP_SERVICE['transfer']['r_save_method']

        # Decode authentication response
        xml_decode = decode.do_decode(xml_from_response[:soap_response])

        # Find id created
        id = decode.get_tag_content(xml_decode, 'transfer_num')

        # Insert new transaction log
        transaction_log = TransactionLog.new do |t|
          t.user_name = session[:username][0].to_s
          t.cxl_user_name = Rails.application.secrets[:cxl_user_name]
          t.description = APP_SERVICE['transfer']['service_name'] + "::" + APP_SERVICE['transfer']['save_method']
          t.xml_request = (Nokogiri.XML(xml_parse)).to_s
          t.xml_response = xml_decode.to_s
          t.execution_date = DateTime.now
          t.level_response = (id != nil ? "SUCCESS - 200" : "ERROR - 400")
        end

        transaction_log.save

        if id != nil
          render :json => { :success => true, :id => id }
        else
          render :json => { :success => false, :message => 'Unable to save transfer. Please contact your system administrator.'  }
        end
      else
        # Find faultstring
        faultstring = decode.get_tag_content(Nokogiri.XML(xml_from_response[:soap_response]), 'faultstring')

        render :json => { :success => false, :message => faultstring }
      end
    else
      render :json => { :success => false, :message => 'Unable to authenticate to CXL.' }
    end
  end

  # ============================================================================
  # create_transfer_from_storage_to_storage
  # params:
  #   :from_type_ind => 0 | 1 | 2
  #   :to_type_ind => 0 | 1 | 2
  # return: JSON
  # ============================================================================
  def create_transfer_from_storage_to_storage
    # Let's authenticate on CXL before sending any XML
    auth_response = ApplicationHelper.authenticate

    if auth_response['success'] == true
      klazz = XmlMapper.new
      klazz.file_name = 'put_transfer_from_storage_to_storage_new'
      klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
      klazz.val2 = params[:from_type_ind]
      klazz.val3 = params[:to_type_ind]
      klazz.val4 = params[:location_num]
      klazz.val5 = params[:operator_person_num]
      klazz.val6 = Date.parse(params[:transfer_comm_dt]).strftime('%Y%m%d')
      klazz.val7 = Date.parse(params[:transfer_comp_dt]).strftime('%Y%m%d')
      klazz.val8 = params[:from_equipment_num]
      klazz.val9 = params[:from_cargo_num]
      klazz.val10 = params[:from_qty]
      klazz.val11 = params[:from_uom]
      klazz.val12 = params[:to_equipment_num]
      klazz.val13 = params[:to_cargo_num]
      klazz.val14 = params[:to_qty]
      klazz.val15 = params[:to_uom]
      klazz.val16 = Date.parse(params[:effective_dt]).strftime('%Y%m%d')
      klazz.val17 = params[:bl_num_cd]
      klazz.val18 = Date.parse(params[:bl_dt]).strftime('%Y%m%d')
      klazz.val19 = params[:from_internal_company_num]
      klazz.val20 = params[:to_internal_company_num]
      klazz.val22 = params[:uom_conv_factor]
      klazz.val23 = params[:uom_conv_factor_ind]

      udf = []

      if !params[:udf].blank?
        params[:udf].map do |u|
          v_udf = {
            :val1 => u[1]['udf_cd'],
            :val2 => u[1]['udf_value'],
            :val3 => u[1]['to_from_ind']
          }

          udf.push(v_udf)
        end
      end

      klazz.val21 = udf

      xml_parse = klazz.do_parse

      # Build SOAP helper with proper service, method and XML
      ss = SoapSender.new
      ss.service = APP_SERVICE['transfer']['service_name']
      ss.method = APP_SERVICE['transfer']['save_method']
      ss.session = auth_response['session']
      ss.xml_resource = xml_parse
      ss.sender = session[:username][0].to_s

      # Send SOAP request to server
      xml_from_response = ss.do_request

      if xml_from_response[:success]
        # Build XML decode helper
        decode = XmlDecode.new
        decode.method = APP_SERVICE['transfer']['r_save_method']

        # Decode authentication response
        xml_decode = decode.do_decode(xml_from_response[:soap_response])

        # Find id created
        id = decode.get_tag_content(xml_decode, 'transfer_num')

        # Insert new transaction log
        transaction_log = TransactionLog.new do |t|
          t.user_name = session[:username][0].to_s
          t.cxl_user_name = Rails.application.secrets[:cxl_user_name]
          t.description = APP_SERVICE['transfer']['service_name'] + "::" + APP_SERVICE['transfer']['save_method']
          t.xml_request = (Nokogiri.XML(xml_parse)).to_s
          t.xml_response = xml_decode.to_s
          t.execution_date = DateTime.now
          t.level_response = (id != nil ? "SUCCESS - 200" : "ERROR - 400")
        end

        transaction_log.save

        if id != nil
          render :json => { :success => true, :id => id }
        else
          render :json => { :success => false, :message => 'Unable to save transfer. Please contact your system administrator.'  }
        end
      else
        # Find faultstring
        faultstring = decode.get_tag_content(Nokogiri.XML(xml_from_response[:soap_response]), 'faultstring')

        render :json => { :success => false, :message => faultstring }
      end
    else
      render :json => { :success => false, :message => 'Unable to authenticate to CXL.' }
    end
  end

  # ============================================================================
  # edit_transfer_from_storage_to_storage
  # params:
  #   :from_type_ind => 0 | 1 | 2
  #   :to_type_ind => 0 | 1 | 2
  # return: JSON
  # ============================================================================
  def edit_transfer_from_storage_to_storage
    # Let's authenticate on CXL before sending any XML
    auth_response = ApplicationHelper.authenticate

    if auth_response['success'] == true
      klazz = XmlMapper.new
      klazz.file_name = 'validate_build_draw_tags_storage_to_storage'
      klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
      klazz.val2 = params[:transfer_num]
      klazz.val3 = params[:from_type_ind]
      klazz.val4 = params[:to_type_ind]
      klazz.val5 = params[:location_num]
      klazz.val6 = params[:operator_person_num]
      klazz.val7 = Date.parse(params[:transfer_comm_dt]).strftime('%Y%m%d')
      klazz.val8 = Date.parse(params[:transfer_comp_dt]).strftime('%Y%m%d')
      klazz.val9 = Date.parse(params[:application_dt]).strftime('%Y%m%d')
      klazz.val10 = params[:from_equipment_num]
      klazz.val11 = params[:from_cargo_num]
      klazz.val12 = params[:from_qty]
      klazz.val13 = params[:from_uom]
      klazz.val14 = params[:to_equipment_num]
      klazz.val15 = params[:to_cargo_num]
      klazz.val16 = params[:to_qty]
      klazz.val17 = params[:to_uom]
      klazz.val18 = Date.parse(params[:effective_dt]).strftime('%Y%m%d')
      klazz.val19 = params[:build_num]
      klazz.val20 = params[:draw_num]
      klazz.val21 = params[:bl_num_cd]
      klazz.val22 = Date.parse(params[:bl_dt]).strftime('%Y%m%d')
      klazz.val23 = params[:from_internal_company_num]
      klazz.val24 = params[:to_internal_company_num]
      klazz.val25 = params[:uom_conv_factor]
      klazz.val26 = params[:uom_conv_factor_ind]

      tag = []

      if !params[:tag].blank?
        params[:tag].map do |t|
          v_tag = {
            :val1 => t[1]['bd_tag_num'],
            :val2 => t[1]['build_draw_num'],
            :val3 => t[1]['equipment_num'],
            :val4 => t[1]['cargo_num'],
            :val5 => t[1]['tag_type_cd'],
            :val6 => t[1]['tag_value1'],
            :val7 => t[1]['tag_value2'],
            :val8 => t[1]['tag_value3'],
            :val9 => t[1]['tag_value4'],
            :val10 => t[1]['tag_value7'],
            :val11 => t[1]['tag_value8'],
            :val12 => t[1]['tag_qty_uom_cd'],
            :val13 => t[1]['chop_id'],
            :val14 => t[1]['tag_alloc_qty'],
            :val15 => t[1]['tag_qty'],
            :val16 => t[1]['tag_source_ind'],
            :val17 => t[1]['split_src_tag_num'],
            :val18 => t[1]['validate_reqd_soft_ind'],
            :val19 => t[1]['build_draw_type_ind'],
            :val20 => t[1]['build_draw_ind'],
            :val21 => t[1]['tag_adj_qty'],
            :val22 => t[1]['tag_type_ind'],
            :val23 => t[1]['ref_bd_tag_num']
          }

          tag.push(v_tag)
        end
      end

      klazz.val27 = tag

      xml_parse = klazz.do_parse

      # Build SOAP helper with proper service, method and XML
      ss = SoapSender.new
      ss.service = APP_SERVICE['tag']['service_name']
      ss.method = APP_SERVICE['tag']['validate_transfer_method']
      ss.session = auth_response['session']
      ss.xml_resource = xml_parse
      ss.sender = session[:username][0].to_s

      # Send SOAP request to server
      xml_from_response = ss.do_request

      # Build XML decode helper
      decode = XmlDecode.new
      decode.method = APP_SERVICE['tag']['r_validate_transfer_method']

      # Decode authentication response
      xml_decode = decode.do_decode(xml_from_response[:soap_response])

      # Find message_string
      message_string = decode.get_tag_content(xml_decode, 'message_string')

      if message_string == 'Transfer Tags Validated successfully.'
        klazz.file_name = 'put_transfer_from_storage_to_storage_edit'

        transfer_daily_detail = []

        params[:transfer_daily_detail].map do |t|
          v_daily_detail = {
            :val1 => t[1]['build_draw_num'],
            :val2 => Date.parse(t[1]['daily_detail_dt']).strftime('%Y%m%d'),
            :val3 => t[1]['cargo_num'],
            :val4 => t[1]['equipment_num'],
            :val5 => t[1]['cmdty_cd'],
            :val6 => t[1]['daily_detail_qty'],
            :val7 => t[1]['daily_detail_mass_qty'],
            :val8 => t[1]['daily_detail_vol_qty'],
            :val9 => t[1]['build_draw_ind']
          }

          transfer_daily_detail.push(v_daily_detail)
        end

        klazz.val25 = transfer_daily_detail
        klazz.val26 = params[:lockinfo]

        klazz.val28 = params[:uom_conv_factor]
        klazz.val29 = params[:uom_conv_factor_ind]
        klazz.val30 = tag

        udf = []

        if !params[:udf].blank?
          params[:udf].map do |u|
            v_udf = {
              :val1 => u[1]['udf_cd'],
              :val2 => u[1]['udf_value'],
              :val3 => u[1]['to_from_ind']
            }

            udf.push(v_udf)
          end
        end

        klazz.val27 = udf

        xml_parse = klazz.do_parse

        # Send SOAP request to server
        ss.service = APP_SERVICE['transfer']['service_name']
        ss.method = APP_SERVICE['transfer']['save_method']
        ss.xml_resource = xml_parse

        # Send SOAP request to server
        xml_from_response = ss.do_request

        if xml_from_response[:success]
          # Build XML decode helper
          decode.method = APP_SERVICE['transfer']['r_save_method']

          # Decode authentication response
          xml_decode = decode.do_decode(xml_from_response[:soap_response])

          # Find id
          id = decode.get_tag_content(xml_decode, 'transfer_num')

          # Insert new transaction log
          transaction_log = TransactionLog.new do |t|
            t.user_name = session[:username][0].to_s
            t.cxl_user_name = Rails.application.secrets[:cxl_user_name]
            t.description = APP_SERVICE['transfer']['service_name'] + "::" + APP_SERVICE['transfer']['save_method']
            t.xml_request = (Nokogiri.XML(xml_parse)).to_s
            t.xml_response = xml_decode.to_s
            t.execution_date = DateTime.now
            t.level_response = (id != nil ? "SUCCESS - 200" : "ERROR - 400")
          end

          transaction_log.save

          if id != nil
            render :json => { :success => true, :id => id }
          else
            render :json => { :success => false, :message => 'Unable to edit transfer. Please contact your system administrator.'  }
          end
        else
          # Find faultstring
          faultstring = decode.get_tag_content(Nokogiri.XML(xml_from_response[:soap_response]), 'faultstring')

          render :json => { :success => false, :message => faultstring }
        end
      else
        render :json => { :success => false, :message => message_string }
      end
    else
      render :json => { :success => false, :message => 'Unable to authenticate to CXL.' }
    end
  end

  # ============================================================================
  # create_transfer_from_storage_to_vessel
  # params:
  #   :from_type_ind => 0 | 1 | 2
  #   :to_type_ind => 0 | 1 | 2
  # return: JSON
  # ============================================================================
  def create_transfer_from_storage_to_vessel
    render :json => { :success => false }
  end

  # ============================================================================
  # create_transfer_from_vessel_to_trade
  # params:
  #   :from_type_ind => 0 | 1 | 2
  #   :to_type_ind => 0 | 1 | 2
  # return: JSON
  # ============================================================================
  def create_transfer_from_vessel_to_trade
    render :json => { :success => false }
  end

  # ============================================================================
  # create_transfer_from_vessel_to_storage
  # params:
  #   :from_type_ind => 0 | 1 | 2
  #   :to_type_ind => 0 | 1 | 2
  # return: JSON
  # ============================================================================
  def create_transfer_from_vessel_to_storage
    render :json => { :success => false }
  end

  # ============================================================================
  # validate_transfer_build_draw_tags
  # params:
  #   :id => [Number]
  # return: JSON
  # ============================================================================
  def validate_transfer_build_draw_tags
    transfer = OpsTransfer.find(params[:id])

    if transfer != nil
      message = nil

      if transfer.from_type_ind == 0 and transfer.to_type_ind == 1 # From Trade To Storage
        build_draw_tags = OpsBuildDrawTag.where('build_draw_num = ? AND alloc_status_ind <> ?', transfer.build_num, 2)

        if build_draw_tags != nil and build_draw_tags.any?
          for t in build_draw_tags
            if t.tag_alloc_qty != nil and t.tag_alloc_qty > 0
              message = 'One or more tags are currently allocated, please do a break allocation first.'
              break
            end
          end
        end
      elsif transfer.from_type_ind == 0 and transfer.to_type_ind == 2 # From Trade To Vessel
        build_draw_tags = OpsBuildDrawTag.where('build_draw_num = ? AND alloc_status_ind <> ?', transfer.build_num, 2)

        if build_draw_tags != nil and build_draw_tags.any?
          for t in build_draw_tags
            if t.tag_alloc_qty != nil and t.tag_alloc_qty > 0
              message = 'One or more tags are currently allocated, please do a break allocation first.'
              break
            end
          end
        end
      elsif transfer.from_type_ind == 1 and transfer.to_type_ind == 0 # From Storage To Trade
        build_draw = OpsBuildDraw.where("delivery_active_status_ind = ?", 1).find(transfer.draw_num)

        if build_draw != nil and build_draw.build_draw_qty != build_draw.open_qty
          message = 'One or more tags are currently allocated, please do a break allocation first.'
        end
      elsif transfer.from_type_ind == 1 and transfer.to_type_ind == 1 # From Storage To Storage
        build_draw = OpsBuildDraw.where("delivery_active_status_ind = ?", 1).find(transfer.draw_num)

        if build_draw != nil and build_draw.build_draw_qty != build_draw.open_qty
          message = 'One or more tags are currently allocated, please do a break allocation first.'
        end
      elsif transfer.from_type_ind == 1 and transfer.to_type_ind == 2 # From Storage To Vessel
        build_draw = OpsBuildDraw.where("delivery_active_status_ind = ?", 1).find(transfer.draw_num)

        if build_draw != nil and build_draw.build_draw_qty != build_draw.open_qty
          message = 'One or more tags are currently allocated, please do a break allocation first.'
        end
      elsif transfer.from_type_ind == 2 and transfer.to_type_ind == 0 # From Vessel To Trade
        build_draw_tags = OpsBuildDrawTag.where('build_draw_num = ? AND alloc_status_ind <> ?', transfer.build_num, 2)

        if build_draw_tags != nil and build_draw_tags.any?
          for t in build_draw_tags
            if t.tag_alloc_qty != nil and t.tag_alloc_qty > 0
              message = 'One or more tags are currently allocated, please do a break allocation first.'
              break
            end
          end
        end
      elsif transfer.from_type_ind == 2 and transfer.to_type_ind == 1 # From Vessel To Storage
        build_draw_tags = OpsBuildDrawTag.where('build_draw_num = ? AND alloc_status_ind <> ?', transfer.build_num, 2)

        if build_draw_tags != nil and build_draw_tags.any?
          for t in build_draw_tags
            if t.tag_alloc_qty != nil and t.tag_alloc_qty > 0
              message = 'One or more tags are currently allocated, please do a break allocation first.'
              break
            end
          end
        end
      end

      if message != nil
        render :json => { :success => false, :message => message }
      else
        render :json => { :success => true }
      end
    else
      render :json => { :success => false, :message => 'Unable to retrieve transfer data. Please contact your system administrator.' }
    end
  end

  # ============================================================================
  # cancel_transfer
  # params:
  #   :id => [Number]
  # return: JSON
  # ============================================================================
  def cancel_transfer
    # Let's authenticate on CXL before sending any XML
    auth_response = ApplicationHelper.authenticate

    if auth_response['success'] == true
      klazz = XmlMapper.new
      klazz.file_name = 'cancel_transfer'
      klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
      klazz.val2 = params[:id]

      xml_parse = klazz.do_parse

      # Build SOAP helper with proper service, method and XML
      ss = SoapSender.new
      ss.service = APP_SERVICE['transfer']['service_name']
      ss.method = APP_SERVICE['transfer']['delete_method']
      ss.session = auth_response['session']
      ss.xml_resource = xml_parse
      ss.sender = session[:username][0].to_s

      # Send SOAP request to server
      xml_from_response = ss.do_request

      if xml_from_response[:success]
        # Build XML decode helper
        decode = XmlDecode.new
        decode.method = APP_SERVICE['transfer']['r_delete_method']

        # Decode authentication response
        xml_decode = decode.do_decode(xml_from_response[:soap_response])

        # Find id
        id = decode.get_tag_content(xml_decode, 'transfer_num')

        # Insert new transaction log
        transaction_log = TransactionLog.new do |t|
          t.user_name = session[:username][0].to_s
          t.cxl_user_name = Rails.application.secrets[:cxl_user_name]
          t.description = APP_SERVICE['transfer']['service_name'] + "::" + APP_SERVICE['transfer']['delete_method']
          t.xml_request = (Nokogiri.XML(xml_parse)).to_s
          t.xml_response = xml_decode.to_s
          t.execution_date = DateTime.now
          t.level_response = (id != nil ? "SUCCESS - 200" : "ERROR - 400")
        end

        transaction_log.save

        if id != nil
          render :json => { :success => true, :id => id }
        else
          render :json => { :success => false, :message => 'Unable to void transfer. Please contact your system administrator.'  }
        end
      else
        # Find faultstring
        faultstring = decode.get_tag_content(Nokogiri.XML(xml_from_response[:soap_response]), 'faultstring')

        render :json => { :success => false, :message => faultstring }
      end
    else
      render :json => { :success => false, :message => 'Unable to authenticate to CXL.' }
    end
  end

  # ============================================================================
  # put_build_draw_match
  # params:
  #   :cargo_num => [Number]
  # return: JSON
  # ============================================================================
  def put_build_draw_match
    # Let's authenticate on CXL before sending any XML
    auth_response = ApplicationHelper.authenticate

    if auth_response['success'] == true
      klazz = XmlMapper.new
      klazz.file_name = 'get_build_draw_cargo_details'
      klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
      klazz.val2 = params[:cargo_num]

      xml_parse = klazz.do_parse

      # Build SOAP helper with proper service, method and XML
      ss = SoapSender.new
      ss.service = APP_SERVICE['build_draw']['service_name']
      ss.method = APP_SERVICE['build_draw']['get_cargo_method']
      ss.session = auth_response['session']
      ss.xml_resource = xml_parse
      ss.sender = session[:username][0].to_s

      # Send SOAP request to server
      xml_from_response = ss.do_request

      # Build XML decode helper
      decode = XmlDecode.new
      decode.method = APP_SERVICE['build_draw']['r_get_cargo_method']

      # Decode authentication response
      xml_decode = decode.do_decode(xml_from_response[:soap_response])

      # Find lockinfo
      lockinfo = decode.get_tag_content(xml_decode, 'lockinfo')

      if lockinfo != nil
        klazz.file_name = 'put_build_draw_match'
        klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
        klazz.val2 = params[:equipment_num]
        klazz.val3 = params[:cargo_num]
        klazz.val4 = params[:strategy_num]
        klazz.val5 = params[:qty_to_alloc]
        klazz.val6 = params[:draw_num]
        klazz.val7 = params[:draw_qty]
        klazz.val8 = params[:draw_dt]

        build = []

        params[:build].map do |t|
          tag = []

          t[1]['tag'].map do |tt|
            v_tag = {
              :val1 => tt[1]['build_draw_num'],
              :val2 => tt[1]['tag_type_cd'],
              :val3 => tt[1]['ref_bd_tag_num'],
              :val4 => tt[1]['bd_tag_num'],
              :val5 => tt[1]['tag_value1'],
              :val6 => tt[1]['tag_value2'],
              :val7 => tt[1]['tag_value3'],
              :val8 => tt[1]['tag_value4'],
              :val9 => tt[1]['tag_value7'],
              :val10 => tt[1]['tag_value8'],
              :val11 => tt[1]['qty_to_alloc'],
              :val12 => tt[1]['tag_qty'],
              :val13 => tt[1]['tag_qty_uom_cd'],
              :val14 => tt[1]['tag_source_ind'],
              :val15 => tt[1]['chop_id']
            }

            tag.push(v_tag)
          end

          v_build = {
            :val1 => t[1]['build_num'],
            :val2 => t[1]['build_qty'],
            :val3 => t[1]['build_dt'],
            :val4 => tag
          }

          build.push(v_build)
        end

        klazz.val9 = build
        klazz.val10 = lockinfo

        xml_parse = klazz.do_parse

        # Send SOAP request to server
        ss.service = APP_SERVICE['build_draw']['service_name']
        ss.method = APP_SERVICE['build_draw']['save_method']
        ss.xml_resource = xml_parse

        # Send SOAP request to server
        xml_from_response = ss.do_request

        if xml_from_response[:success]
          # Build XML decode helper
          decode.method = APP_SERVICE['build_draw']['r_save_method']

          # Decode authentication response
          xml_decode = decode.do_decode(xml_from_response[:soap_response])

          # Find id
          id = decode.get_tag_content(xml_decode, 'bd_match_num')

          # Insert new transaction log
          transaction_log = TransactionLog.new do |t|
            t.user_name = session[:username][0].to_s
            t.cxl_user_name = Rails.application.secrets[:cxl_user_name]
            t.description = APP_SERVICE['build_draw']['service_name'] + "::" + APP_SERVICE['build_draw']['save_method']
            t.xml_request = (Nokogiri.XML(xml_parse)).to_s
            t.xml_response = xml_decode.to_s
            t.execution_date = DateTime.now
            t.level_response = (id != nil ? "SUCCESS - 200" : "ERROR - 400")
          end

          transaction_log.save

          if id != nil
            render :json => { :success => true, :id => id }
          else
            render :json => { :success => false, :message => 'Unable to allocate tags. Please contact your system administrator.'  }
          end
        else
          # Find faultstring
          faultstring = decode.get_tag_content(Nokogiri.XML(xml_from_response[:soap_response]), 'faultstring')

          render :json => { :success => false, :message => faultstring }
        end
      else
        render :json => { :success => false, :message => 'Unable to retrieve build/draw data from server. Please contact your system administrator.' }
      end
    else
      render :json => { :success => false, :message => 'Unable to authenticate to CXL.' }
    end
  end

  # ============================================================================
  # validate_transfer_build_draw_match
  # params:
  #   :id => [Number]
  # return: JSON
  # ============================================================================
  def validate_transfer_build_draw_match
    transfer = OpsTransfer.find(params[:id])

    if transfer != nil
      draws_num = _get_build_draws(transfer.build_num)

      if draws_num != nil and draws_num.any?
        transfers_num = OpsBuildDraw.select(:transfer_num).distinct.where('build_draw_num In (?)', draws_num).where('delivery_active_status_ind = ?', 1).map(&:transfer_num)

        if transfers_num != nil and transfers_num.any?
          render :json => { :success => false, :message => 'Some tags related to transfer ' + transfer.transfer_num.to_s + ' are allocated. Please try to do a break allocation on transfers ' + transfers_num.map(&:inspect).join(', ') + ' first.' }
        else
          render :json => { :success => true, :draw_num => transfer.draw_num }
        end
      else
        if transfer.draw_num != nil
          render :json => { :success => true, :draw_num => transfer.draw_num }
        else
          render :json => { :success => false, :message => 'Transfer does not have draws to do a break allocation.' }
        end
      end
    else
      render :json => { :success => false, :message => 'Unable to retrieve transfer data. Please contact your system administrator.' }
    end
  end

  # Return list of draws related to build
  def _get_build_draws(build_num)
    draws_num = nil

    if build_num != nil
      # Find tags from build
      bd_tag_num = OpsBuildDrawTag.select(:bd_tag_num).distinct.where('build_draw_num = ?', build_num).where('alloc_status_ind <> ?', 2).map(&:bd_tag_num)

      # Find draws related to build num through its tags
      if bd_tag_num != nil and bd_tag_num.any?
        draws_num = OpsBuildDrawTag.select(:build_draw_num).distinct.where('ref_bd_tag_num In (?)', bd_tag_num).where('alloc_status_ind <> ?', 2).joins(:build_draw).where('[OPS_BUILD_DRAW].delivery_active_status_ind = ?', 1).where('[OPS_BUILD_DRAW].build_draw_ind = ?', 1).map(&:build_draw_num)
      end
    end

    return draws_num
  end

  # ============================================================================
  # cancel_build_draw_match
  # params:
  #   :id => [Number]
  # return: JSON
  # ============================================================================
  def cancel_build_draw_match
    # Let's authenticate on CXL before sending any XML
    auth_response = ApplicationHelper.authenticate

    if auth_response['success'] == true
      klazz = XmlMapper.new
      klazz.file_name = 'cancel_build_draw_match'
      klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
      klazz.val2 = params[:id]

      xml_parse = klazz.do_parse

      # Build SOAP helper with proper service, method and XML
      ss = SoapSender.new
      ss.service = APP_SERVICE['build_draw']['service_name']
      ss.method = APP_SERVICE['build_draw']['delete_method']
      ss.session = auth_response['session']
      ss.xml_resource = xml_parse
      ss.sender = session[:username][0].to_s

      # Send SOAP request to server
      xml_from_response = ss.do_request

      if xml_from_response[:success]
        # Build XML decode helper
        decode = XmlDecode.new
        decode.method = APP_SERVICE['build_draw']['r_delete_method']

        # Decode authentication response
        xml_decode = decode.do_decode(xml_from_response[:soap_response])

        # Find id
        id = decode.get_tag_content(xml_decode, 'bd_match_num')

        # Insert new transaction log
        transaction_log = TransactionLog.new do |t|
          t.user_name = session[:username][0].to_s
          t.cxl_user_name = Rails.application.secrets[:cxl_user_name]
          t.description = APP_SERVICE['build_draw']['service_name'] + "::" + APP_SERVICE['build_draw']['delete_method']
          t.xml_request = (Nokogiri.XML(xml_parse)).to_s
          t.xml_response = xml_decode.to_s
          t.execution_date = DateTime.now
          t.level_response = (id != nil ? "SUCCESS - 200" : "ERROR - 400")
        end

        transaction_log.save

        if id != nil
          render :json => { :success => true, :id => id }
        else
          render :json => { :success => false, :message => 'Unable to break draw allocation. Please contact your system administrator.'  }
        end
      else
        # Find faultstring
        faultstring = decode.get_tag_content(Nokogiri.XML(xml_from_response[:soap_response]), 'faultstring')

        render :json => { :success => false, :message => faultstring }
      end
    else
      render :json => { :success => false, :message => 'Unable to authenticate to CXL.' }
    end
  end

  # ============================================================================
  # split_build_draw_tag
  # params:
  #   :cargo_num => [Number]
  # return: JSON
  # ============================================================================
  def split_build_draw_tag
    # Let's authenticate on CXL before sending any XML
    auth_response = ApplicationHelper.authenticate

    if auth_response['success'] == true
      klazz = XmlMapper.new
      klazz.file_name = 'get_build_draw_tags'
      klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
      klazz.val2 = params[:cargo_num]

      xml_parse = klazz.do_parse

      # Build SOAP helper with proper service, method and XML
      ss = SoapSender.new
      ss.service = APP_SERVICE['tag']['service_name']
      ss.method = APP_SERVICE['tag']['get_cargo_method']
      ss.session = auth_response['session']
      ss.xml_resource = xml_parse
      ss.sender = session[:username][0].to_s

      # Send SOAP request to server
      xml_from_response = ss.do_request

      # Build XML decode helper
      decode = XmlDecode.new
      decode.method = APP_SERVICE['tag']['r_get_cargo_method']

      # Decode authentication response
      xml_decode = decode.do_decode(xml_from_response[:soap_response])

      # Find lockinfo
      lockinfo = decode.get_tag_content(xml_decode, 'lockinfo')

      if lockinfo != nil
        klazz.file_name = 'split_build_draw_tag'
        klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
        klazz.val2 = params[:build_draw_num]
        klazz.val3 = params[:ref_bd_tag_num]
        klazz.val4 = params[:equipment_num]
        klazz.val5 = params[:cargo_num]
        klazz.val6 = params[:cmdty_cd]
        klazz.val7 = params[:build_draw_qty]
        klazz.val8 = params[:bd_tag_num]
        klazz.val9 = params[:tag_type_cd]
        klazz.val10 = params[:tag_value1]
        klazz.val11 = params[:tag_value2]
        klazz.val12 = params[:tag_value3]
        klazz.val13 = params[:tag_value4]
        klazz.val14 = params[:tag_value7]
        klazz.val15 = params[:tag_value8]
        klazz.val16 = params[:tag_qty_uom_cd]
        klazz.val17 = params[:chop_id]
        klazz.val18 = params[:tag_alloc_qty]
        klazz.val19 = params[:tag_qty]
        klazz.val20 = 1 # TODO: Modify person num - CXLUSER ID

        tag = []

        params[:tag].map do |t|
          v_tag = {
            :val1 => t[1]['bd_tag_num'],
            :val2 => t[1]['ref_bd_tag_num'],
            :val3 => t[1]['tag_type_cd'],
            :val4 => t[1]['tag_value1'],
            :val5 => t[1]['tag_value2'],
            :val6 => t[1]['tag_value3'],
            :val7 => t[1]['tag_value4'],
            :val8 => t[1]['tag_value7'],
            :val9 => t[1]['tag_value8'],
            :val10 => t[1]['tag_qty_uom_cd'],
            :val11 => t[1]['chop_id'],
            :val12 => t[1]['tag_qty'],
            :val13 => t[1]['split_src_tag_num']
          }

          tag.push(v_tag)
        end

        klazz.val21 = tag
        klazz.val22 = lockinfo

        xml_parse = klazz.do_parse

        # Send SOAP request to server
        ss.service = APP_SERVICE['tag']['service_name']
        ss.method = APP_SERVICE['tag']['split_method']
        ss.xml_resource = xml_parse

        # Send SOAP request to server
        xml_from_response = ss.do_request

        if xml_from_response[:success]
          # Build XML decode helper
          decode.method = APP_SERVICE['tag']['r_split_method']

          # Decode authentication response
          xml_decode = decode.do_decode(xml_from_response[:soap_response])

          # Find id
          id = decode.get_tag_content(xml_decode, 'transfer_num')

          # Insert new transaction log
          transaction_log = TransactionLog.new do |t|
            t.user_name = session[:username][0].to_s
            t.cxl_user_name = Rails.application.secrets[:cxl_user_name]
            t.description = APP_SERVICE['tag']['service_name'] + "::" + APP_SERVICE['tag']['split_method']
            t.xml_request = (Nokogiri.XML(xml_parse)).to_s
            t.xml_response = xml_decode.to_s
            t.execution_date = DateTime.now
            t.level_response = (id != nil ? "SUCCESS - 200" : "ERROR - 400")
          end

          transaction_log.save

          if id != nil
            render :json => { :success => true, :id => id }
          else
            render :json => { :success => false, :message => 'Unable to split tags. Please contact your system administrator.'  }
          end
        else
          # Find faultstring
          faultstring = decode.get_tag_content(Nokogiri.XML(xml_from_response[:soap_response]), 'faultstring')

          render :json => { :success => false, :message => faultstring }
        end
      else
        render :json => { :success => false, :message => 'Unable to retrieve tags data from server. Please contact your system administrator' }
      end
    else
      render :json => { :success => false, :message => 'Unable to authenticate to CXL.' }
    end
  end

  # ============================================================================
  # put_build_draw_tags
  # params:
  #   :cargo_num => [Number]
  # return: JSON
  # ============================================================================
  def put_build_draw_tags
    # Let's authenticate on CXL before sending any XML
    auth_response = ApplicationHelper.authenticate

    if auth_response['success'] == true
      klazz = XmlMapper.new
      klazz.file_name = 'get_build_draw_tags'
      klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
      klazz.val2 = params[:cargo_num]

      xml_parse = klazz.do_parse

      # Build SOAP helper with proper service, method and XML
      ss = SoapSender.new
      ss.service = APP_SERVICE['tag']['service_name']
      ss.method = APP_SERVICE['tag']['get_cargo_method']
      ss.session = auth_response['session']
      ss.xml_resource = xml_parse
      ss.sender = session[:username][0].to_s

      # Send SOAP request to server
      xml_from_response = ss.do_request

      # Build XML decode helper
      decode = XmlDecode.new
      decode.method = APP_SERVICE['tag']['r_get_cargo_method']

      # Decode authentication response
      xml_decode = decode.do_decode(xml_from_response[:soap_response])

      # Find lockinfo
      lockinfo = decode.get_tag_content(xml_decode, 'lockinfo')

      if lockinfo != nil
        klazz.file_name = 'validate_transfer_build_draw_tags'
        klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
        klazz.val2 = params[:build_draw_num]
        klazz.val3 = params[:equipment_num]
        klazz.val4 = params[:cargo_num]
        klazz.val5 = params[:cmdty_cd]
        klazz.val6 = params[:build_draw_qty]

        tag = []

        params[:tag].map do |t|
          v_tag = {
            :val1 => t[1]['bd_tag_num'],
            :val2 => t[1]['tag_type_cd'],
            :val3 => t[1]['tag_value1'],
            :val4 => t[1]['tag_value2'],
            :val5 => t[1]['tag_value3'],
            :val6 => t[1]['tag_value4'],
            :val7 => t[1]['tag_value7'],
            :val8 => t[1]['tag_value8'],
            :val9 => t[1]['tag_qty_uom_cd'],
            :val10 => t[1]['chop_id'],
            :val11 => t[1]['tag_qty'],
            :val12 => 1,
            :val13 => t[1]['ref_bd_tag_num']
          }

          tag.push(v_tag)
        end

        klazz.val7 = tag

        xml_parse = klazz.do_parse

        # Build SOAP helper with proper service, method and XML
        ss.service = APP_SERVICE['tag']['service_name']
        ss.method = APP_SERVICE['tag']['validate_transfer_method']
        ss.session = auth_response['session']
        ss.xml_resource = xml_parse

        # Send SOAP request to server
        xml_from_response = ss.do_request

        # Build XML decode helper
        decode.method = APP_SERVICE['tag']['r_validate_transfer_method']

        # Decode authentication response
        xml_decode = decode.do_decode(xml_from_response[:soap_response])

        # Find message_string
        message_string = decode.get_tag_content(xml_decode, 'message_string')

        if message_string == 'Tags are saved successfully.'
          klazz.file_name = 'put_build_draw_tags'
          klazz.val8 = lockinfo

          xml_parse = klazz.do_parse

          # Send SOAP request to server
          ss.service = APP_SERVICE['tag']['service_name']
          ss.method = APP_SERVICE['tag']['save_method']
          ss.xml_resource = xml_parse

          # Send SOAP request to server
          xml_from_response = ss.do_request

          if xml_from_response[:success]
            # Build XML decode helper
            decode.method = APP_SERVICE['tag']['r_save_method']

            # Decode authentication response
            xml_decode = decode.do_decode(xml_from_response[:soap_response])

            # Find id
            id = decode.get_tag_content(xml_decode, 'cargo_num')

            # Insert new transaction log
            transaction_log = TransactionLog.new do |t|
              t.user_name = session[:username][0].to_s
              t.cxl_user_name = Rails.application.secrets[:cxl_user_name]
              t.description = APP_SERVICE['tag']['service_name'] + "::" + APP_SERVICE['tag']['save_method']
              t.xml_request = (Nokogiri.XML(xml_parse)).to_s
              t.xml_response = xml_decode.to_s
              t.execution_date = DateTime.now
              t.level_response = (id != nil ? "SUCCESS - 200" : "ERROR - 400")
            end

            transaction_log.save

            if id != nil
              render :json => { :success => true, :id => id }
            else
              render :json => { :success => false, :message => 'Unable to edit tags. Please contact your system administrator.'  }
            end
          else
            # Find faultstring
            faultstring = decode.get_tag_content(Nokogiri.XML(xml_from_response[:soap_response]), 'faultstring')

            render :json => { :success => false, :message => faultstring }
          end
        else
          render :json => { :success => false, :message => message_string }
        end
      else
        render :json => { :success => false, :message => 'Unable to retrieve tags data from server. Please contact your system administrator' }
      end
    else
      render :json => { :success => false, :message => 'Unable to authenticate to CXL.' }
    end
  end

  # ============================================================================
  # show
  # params:
  #   :id => [Number]
  # return: HTML
  # ============================================================================
  def show
    @transfer = OpsTransfer
      .includes(:from_type)
      .includes(:to_type)
      .includes(:location)
      .includes({ from_itinerary: [ { movements: [ :mot, :mot_type ] } ] })
      .includes(:from_storage)
      .includes(:from_cargo)
      .includes({ to_itinerary: [ { movements: [ :mot, :mot_type ] } ] })
      .includes(:to_storage)
      .includes(:to_cargo)
      .includes({ build: [ { trade: [ :trade_dtl, :strategy, :counterpart, :obligation_hdr ] } ] })
      .includes({ draw: [ { trade: [ :trade_dtl, :strategy, :counterpart, :obligation_hdr ] } ] })
      .includes(:operator)
      .includes(:transfer_at)
      .includes(:from_udf)
      .includes(:to_udf)
      .find(params[:id])

    if @transfer.build_num != nil
      @tags = OpsBuildDrawTag.where("build_draw_num = :bdn", bdn: @transfer.build_num).where("alloc_status_ind <> ?", 2)
    else
      @tags = OpsBuildDrawTag.where("build_draw_num = :bdn", bdn: @transfer.draw_num).where("alloc_status_ind <> ?", 2)
    end
  end

  # ============================================================================
  # edit
  # params:
  #   :id => [Number]
  # return: HTML
  # ============================================================================
  def edit
    # Let's authenticate on CXL before sending any XML
    auth_response = ApplicationHelper.authenticate

    if auth_response['success'] == true
      klazz = XmlMapper.new
      klazz.file_name = 'get_multiple_transfers'
      klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
      klazz.val2 = params[:id]

      xml_parse = klazz.do_parse

      # Build SOAP helper with proper service, method and XML
      ss = SoapSender.new
      ss.service = APP_SERVICE['transfer']['service_name']
      ss.method = APP_SERVICE['transfer']['get_method']
      ss.session = auth_response['session']
      ss.xml_resource = xml_parse
      ss.sender = session[:username][0].to_s

      # Send SOAP request to server
      xml_from_response = ss.do_request

      # Build XML decode helper
      decode = XmlDecode.new
      decode.method = APP_SERVICE['transfer']['r_get_method']

      # Decode authentication response
      xml_decode = decode.do_decode(xml_from_response[:soap_response])

      # Find lockinfo
      @lockinfo = decode.get_tag_content(xml_decode, 'lockinfo')
    end

    @transfer = OpsTransfer
      .includes(:from_type)
      .includes(:to_type)
      .includes(:location)
      .includes(:from_itinerary)
      .includes(:from_storage)
      .includes(:from_cargo)
      .includes(:to_itinerary)
      .includes(:to_storage)
      .includes(:to_cargo)
      .includes({ build: [ { trade: [ :trade_dtl, :strategy, :counterpart, :obligation_hdr ] } ] })
      .includes({ draw: [ { trade: [ :trade_dtl, :strategy, :counterpart, :obligation_hdr ] } ] })
      .includes(:operator)
      .includes(:transfer_at)
      .includes(:transfer_daily_detail)
      .includes(:from_udf)
      .includes(:to_udf)
      .find(params[:id])

    if @transfer.build_num != nil
      @tags = OpsBuildDrawTag.where("build_draw_num = :bdn", bdn: @transfer.build_num).where("alloc_status_ind <> ?", 2)
    else
      @tags = OpsBuildDrawTag.where("build_draw_num = :bdn", bdn: @transfer.draw_num).where("alloc_status_ind <> ?", 2)
    end
  end

  # ============================================================================
  # builddraw
  # params:
  #   :id => [Number]
  # return: HTML
  # ============================================================================
  def builddraw
    @build = OpsBuildDraw
      .includes(:storage)
      .includes(:cargo)
      .includes(:tags)
      .where("build_draw_ind = ?", 0)
      .where("delivery_active_status_ind = ?", 1)
      .find(params[:id])

    if @build.transfer_num != nil
      # Let's authenticate on CXL before sending any XML
      auth_response = ApplicationHelper.authenticate

      if auth_response['success'] == true
        klazz = XmlMapper.new
        klazz.file_name = 'get_multiple_transfers'
        klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
        klazz.val2 = @build.transfer_num

        xml_parse = klazz.do_parse

        # Build SOAP helper with proper service, method and XML
        ss = SoapSender.new
        ss.service = APP_SERVICE['transfer']['service_name']
        ss.method = APP_SERVICE['transfer']['get_method']
        ss.session = auth_response['session']
        ss.xml_resource = xml_parse
        ss.sender = session[:username][0].to_s

        # Send SOAP request to server
        xml_from_response = ss.do_request

        # Build XML decode helper
        decode = XmlDecode.new
        decode.method = APP_SERVICE['transfer']['r_get_method']

        # Decode authentication response
        xml_decode = decode.do_decode(xml_from_response[:soap_response])

        # Find lockinfo
        @lockinfo = decode.get_tag_content(xml_decode, 'lockinfo')
      end
    end
  end

  # ============================================================================
  # allocation
  # params:
  #   :id => [Number]
  # return: HTML
  # ============================================================================
  def allocation
    transfer = OpsTransfer.find(params[:id])

    # equipment_num = transfer.from_equipment_num != nil ? transfer.from_equipment_num : transfer.to_equipment_num
    cargo_num = transfer.from_cargo_num != nil ? transfer.from_cargo_num : transfer.to_cargo_num

    @builds = OpsBuildDraw
      .includes(:storage)
      .includes(:cargo)
      .includes(:tags)
      .where("cargo_num = ?", cargo_num)
      .where("build_draw_ind = ?", 0)
      .where("delivery_active_status_ind = ?", 1)
      .where("open_qty > ?", 0)
      .order("build_draw_num ASC")

    @draws = OpsBuildDraw
      .where("cargo_num = ?", cargo_num)
      .where("build_draw_ind = ?", 1)
      .where("delivery_active_status_ind = ?", 1)
      .where("open_qty < ?", 0)
      .order("build_draw_num ASC")
  end

  def get_level_by_equipment_from
    r = OpsCargo
      .where("equipment_num = ?", params[:query])
      .order("cargo_name ASC")

    @levels = r.map { |l| [ l.cargo_name, l.cargo_num, { 'uom_cd' => l.qty_uom_cd} ] }
  end

  def get_level_by_equipment_to
    r = OpsCargo
      .where("equipment_num = ?", params[:query])
      .order("cargo_name ASC")

    @levels = r.map { |l| [ l.cargo_name, l.cargo_num, { 'uom_cd' => l.qty_uom_cd} ] }
  end

  def get_cargo_by_equipment_from
    r = OpsCargo
      .where("equipment_num = ?", params[:query])
      .order("cargo_name ASC")

    @levels = r.map { |l| [ l.cargo_name, l.cargo_num ] }
  end

  def get_cargo_by_equipment_to
    r = OpsCargo
      .where("equipment_num = ?", params[:query])
      .order("cargo_name ASC")

    @levels = r.map { |l| [ l.cargo_name, l.cargo_num ] }
  end

  def import_tag_from_excel
    spreadsheet = open_spreadsheet(params[:btn_import_tag])

    @rows = []

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[['type', 'value1', 'value2', 'value3', 'value4', 'value5', 'value6', 'value7', 'value8', 'tag_qty', 'exchange_code'], spreadsheet.row(i)].transpose]

      @rows.push(row)
    end

    respond_to do |format|
      format.json { render :json => @rows }
    end
  end

  def open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

end
