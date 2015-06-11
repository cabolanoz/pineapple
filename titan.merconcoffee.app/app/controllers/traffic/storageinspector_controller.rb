class Traffic::StorageinspectorController < ApplicationController

  def index
    @inventory_by_uom = OpsBuildDraw
      .select("[OPS_CARGO].qty_uom_cd, SUM([OPS_BUILD_DRAW].build_draw_qty) AS build_draw_qty, SUM([OPS_BUILD_DRAW].open_qty) AS open_qty, (SUM([OPS_BUILD_DRAW].build_draw_qty) - SUM([OPS_BUILD_DRAW].open_qty)) AS used_qty")
      .joins("INNER JOIN [OPS_CARGO] ON [OPS_BUILD_DRAW].cargo_num = [OPS_CARGO].cargo_num AND [OPS_CARGO].status_ind = 1")
      .where("[OPS_BUILD_DRAW].build_draw_ind = ?", 0)
      .where("[OPS_BUILD_DRAW].delivery_active_status_ind = ?", 1)
      .where("[OPS_BUILD_DRAW].open_qty > ?", 0)
      .group("[OPS_CARGO].qty_uom_cd")
      .order("[OPS_CARGO].qty_uom_cd")

    @inventory_by_storage = OpsBuildDraw
      .select("[OPS_BUILD_DRAW].equipment_num, [REF_STORAGE].storage_cd, SUM([OPS_BUILD_DRAW].build_draw_qty) AS build_draw_qty, SUM([OPS_BUILD_DRAW].open_qty) AS open_qty, (SUM([OPS_BUILD_DRAW].build_draw_qty) - SUM([OPS_BUILD_DRAW].open_qty)) AS used_qty")
      .joins("INNER JOIN [REF_STORAGE] ON [OPS_BUILD_DRAW].equipment_num = [REF_STORAGE].equipment_num AND [REF_STORAGE].status_ind = 1")
      .where("[OPS_BUILD_DRAW].build_draw_ind = ?", 0)
      .where("[OPS_BUILD_DRAW].delivery_active_status_ind = ?", 1)
      .where("[OPS_BUILD_DRAW].open_qty > ?", 0)
      .group("[OPS_BUILD_DRAW].equipment_num, [REF_STORAGE].storage_cd")
      .order("[REF_STORAGE].storage_cd")

    respond_to do |format|
      format.html
      format.json { render :json => { :inventory_by_uom => @inventory_by_uom, :inventory_by_storage => @inventory_by_storage } }
      format.datatable1 { render :json => BuildsDatatable.new(view_context) }
      format.datatable2 { render :json => DrawsDatatable.new(view_context) }
    end
  end

  def get_draw_by_equipment_and_cargo
    @associated_draw = OpsBuildDraw
      .includes(:build_draw_type, :location)
      .where("build_draw_ind = ?", 1)
      .where("delivery_active_status_ind = ?", 1)
      .where("equipment_num = ?", params[:equipment_num])
      .where("cargo_num = ?", params[:cargo_num])
      .order("build_draw_num")

    draw = @associated_draw.pluck(:build_draw_num)

    @available_draw = OpsBuildDraw
      .includes(:build_draw_type, :location)
      .where("build_draw_ind = ?", 1)
      .where("delivery_active_status_ind = ?", 1)
      .where("cargo_num = ?", params[:cargo_num])
      .where("build_draw_num NOT IN (?)", draw)
      .order("build_draw_num")
  end

  def get_inventory_by_storage_group_by_commodity
    @inventory = OpsBuildDraw
      .select("[OPS_BUILD_DRAW].cmdty_cd, SUM([OPS_BUILD_DRAW].build_draw_qty) AS build_draw_qty, SUM([OPS_BUILD_DRAW].open_qty) AS open_qty, (SUM([OPS_BUILD_DRAW].build_draw_qty) - SUM([OPS_BUILD_DRAW].open_qty)) AS used_qty")
      .where("[OPS_BUILD_DRAW].build_draw_ind = ?", 0)
      .where("[OPS_BUILD_DRAW].delivery_active_status_ind = ?", 1)
      .where("[OPS_BUILD_DRAW].open_qty > ?", 0)
      .where("[OPS_BUILD_DRAW].equipment_num = ?", params[:equipment_num])
      .group("[OPS_BUILD_DRAW].cmdty_cd")
      .order("[OPS_BUILD_DRAW].cmdty_cd")

    respond_to do |format|
      format.json { render :json => @inventory }
    end
  end

  def adjustment
    @build = OpsBuildDraw.find(params[:id])

    if @build != nil
      @builds = OpsBuildDraw
        .includes(:tags)
        .where("cargo_num = ?", @build.cargo_num)
        .where("build_draw_ind = ?", 0)
        .where("delivery_active_status_ind = ?", 1)
        .where("open_qty > ?", 0)
        .order("build_draw_num ASC")
    end

    respond_to do |format|
      format.html
    end
  end

  def get_level_by_equipment
    r = OpsCargo
      .where("equipment_num = ?", params[:equipment_num])
      .order("cargo_name ASC")

    @levels = r.map { |l| [ l.cargo_name, l.cargo_num ] }
  end

  def get_empty_cargo_adjustment
    # Let's authenticate on CXL before sending any XML
    auth_response = ApplicationHelper.authenticate

    if auth_response['success'] == true
      klazz = XmlMapper.new
      klazz.file_name = 'get_empty_cargo_adjustment'
      klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
      klazz.val2 = params[:cargo_num]

      xml_parse = klazz.do_parse

      # Build SOAP helper with proper service, method and XML
      ss = SoapSender.new
      ss.service = APP_SERVICE['inventory']['service_name']
      ss.method = APP_SERVICE['inventory']['get_empty_cargo_adjustment_method']
      ss.session = auth_response['session']
      ss.xml_resource = xml_parse
      ss.sender = session[:username][0].to_s

      # Send SOAP request to server
      xml_from_response = ss.do_request

      if xml_from_response[:success]
        # Build XML decode helper
        decode = XmlDecode.new
        decode.method = APP_SERVICE['inventory']['r_get_empty_cargo_adjustment_method']

        # Decode authentication response
        xml_decode = decode.do_decode(xml_from_response[:soap_response])

        # Find before quantity
        before_qty = decode.get_tag_content(xml_decode, 'before_qty')
        # Find effective date
        effective_dt = decode.get_tag_content(xml_decode, 'effective_dt')

        render :json => { :success => true, :before_qty => before_qty, :effective_dt => effective_dt }
      else
        # Find faultstring
        faultstring = decode.get_tag_content(Nokogiri.XML(xml_from_response[:soap_response]), 'faultstring')

        render :json => { :success => false, :message => faultstring }
      end
    else
      render :json => { :success => false, :message => 'Unable to authenticate to CXL.' }
    end
  end

  def put_cargo_adjustment
    # Let's authenticate on CXL before sending any XML
    auth_response = ApplicationHelper.authenticate

    if auth_response['success'] == true
      klazz = XmlMapper.new
      klazz.file_name = 'put_cargo_adjustment'
      klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
      klazz.val2 = params[:cargo_num]
      klazz.val3 = params[:effective_dt]
      klazz.val4 = params[:actual_qty]

      xml_parse = klazz.do_parse

      # Build SOAP helper with proper service, method and XML
      ss = SoapSender.new
      ss.service = APP_SERVICE['inventory']['service_name']
      ss.method = APP_SERVICE['inventory']['put_cargo_adjustment_method']
      ss.session = auth_response['session']
      ss.xml_resource = xml_parse
      ss.sender = session[:username][0].to_s

      # Send SOAP request to server
      xml_from_response = ss.do_request

      if xml_from_response[:success]
        # Build XML decode helper
        decode = XmlDecode.new
        decode.method = APP_SERVICE['inventory']['r_put_cargo_adjustment_method']

        # Decode authentication response
        xml_decode = decode.do_decode(xml_from_response[:soap_response])

        # Find id created
        id = decode.get_tag_content(xml_decode, 'build_draw_num')

        # Insert new transaction log
        transaction_log = TransactionLog.new do |t|
          t.user_name = session[:username][0].to_s
          t.cxl_user_name = Rails.application.secrets[:cxl_user_name]
          t.description = APP_SERVICE['inventory']['service_name'] + "::" + APP_SERVICE['inventory']['put_cargo_adjustment_method']
          t.xml_request = (Nokogiri.XML(xml_parse)).to_s
          t.xml_response = xml_decode.to_s
          t.execution_date = DateTime.now
          t.level_response = (id != nil ? "SUCCESS - 200" : "ERROR - 400")
        end

        transaction_log.save

        if id != nil
          build_draw = OpsBuildDraw.find(id)

          v_build_draw = {
            :build_draw_num => build_draw.build_draw_num,
            :build_draw_ind => build_draw.build_draw_ind,
            :location_num => build_draw.location_num,
            :trade_num => build_draw.trade_num,
            :obligation_num => build_draw.obligation_num,
            :transfer_start_dt => build_draw.transfer_start_dt.strftime("%Y%m%d%H%M%S"),
            :transfer_end_dt => build_draw.transfer_end_dt.strftime("%Y%m%d%H%M%S"),
            :build_draw_qty => build_draw.build_draw_qty,
            :open_qty => build_draw.open_qty,
            :transfer_price => build_draw.transfer_price,
            :per_unit_cost => build_draw.per_unit_cost,
            :build_draw_type_ind => build_draw.build_draw_type_ind,
            :strategy_num => build_draw.strategy_num,
            :obligation_detail_num => build_draw.obligation_detail_num,
            :transfer_num => build_draw.transfer_num,
            :transfer_at_ind => build_draw.transfer_at_ind,
            :transfer_price_status_ind => build_draw.transfer_price_status_ind,
            :net_qty => build_draw.net_qty,
            :cargo_qty => build_draw.cargo_qty,
            :packaging_qty => build_draw.packaging_qty,
            :base_vol => build_draw.base_vol,
            :base_mass => build_draw.base_mass,
            :filled_ind => build_draw.filled_ind,
            :weighted_avg => build_draw.weighted_avg,
            :import_ind => build_draw.import_ind,
            :import_type_ind => build_draw.import_type_ind,
            :mtm_price => build_draw.mtm_price,
            :p_l_value => build_draw.p_l_value,
            :price_locked_ind => build_draw.price_locked_ind,
            :last_modify_dt => build_draw.last_modify_dt.strftime("%Y%m%d%H%M%S"),
            :modify_person_num => build_draw.modify_person_num,
            # is_tag_qty_non_zero_ind
            :gain_loss_factor => build_draw.gain_loss_factor,
            :transfer_cost => build_draw.transfer_cost,
            :delivery_active_status_ind => build_draw.delivery_active_status_ind,
            :delivery_dt_mtm_ind => build_draw.delivery_dt_mtm_ind,
            # conf_warning_ind
            :transfer_split_ind => build_draw.transfer_split_ind,
            :commodity_cost => build_draw.commodity_cost,
            :sap_cur_bal_ind => build_draw.sap_cur_bal_ind,
            :effective_dt => build_draw.effective_dt.strftime("%Y%m%d%H%M%S"),
            :cmdty_cd => build_draw.cmdty_cd
          }

          render :json => { :success => true, :id => id, :build_draw => v_build_draw }
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

  def cancel_cargo_adjustment
    # Let's authenticate on CXL before sending any XML
    auth_response = ApplicationHelper.authenticate

    if auth_response['success'] == true
      klazz = XmlMapper.new
      klazz.file_name = 'cancel_cargo_adjustment'
      klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
      klazz.val2 = params[:id]

      xml_parse = klazz.do_parse

      # Build SOAP helper with proper service, method and XML
      ss = SoapSender.new
      ss.service = APP_SERVICE['inventory']['service_name']
      ss.method = APP_SERVICE['inventory']['cancel_cargo_adjustment']
      ss.session = auth_response['session']
      ss.xml_resource = xml_parse
      ss.sender = session[:username][0].to_s

      # Send SOAP request to server
      xml_from_response = ss.do_request

      if xml_from_response[:success]
        # Build XML decode helper
        decode = XmlDecode.new
        decode.method = APP_SERVICE['inventory']['r_cancel_cargo_adjustment']

        # Decode authentication response
        xml_decode = decode.do_decode(xml_from_response[:soap_response])

        # Find id
        id = decode.get_tag_content(xml_decode, 'build_draw_num')

        # Insert new transaction log
        transaction_log = TransactionLog.new do |t|
          t.user_name = session[:username][0].to_s
          t.cxl_user_name = Rails.application.secrets[:cxl_user_name]
          t.description = APP_SERVICE['inventory']['service_name'] + "::" + APP_SERVICE['inventory']['cancel_cargo_adjustment']
          t.xml_request = (Nokogiri.XML(xml_parse)).to_s
          t.xml_response = xml_decode.to_s
          t.execution_date = DateTime.now
          t.level_response = (id != nil ? "SUCCESS - 200" : "ERROR - 400")
        end

        transaction_log.save

        if id != nil
          render :json => { :success => true, :id => id }
        else
          render :json => { :success => false, :message => 'Unable to void build/draw. Please contact your system administrator.'  }
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

  def put_gain_loss_bd_tags_for_adj
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
        klazz.file_name = 'put_gain_loss_bd_tags_for_adj'
        klazz.val1 = DateTime.now.strftime('%Y%m%d%H%M%S')
        klazz.val2 = params[:equipment_num]
        klazz.val3 = params[:cargo_num]
        klazz.val5 = params[:gl_build_draw_num]

        build = []

        params[:build].map do |t|
          tag = []

          if t[1]['tag'] != nil
            t[1]['tag'].map do |tt|
              v_tag = {
                :val1 => tt[1]['build_draw_num'],
                :val2 => tt[1]['tag_type_cd'],
                :val3 => tt[1]['tag_type_ind'],
                :val4 => tt[1]['bd_tag_num'],
                :val5 => tt[1]['tag_gain_loss_qty_to_alloc'],
                :val6 => tt[1]['tag_qty'],
                :val7 => tt[1]['tag_qty_uom_cd'],
                :val8 => tt[1]['modify_person_num'],
                :val9 => tt[1]['tag_value1'],
                :val10 => tt[1]['tag_value2'],
                :val11 => tt[1]['tag_value3'],
                :val12 => tt[1]['tag_value4'],
                :val13 => tt[1]['tag_value7'],
                :val14 => tt[1]['tag_value8'],
                :val15 => tt[1]['chop_id'],
                :val16 => tt[1]['tag_source_ind'],
                :val17 => tt[1]['build_draw_type_ind'],
                :val18 => tt[1]['build_draw_ind'],
                :val19 => tt[1]['ref_bd_tag_num'],
                :val20 => tt[1]['tag_alloc_qty'],
                :val21 => tt[1]['gl_ref_bd_tag_num'],
                :val22 => tt[1]['split_src_tag_num'],
                :val23 => tt[1]['adj_ref_build_draw_num'],
                :val24 => tt[1]['tag_adj_qty']
              }

              tag.push(v_tag)
            end
          end

          v_build = {
            :val1 => t[1]['build_draw_num'],
            :val2 => t[1]['build_draw_ind'],
            :val3 => t[1]['location_num'],
            :val4 => t[1]['trade_num'],
            :val5 => t[1]['obligation_num'],
            :val6 => t[1]['transfer_start_dt'],
            :val7 => t[1]['transfer_end_dt'],
            :val8 => t[1]['build_draw_qty'],
            :val9 => t[1]['open_qty'],
            :val10 => t[1]['transfer_price'],
            :val11 => t[1]['per_unit_cost'],
            :val12 => t[1]['build_draw_type_ind'],
            :val13 => t[1]['strategy_num'],
            :val14 => t[1]['obligation_detail_num'],
            :val15 => t[1]['transfer_num'],
            :val16 => t[1]['transfer_at_ind'],
            :val17 => t[1]['transfer_price_status_ind'],
            :val18 => t[1]['net_qty'],
            :val19 => t[1]['cargo_qty'],
            :val20 => t[1]['packaging_qty'],
            :val21 => t[1]['base_vol'],
            :val22 => t[1]['base_mass'],
            :val23 => t[1]['filled_ind'],
            :val24 => t[1]['weighted_avg'],
            :val25 => t[1]['import_ind'],
            :val26 => t[1]['import_type_ind'],
            :val27 => t[1]['mtm_price'],
            :val28 => t[1]['p_l_value'],
            :val29 => t[1]['price_locked_ind'],
            :val30 => t[1]['last_modify_dt'],
            :val31 => t[1]['modify_person_num'],
            :val32 => t[1]['gain_loss_factor'],
            :val33 => t[1]['transfer_cost'],
            :val34 => t[1]['delivery_active_status_ind'],
            :val35 => t[1]['delivery_dt_mtm_ind'],
            :val36 => t[1]['transfer_split_ind'],
            :val37 => t[1]['commodity_cost'],
            :val38 => t[1]['sap_cur_bal_ind'],
            :val39 => t[1]['effective_dt'],
            :val40 => t[1]['cmdty_cd'],
            :val41 => tag
          }

          build.push(v_build)
        end

        klazz.val6 = build
        klazz.val7 = lockinfo

        xml_parse = klazz.do_parse

        # Send SOAP request to server
        ss.service = APP_SERVICE['inventory']['service_name']
        ss.method = APP_SERVICE['inventory']['put_gain_loss_bd_tags_for_adj']
        ss.xml_resource = xml_parse

        # Send SOAP request to server
        xml_from_response = ss.do_request

        if xml_from_response[:success]
          # Build XML decode helper
          decode.method = APP_SERVICE['inventory']['r_put_gain_loss_bd_tags_for_adj']

          # Decode authentication response
          xml_decode = decode.do_decode(xml_from_response[:soap_response])

          # Find id
          id = decode.get_tag_content(xml_decode, 'cargo_num')

          # Insert new transaction log
          transaction_log = TransactionLog.new do |t|
            t.user_name = session[:username][0].to_s
            t.cxl_user_name = Rails.application.secrets[:cxl_user_name]
            t.description = APP_SERVICE['inventory']['service_name'] + "::" + APP_SERVICE['inventory']['put_gain_loss_bd_tags_for_adj']
            t.xml_request = (Nokogiri.XML(xml_parse)).to_s
            t.xml_response = xml_decode.to_s
            t.execution_date = DateTime.now
            t.level_response = (id != nil ? "SUCCESS - 200" : "ERROR - 400")
          end

          transaction_log.save

          if id != nil
            # Insert new adjustment reason
            adjustments = Adjustments.new do |t|
              t.build_draw_num = params[:gl_build_draw_num]
              t.build_draw_qty = params[:gl_build_draw_qty]
              t.adjustment_reason_num = params[:gl_adjustment_reason]
              t.created_on = DateTime.now
              t.last_modify_dt = DateTime.now
            end

            adjustments.save

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

end
