class InventoriesDatatableDtl
  delegate :params, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: OpsBuildDraw.where("build_draw_ind = ?", 0).where("delivery_active_status_ind = ?", 1).count,
      iTotalDisplayRecords: inventories.total_entries,
      aaData: data,
      processing: '/assets/loader.gif'
    }
  end

private
  def data
    inventories.map do |t|
      [
        link_to(t.build_draw_num, { :controller => 'traffic/transfermanager', :action => :builddraw, :id => t.build_draw_num }, 'data-no-turbolink' => true),
        t.transfer_num != nil ? link_to(t.transfer_num, { :controller => 'traffic/transfermanager', :action => :show, :id => t.transfer_num }, 'data-no-turbolink' => true) : '',
        t.storage_type_cd,
        t.equipment_num,
        t.storage_cd,
        t.cmdty_cd,
        t.location_cd,
        t.owner_cd,
        t.owner_nam,
        t.tag_qty != nil ? t.tag_qty.round(2) : 0.00,
        t.tag_qty_uom_cd,
        t.bag_qty.to_i,
        t.crop_cd,
        t.lot_num
      ]
    end
  end

  def inventories
    @inventories ||= fetch_inventories
  end

  def fetch_inventories
    inventories = OpsBuildDraw
      .select("[OPS_BUILD_DRAW].transfer_num, [REF_STORAGE].storage_type_cd, [REF_STORAGE].equipment_num, [REF_STORAGE].storage_cd, [OPS_BUILD_DRAW].cmdty_cd, [OPS_BUILD_DRAW_TAG].tag_value7 AS location_cd, [OPS_BUILD_DRAW_TAG].tag_value1 AS owner_cd, [REF_COMPANY].company_legal_long AS owner_nam, [OPS_BUILD_DRAW_TAG].tag_qty, [OPS_BUILD_DRAW_TAG].tag_qty_uom_cd, ISNULL((CASE WHEN PATINDEX('%[a-zA-Z]%', [OPS_BUILD_DRAW_TAG].tag_value4) > 0 THEN 0 ELSE CAST([OPS_BUILD_DRAW_TAG].tag_value4 AS INTEGER) END), 0) AS bag_qty, [OPS_BUILD_DRAW_TAG].tag_value2 AS crop_cd, [OPS_BUILD_DRAW_TAG].tag_value3 AS lot_num, [OPS_BUILD_DRAW].build_draw_num")
      .joins("INNER JOIN [OPS_CARGO] ON [OPS_BUILD_DRAW].cargo_num = [OPS_CARGO].cargo_num AND [OPS_CARGO].status_ind = 1")
      .joins("INNER JOIN [REF_STORAGE] ON [OPS_BUILD_DRAW].equipment_num = [REF_STORAGE].equipment_num AND [REF_STORAGE].status_ind = 1")
      .joins("INNER JOIN [OPS_BUILD_DRAW_TAG] ON [OPS_BUILD_DRAW].build_draw_num = [OPS_BUILD_DRAW_TAG].build_draw_num AND [OPS_BUILD_DRAW_TAG].alloc_status_ind <> 2")
      .joins("LEFT JOIN [REF_COMPANY] ON [OPS_BUILD_DRAW_TAG].tag_value1 = [REF_COMPANY].company_cd AND [REF_COMPANY].status_ind = 1")
      .where("[OPS_BUILD_DRAW].build_draw_ind = ?", 0)
      .where("[OPS_BUILD_DRAW].delivery_active_status_ind = ?", 1)
      .group("[OPS_BUILD_DRAW].transfer_num, [REF_STORAGE].storage_type_cd, [REF_STORAGE].equipment_num, [REF_STORAGE].storage_cd, [OPS_BUILD_DRAW].cmdty_cd, [OPS_BUILD_DRAW_TAG].tag_value7, [OPS_BUILD_DRAW_TAG].tag_value1, [REF_COMPANY].company_legal_long, [OPS_BUILD_DRAW_TAG].tag_qty, [OPS_BUILD_DRAW_TAG].tag_qty_uom_cd, [OPS_BUILD_DRAW_TAG].tag_value4, [OPS_BUILD_DRAW_TAG].tag_value2, [OPS_BUILD_DRAW_TAG].tag_value3, [OPS_BUILD_DRAW].build_draw_num")
      .having(params[:sSearch_C7])
      .order("[REF_STORAGE].storage_type_cd")

    inventories = inventories.paginate(page: page, per_page: per_page)

    if params[:sSearch_C1].present?
      inventories = inventories.where("[REF_STORAGE].storage_type_cd = ?", params[:sSearch_C1])
    end

    if params[:sSearch_C2].present?
      inventories = inventories.where("[REF_STORAGE].equipment_num = ?", params[:sSearch_C2])
    end

    # I still don't know what to match the level with
    if params[:sSearch_C3].present?
      inventories = inventories.where("[OPS_BUILD_DRAW].cmdty_cd = ?", params[:sSearch_C3])
    end

    if params[:sSearch_C4].present?
      inventories = inventories.where("[OPS_BUILD_DRAW_TAG].tag_value7 LIKE ?", "%#{params[:sSearch_C4]}%")
    end

    if params[:sSearch_C5].present?
      if params[:sSearch_C5].include?('=!')
        inventories = inventories.where("[OPS_BUILD_DRAW_TAG].tag_value1 NOT LIKE ? OR [REF_COMPANY].company_legal_long NOT LIKE ?", "%#{params[:sSearch_C5][2]}%", "%#{params[:sSearch_C5][2]}%")
      else
        inventories = inventories.where("[OPS_BUILD_DRAW_TAG].tag_value1 LIKE ? OR [REF_COMPANY].company_legal_long LIKE ?", "%#{params[:sSearch_C5]}%", "%#{params[:sSearch_C5]}%")
      end
    end

    if params[:sSearch_C6].present?
      inventories = inventories.where("[OPS_CARGO].internal_company_num = ?", params[:sSearch_C6])
    end

    inventories
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 15
  end

end
