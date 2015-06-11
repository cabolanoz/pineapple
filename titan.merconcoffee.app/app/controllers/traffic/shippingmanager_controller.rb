class Traffic::ShippingmanagerController < ApplicationController
	def index
		respond_to do |format|
			format.html
			format.datatable { render :json => ItinerariesDatatable.new(view_context) }
		end
	end

	def show
		@itinerary = OpsItinerary
			.find(params[:id])

		respond_to do |format|
			format.html
			format.json do
				render :json => @itinerary.to_json(:include => [ :operator, :internal_company, :movements =>  { :include => [ :mot, :mot_type, :depart_location, :arrive_location, :movement_status, :cargos ] } ])
			end
		end
	end

	def get_itinerary_by_id
		@itinerary = OpsItinerary
			.find(params[:id])

		respond_to do |format|
			format.json do
				render :json => @itinerary.to_json(:include => [ :operator, :internal_company, :movements =>  { :include => [ :mot, :mot_type, :depart_location, :arrive_location, :movement_status, :cargos ] } ])
			end
		end
	end
end
