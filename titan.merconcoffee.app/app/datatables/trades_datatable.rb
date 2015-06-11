class TradesDatatable
  delegate :params, :link_to, :number_with_precision, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: TrdHeader.where("trade_type_cd = ?", 'Coffee Contract').where("trade_status_ind <> ?", 5).count,
      iTotalDisplayRecords: trades.total_entries,
      aaData: data
    }
  end

private
  def data
    trades.map do |t|
      [
        link_to(t.trade_num, :controller => 'trademanager', :action => 'show', :id => t),
        t.trade_trm.term_num,
        t.trade_dt.strftime("%m/%d/%Y"),
        t.deal_id != nil ? t.deal_id : '',
        t.trader.first_name.strip + ' ' + t.trader.last_name.strip,
        '',
        '',
        '',
        ''
      ]
    end
  end

  def trades
    @trades ||= fetch_trades
  end

  def fetch_trades
    trades = TrdHeader
      .includes(:trade_dtl)
      .includes(:trade_trm)
      .includes(:internal_company)
      .includes(:trader)
      .includes(:strategy)
      .includes(:counterpart)
      .where("trade_type_cd = ?", 'Coffee Contract')
      .where("trade_status_ind <> ?", 5)
      .order("trade_num DESC")
    trades = trades.paginate(page: page, per_page: per_page)

    # if params[:sSearch].present?
    #   transfers = transfers.where("transfer_num LIKE :search", search: "#{params[:sSearch]}%")
    # end

    trades
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end
end
