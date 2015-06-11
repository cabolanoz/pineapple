class YieldGroupsDatatable
  delegate :params, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: YlYieldGroups.count,
      iTotalDisplayRecords: groups.total_entries,
      aaData: data,
      processing: '/assets/loader.gif'
    }
  end

private
  def data
    groups.map do |t|
      [
        t.YG_Id,
        t.YG_Description,
        t.YG_Gold == true ? t.YG_Gold : '',
        t.YG_Sum == true ? t.YG_Sum : '',
        t.YG_ParentGroup,
        t.calcType != nil ? t.calcType.CT_Description : '' ,
        t.physicalState != nil ? t.physicalState.profit_unit_name : ''
      ]
    end
    # t.physicalState.profit_unit_code,
    # t.physicalState.profit_unit_name,
  end

  def groups
    @groups ||= fetch_groups
  end

  def fetch_groups
    groups = YlYieldGroups
      .includes(:physicalState)
      .where("yg_status = ?", 1)
    groups = groups.paginate(page: page, per_page: per_page)

    # .includes({ movements: [ :mot, :mot_type, :depart_location, :arrive_location, :movement_status ] })

    if params[:sSearch].present?
      if params[:sSearch].length >= 4
        groups = groups
          .where("YG_Description LIKE :search", search: "%#{params[:sSearch]}%")
      end
    end

    groups
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 15
  end

  # def serialize_m(v)
  #   v.map do |m|
  #     {
  #       :movement_num => m.movement_num,
  #       :equipment_num => m.equipment_num,
  #       :mot => m.mot,
  #       :mot_type => m.mot_type,
  #       :movement_status => m.movement_status,
  #       :depart_location => m.depart_location,
  #       :depart_dt => m.depart_dt.strftime("%m/%d/%Y"),
  #       :arrive_location => m.arrive_location,
  #       :arrive_dt => m.arrive_dt.strftime("%m/%d/%Y"),
  #       :cargo => OpsCargo.where("equipment_num = ?", m.equipment_num)
  #     }
  #   end
  # end
end
