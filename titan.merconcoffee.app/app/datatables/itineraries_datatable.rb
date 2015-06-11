class ItinerariesDatatable
  delegate :params, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: OpsItinerary.where('status_ind = ?', 1).count,
      iTotalDisplayRecords: itineraries.total_entries,
      aaData: data,
      processing: '/assets/loader.gif'
    }
  end

private
  def data
    itineraries.map do |t|
      [
        # '',
        link_to(t.itinerary_num, :controller => 'shippingmanager', :action => 'show', :id => t),
        t.itinerary_name.strip,
        t.operator.first_name.strip + ' ' + t.operator.last_name.strip,
        t.start_dt.strftime("%m/%d/%Y"),
        t.end_dt.strftime("%m/%d/%Y"),
        t.create_dt.strftime("%m/%d/%Y"),
        '<i class="glyphicon glyphicon-chevron-right" style="cursor: pointer;"></i>'
        # serialize_m(t.movements)
      ]
    end
  end

  def itineraries
    @itineraries ||= fetch_itineraries
  end

  def fetch_itineraries
    itineraries = OpsItinerary
      .includes(:operator)
      .where('status_ind = ?', 1)
      .order("itinerary_num DESC")
    itineraries = itineraries.paginate(page: page, per_page: per_page)

    # .includes({ movements: [ :mot, :mot_type, :depart_location, :arrive_location, :movement_status ] })

    if params[:sSearch].present?
      if params[:sSearch].length >= 4
        itineraries = itineraries
          .where("itinerary_name LIKE :search", search: "%#{params[:sSearch]}%")
      end
    end

    itineraries
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
