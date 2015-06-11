class Traffic::TrademanagerController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.datatable { render :json => TradesDatatable.new(view_context) }
    end
  end

  def show
    @trade = TrdHeader
      .includes(:trade_dtl)
      .includes(:trade_trm)
      .includes(:internal_company)
      .includes(:trader)
      .includes(:strategy)
      .includes(:counterpart)
      .includes(:obligation_hdr)
      .find(params[:id])
  end
end
