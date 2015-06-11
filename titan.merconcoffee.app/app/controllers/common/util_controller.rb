class Common::UtilController < ApplicationController
  def get_trade_buy_like_trade
    query = params[:query]

    @trades = TrdHeader
      .includes(:trade_dtl)
      .includes(:strategy)
      .includes(:counterpart)
      .joins(:obligation_hdr)
      .where("[TRD_HEADER].trade_num LIKE ? AND [TRD_HEADER].trade_type_cd = ? AND [TRD_HEADER].trade_status_ind <> ? AND [OPS_OBLIGATION_HDR].buy_sell_ind = ?", "#{query}%", 'Coffee Contract', 5, 1)
      .limit(5)
  end

  def get_trade_sell_like_trade
    query = params[:query]

    @trades = TrdHeader
      .includes(:trade_dtl)
      .includes(:strategy)
      .includes(:counterpart)
      .joins(:obligation_hdr)
      .where("[TRD_HEADER].trade_num LIKE ? AND [TRD_HEADER].trade_type_cd = ? AND [TRD_HEADER].trade_status_ind <> ? AND [OPS_OBLIGATION_HDR].buy_sell_ind = ?", "#{query}%", 'Coffee Contract', 5, -1)
      .limit(5)
  end

  def get_movement_by_itinerary
    query = params[:query]

    @movements = OpsMovement
      .includes(:mot)
      .includes(:mot_type)
      .includes(:depart_location)
      .where("itinerary_num = :query", query: "#{query}")
      .where("status_ind = ?", 1)
  end

  def get_storage_by_id
    @storage = RefStorage
      .find(params[:id])

    respond_to do |format|
      format.json { render :json => @storage }
    end
  end

  def get_level_by_cargo
    @level = OpsCargo
      .find(params[:id])

    respond_to do |format|
      format.json { render :json => @level }
    end
  end

  def get_obligation_detail_by_obligation_and_transfer
    obligation_dtl = OpsObligationDetail.where("obligation_num = ?", params[:obligation_num]).where("transfer_num = ?", params[:transfer_num]).limit(1)
    stl_item_hdr = StlItemHdr.where('delivery_num = ?', params[:transfer_num]).limit(1)

    respond_to do |format|
      format.json { render :json => { :obligation_dtl => obligation_dtl, :stl_item_hdr => stl_item_hdr } }
    end
  end

  def get_transaction_log_by_id
    @transaction = TransactionLog
      .find(params[:id])

    respond_to do |format|
      format.json { render :json => @transaction }
    end
  end

  def get_udf_for_transfer
    udf = RefUdf.where('status_ind = ?', 1).where('udf_entity_type_ind = ?', 2).where('mot_type_ind = ?', 5)

    respond_to do |format|
      format.json { render :json => udf }
    end
  end

  def get_convertion_factor_by_uom
    factor = RefUom.where(["uom_cd = ?", params[:uom_cd]]).select("uom_factor").limit(1)

    render :json => { :success => true, :factor => factor }
  end

  def get_transfer_by_id
    transfer = OpsTransfer
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
      .find(params[:transfer_num])

    render :json => { :success => true, :transfer => transfer }
  end

  def get_udf_values_by_code
    udf_values = RefUdfValues.where('udf_cd = ?', params[:udf_cd]).where('status_ind = ?', 1).order(udf_reference_value: :asc)

    respond_to do |format|
      format.json { render :json => udf_values }
    end
  end

  def get_tag_by_id
    tag = OpsBuildDrawTag.where(bd_tag_num: params[:bd_tag_num]).first
    render :json => { :success => true, :tag => tag }
  end

  def get_transfer_ud
    udf = OpsTransferUdf.where(transfer_num: params[:transfer_num])
    render :json => { :success => true, :udf => udf}
  end

  def get_obligation_dtl_by_num
    dtl = OpsObligationDetail.where(obligation_num: params[:obligation_num]).first
    render :json => { :success => true, :dtl => dtl}
  end

  def get_obligation_hdr_by_num
    hdr = OpsObligationHdr.where(obligation_num: params[:obligation_num]).first
    render :json => { :success => true, :hdr => hdr}
  end

  def get_obligation_daily_by_num
    daily = OpsTransferDailyDetail.where(transfer_num: params[:transfer_num])
    render :json => { :success => true, :daily => daily}
  end

  def get_tags_from_build_draw
    tags = OpsBuildDrawTag.where(build_draw_num: params[:build_draw_num])
    render :json => { :success => true, :tags => tags }
  end


end
