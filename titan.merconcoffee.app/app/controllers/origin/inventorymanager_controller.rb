class Origin::InventorymanagerController < ApplicationController

  # ============================================================================
  # index
  # params:
  # return: HTML
  # ============================================================================
  def index
    respond_to do |format|
      format.html
      format.datatable1 { render :json => InventoriesDatatableDtl.new(view_context) }
      format.datatable2 { render :json => InventoriesDatatableHdr.new(view_context) }
    end
  end

  def get_storage_by_type
    r = RefStorage
      .where("storage_type_cd = ?", params[:storage_type_cd])
      .where("status_ind = ?", 1)
      .order("storage_cd ASC")

    @storages = r.map { |l| [ l.storage_cd, l.equipment_num ] }
  end

  def get_level_by_equipment
    r = OpsCargo
      .where("equipment_num = ?", params[:equipment_num])
      .order("cargo_name ASC")

    @levels = r.map { |l| [ l.cargo_name, l.cmdty_cd, { 'data-cargo' => l.cargo_num } ] }
  end

  def inventory_dtl
    @inventories = OpsBuildDraw
      .select("[OPS_BUILD_DRAW].build_draw_num, [OPS_BUILD_DRAW].transfer_num, [REF_STORAGE].storage_type_cd, [REF_STORAGE].equipment_num, [REF_STORAGE].storage_cd, [OPS_BUILD_DRAW].cmdty_cd, [OPS_BUILD_DRAW_TAG].tag_value7 AS location_cd, [OPS_BUILD_DRAW_TAG].tag_value1 AS owner_cd, [REF_COMPANY].company_legal_long AS owner_nam, [OPS_BUILD_DRAW_TAG].tag_qty, [OPS_BUILD_DRAW_TAG].tag_qty_uom_cd, CAST(ISNULL([OPS_BUILD_DRAW_TAG].tag_value4, 0) AS DECIMAL(18, 6)) AS bag_qty, [OPS_BUILD_DRAW_TAG].tag_value2 AS crop_cd, [OPS_BUILD_DRAW_TAG].tag_value3 AS lot_num")
      .joins("INNER JOIN [OPS_CARGO] ON [OPS_BUILD_DRAW].cargo_num = [OPS_CARGO].cargo_num AND [OPS_CARGO].status_ind = 1")
      .joins("INNER JOIN [REF_STORAGE] ON [OPS_BUILD_DRAW].equipment_num = [REF_STORAGE].equipment_num AND [REF_STORAGE].status_ind = 1")
      .joins("INNER JOIN [OPS_BUILD_DRAW_TAG] ON [OPS_BUILD_DRAW].build_draw_num = [OPS_BUILD_DRAW_TAG].build_draw_num AND [OPS_BUILD_DRAW_TAG].alloc_status_ind <> 2")
      .joins("LEFT JOIN [REF_COMPANY] ON [OPS_BUILD_DRAW_TAG].tag_value1 = [REF_COMPANY].company_cd AND [REF_COMPANY].status_ind = 1")
      .where("[OPS_BUILD_DRAW].build_draw_ind = ?", 0)
      .where("[OPS_BUILD_DRAW].delivery_active_status_ind = ?", 1)
      .group("[OPS_BUILD_DRAW].build_draw_num, [OPS_BUILD_DRAW].transfer_num, [REF_STORAGE].storage_type_cd, [REF_STORAGE].equipment_num, [REF_STORAGE].storage_cd, [OPS_BUILD_DRAW].cmdty_cd, [OPS_BUILD_DRAW_TAG].tag_value7, [OPS_BUILD_DRAW_TAG].tag_value1, [REF_COMPANY].company_legal_long, [OPS_BUILD_DRAW_TAG].tag_qty, [OPS_BUILD_DRAW_TAG].tag_qty_uom_cd, [OPS_BUILD_DRAW_TAG].tag_value4, [OPS_BUILD_DRAW_TAG].tag_value2, [OPS_BUILD_DRAW_TAG].tag_value3")
      .having(params[:sSearch_C7])
      .order("[REF_STORAGE].storage_type_cd")

    if params[:sSearch_C1].present?
      @inventories = @inventories.where("[REF_STORAGE].storage_type_cd = ?", params[:sSearch_C1])
    end

    if params[:sSearch_C2].present?
      @inventories = @inventories.where("[REF_STORAGE].equipment_num = ?", params[:sSearch_C2])
    end

    # I still don't know what to match the level with
    if params[:sSearch_C3].present?
      @inventories = @inventories.where("[OPS_BUILD_DRAW].cmdty_cd = ?", params[:sSearch_C3])
    end

    if params[:sSearch_C4].present?
      @inventories = @inventories.where("[OPS_BUILD_DRAW_TAG].tag_value7 LIKE ?", "%#{params[:sSearch_C4]}%")
    end

    if params[:sSearch_C5].present?
      if params[:sSearch_C5].include?('=!')
        @inventories = @inventories.where("[OPS_BUILD_DRAW_TAG].tag_value1 NOT LIKE ? OR [REF_COMPANY].company_legal_long NOT LIKE ?", "%#{params[:sSearch_C5][2]}%", "%#{params[:sSearch_C5][2]}%")
      else
        @inventories = @inventories.where("[OPS_BUILD_DRAW_TAG].tag_value1 LIKE ? OR [REF_COMPANY].company_legal_long LIKE ?", "%#{params[:sSearch_C5]}%", "%#{params[:sSearch_C5]}%")
      end
    end

    if params[:sSearch_C6].present?
      @inventories = @inventories.where("[OPS_CARGO].internal_company_num = ?", params[:sSearch_C6])
    end

    respond_to do |format|
      format.xls
    end
  end

end
