class YieldLineGroupDatatable
  delegate :params, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: YlLineClassYields.count,
      iTotalDisplayRecords: linegroups.total_entries,
      aaData: data,
      processing: '/assets/loader.gif'
    }
  end

private
  def data
    
    linegroups.map do |t|
      [
        t.LC_id,
        t.LC_PhysicalState,
        t.physicalState != nil ? t.physicalState.profit_unit_name : '',
        t.LC_GroupNum,
        t.group.commodity_group_name,
        t.LC_YE_id,
        t.element.YE_Element,
        t.LC_UseForPay
      ]
    end
  end

  def linegroups
    @linegroups ||= fetch_linegroups
  end

  def fetch_linegroups
    linegroups = YlLineClassYields
      .includes(:physicalState)
      .includes(:group)
      .includes(:element)
      .where("lc_status = ?", 1)
    linegroups = linegroups.paginate(page: page, per_page: per_page)

    # .includes({ movements: [ :mot, :mot_type, :depart_location, :arrive_location, :movement_status ] })

    if params[:sSearch].present?
      if params[:sSearch].length >= 4
      #   linegroups = linegroups
      #     .where("YG_Description LIKE :search", search: "%#{params[:sSearch]}%")
      end
    end

    linegroups
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 15
  end

end
