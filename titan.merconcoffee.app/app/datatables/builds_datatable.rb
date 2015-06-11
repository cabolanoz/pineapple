class BuildsDatatable
  delegate :params, :link_to, :number_with_precision, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: OpsBuildDraw.where("build_draw_ind = ?", 0).where("delivery_active_status_ind = ?", 1).count,
      iTotalDisplayRecords: builds.total_entries,
      aaData: data,
      processing: '/assets/loader.gif'
    }
  end

private
  def data
    builds.map do |t|
      [
        link_to(t.build_draw_num, "javascript:;", :id => "lnk_build_#{t.build_draw_num}"),
        t.storage != nil ? t.storage.storage_cd : '',
        t.cargo != nil ? t.cargo.cargo_name : '',
        t.cargo != nil ? t.cargo.cmdty_cd : '',
        t.location != nil ? t.location.location_cd : '',
        t.transfer_num != nil ? link_to(t.transfer_num, { :controller => 'transfermanager', :action => 'show', :id => t.transfer_num }) : '',
        number_with_precision(t.build_draw_qty, :precision => 2, :delimiter => ','),
        number_with_precision(t.open_qty, :precision => 2, :delimiter => ','),
        number_with_precision((t.build_draw_qty - t.open_qty), :precision => 2, :delimiter => ','),
        t.equipment_num,
        t.cargo_num,
        t.tags
      ]
    end
  end

  def builds
    @builds ||= fetch_builds
  end

  def fetch_builds
    builds = OpsBuildDraw
      .includes(:tags)
      .joins("LEFT JOIN [REF_STORAGE] ON [OPS_BUILD_DRAW].equipment_num = [REF_STORAGE].equipment_num")
      .joins([ :cargo, :location ])
      .where("build_draw_ind = ?", 0)
      .where("delivery_active_status_ind = ?", 1)
      .order("[OPS_BUILD_DRAW].build_draw_num DESC")
    builds = builds.paginate(
      :page => page,
      :per_page => per_page
    )

    # if params[:sSearch].present?
    #   transfers = transfers.where("transfer_num LIKE :search", search: "#{params[:sSearch]}%")
    # end

    builds
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end
end
