class YieldElementsDatatable
  delegate :params, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: YlYieldElements.count,
      iTotalDisplayRecords: elements.total_entries,
      aaData: data,
      processing: '/assets/loader.gif'
    }
  end

private
  def data
    elements.map do |t|
      [
        t.YE_Id,
        t.elementType.ET_Element,
        t.YE_Element,
        t.yieldGroup.YG_Description
      ]
    end
    # t.physicalState.profit_unit_code,
    # t.physicalState.profit_unit_name,
  end

  def elements
    @elements ||= fetch_elements
  end

  def fetch_elements
    elements = YlYieldElements
      .includes(:elementType)
      .includes(:yieldGroup)
      .where("ye_status = ?", 1)

    elements = elements.paginate(page: page, per_page: per_page)

    # .includes({ movements: [ :mot, :mot_type, :depart_location, :arrive_location, :movement_status ] })

    if params[:sSearch].present?
      if params[:sSearch].length >= 4
        elements = elements
          .where("YE_Element LIKE :search", search: "%#{params[:sSearch]}%")
      end
    end

    elements
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
