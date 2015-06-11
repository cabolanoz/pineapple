class TransfersDatatable
  delegate :params, :link_to, :number_with_precision, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: OpsTransfer.count,
      iTotalDisplayRecords: transfers.total_entries,
      aaData: data
    }
  end

private
  def data
    transfers.map do |t|
      [
        link_to(t.transfer_num, { :controller => 'transfermanager', :action => 'show', :id => t }, 'data-no-turbolink' => true),
        t.delivery_active_status.ind_value_name == 'Void' ? '<span style="color: #a94442; font-weight: bold;">' + t.delivery_active_status.ind_value_name + '</span>' : t.delivery_active_status.ind_value_name,
        t.location.location_cd,
        t.effective_dt.strftime("%m/%d/%Y"),
        t.transfer_comm_dt.strftime("%m/%d/%Y"),
        t.transfer_comp_dt.strftime("%m/%d/%Y"),
        t.bl_num_cd,
        t.bl_dt.strftime("%m/%d/%Y"),
        t.obligation_num,
        t.build_num != nil ? link_to(t.build_num, { :controller => 'transfermanager', :action => 'builddraw', :id => t.build_num }, { 'data-no-turbolink' => true }) : '',
        t.draw_num,
        number_with_precision(t.gain_loss_qty, :precision => 2, :delimiter => ','),
        t.from_type.ind_value_name,
        t.from_storage != nil ? t.from_storage.storage_cd : '',
        t.from_itinerary != nil ? link_to(t.from_itinerary.itinerary_num, :controller => 'shippingmanager', :action => 'show', :id => t.from_itinerary.itinerary_num) : '',
        t.from_cargo != nil ? t.from_cargo.cargo_name : '',
        number_with_precision(t.from_qty, :precision => 2, :delimiter => ','),
        t.to_type.ind_value_name,
        t.to_storage != nil ? t.to_storage.storage_cd : '',
        t.to_itinerary != nil ? link_to(t.to_itinerary.itinerary_num, :controller => 'shippingmanager', :action => 'show', :id => t.to_itinerary.itinerary_num) : '',
        t.to_cargo != nil ? t.to_cargo.cargo_name : '',
        number_with_precision(t.to_qty, :precision => 2, :delimiter => ',')
      ]
    end
  end

  def transfers
    @transfers ||= fetch_transfers
  end

  def fetch_transfers
    transfers = OpsTransfer
      .includes(:from_type)
      .includes(:to_type)
      .includes(:location)
      .includes(:from_itinerary)
      .includes(:from_storage)
      .includes(:from_cargo)
      .includes(:to_itinerary)
      .includes(:to_storage)
      .includes(:to_cargo)
      .includes(:delivery_active_status)
      .order("transfer_num DESC")
    transfers = transfers.paginate(page: page, per_page: per_page)

    if params[:sSearch].present?
      transfers = transfers.where("transfer_num LIKE :search", search: "#{params[:sSearch]}%")
    end

    transfers
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end
end
