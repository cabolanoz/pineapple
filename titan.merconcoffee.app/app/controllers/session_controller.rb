require 'socket'
class SessionController < ApplicationController
  def new
	render layout: false 
  end

  def create
  	#Authenticate with ldap
  	connection = Net::LDAP.new( :host => APP_ACTIVE_DIRECTORY['server'],
								:port => APP_ACTIVE_DIRECTORY['port'],
					   			:base => APP_ACTIVE_DIRECTORY['treebase'],
						   		:auth => { :username => params[:session][:username].downcase+"@#{APP_ACTIVE_DIRECTORY['domain']}",
								      	:password => params[:session][:password],
								        :method => :simple })
		

  	puts 'Trying to Authenticate User '+params[:session][:username].downcase
	if connection.bind and user = connection.search(:filter => "sAMAccountName="+params[:session][:username].downcase).first
		puts 'User Authenticated'
		log_in user,Socket.gethostname
		redirect_to  '/'
	else
		redirect_to  '/login'
  	end
  end

  def destroy
  	clearSession
  	puts 'Session Removed'
  	redirect_to  '/login'
  end

end
