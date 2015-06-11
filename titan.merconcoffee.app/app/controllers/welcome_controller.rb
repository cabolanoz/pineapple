class WelcomeController < ApplicationController

  # If you’re reading this, that means you have been put in charge of my previous project. I am so, so sorry for you. God speed. :)
  # Ironic because I don't believe in God... :D

  def index
    render layout: true
  	#@url = "http://localhost:8080/CXLRWS/Itinerary/getAll?filter="

  	#begin
  	#	@itineraries = HTTParty.get(@url)
  	#rescue StandardError
  	#	@itineraries = OpenStruct.new(:code => nil, :message => "Service not found")
  	#end

  	#respond_to do |format|
  	#	format.html
  	#	format.json { render :json => @itineraries }
  	#end
  end
end
