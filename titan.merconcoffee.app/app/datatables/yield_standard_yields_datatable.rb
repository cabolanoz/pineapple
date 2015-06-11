class YieldStandardYieldsDatatable
  delegate :params, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: YlStandardYields.count,
      iTotalDisplayRecords: standards.total_entries,
      aaData: data,
      processing: '/assets/loader.gif'
    }
  end

private
  def data
    
    standards.map do |t|
      [
        t.SY_id,
        t.lineclass.LC_id,
        t.lineclass.LC_PhysicalState,
        t.lineclass.physicalState != nil ? t.lineclass.physicalState.profit_unit_name : '',
        t.lineclass.LC_GroupNum,
        t.lineclass.group.commodity_group_name,
        t.location.location_num,
        t.location.location_name,
        t.lineclass.LC_YE_id,
        t.lineclass.element.YE_Element,
        t.lineclass.LC_UseForPay,
        t.SY_Percent,
        t.SY_ValidDt
      ]
    end
  end

  def standards
    @standard ||= fetch_standard
  end

  def fetch_standard
    standard = YlStandardYields
      .includes(:lineclass)
      .includes(:location)
      .where("SY_status = ?", 1)
    standard = standard.paginate(page: page, per_page: per_page)

    # .includes({ movements: [ :mot, :mot_type, :depart_location, :arrive_location, :movement_status ] })

    if params[:sSearch].present?
      if params[:sSearch].length >= 4
      #   linegroups = linegroups
      #     .where("YG_Description LIKE :search", search: "%#{params[:sSearch]}%")
      end
    end

    standard
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 15
  end

end
