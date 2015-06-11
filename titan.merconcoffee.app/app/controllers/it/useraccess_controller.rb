class It::UseraccessController < ApplicationController
	def index
		connection = Net::LDAP.new(
			:host => APP_ACTIVE_DIRECTORY['server'],
			:port => APP_ACTIVE_DIRECTORY['port'],
   		:base => APP_ACTIVE_DIRECTORY['treebase'],
   		:auth => {
				:username => "cxluser@#{APP_ACTIVE_DIRECTORY['domain']}",
      	:password => APP_ACTIVE_DIRECTORY['password'],
        :method => :simple
			}
		)

		filter = Net::LDAP::Filter.eq('mail', '*.com') & Net::LDAP::Filter.eq('objectclass', 'person') & Net::LDAP::Filter.eq('objectclass', 'user')
		attributes = ['cn', 'mail', 'sAMAccountName']

		@users = connection.search(:attributes => attributes, :filter => filter)

		respond_to do |format|
			format.html
		end
	end

	def show
		username = params[:username]

		userexists = User.exists?(:user_name => username)

		if !userexists
			connection = Net::LDAP.new(
				:host => APP_ACTIVE_DIRECTORY['server'],
				:port => APP_ACTIVE_DIRECTORY['port'],
	   		:base => APP_ACTIVE_DIRECTORY['treebase'],
	   		:auth => {
					:username => "cxluser@#{APP_ACTIVE_DIRECTORY['domain']}",
	      	:password => APP_ACTIVE_DIRECTORY['password'],
	        :method => :simple
				}
			)

			filter = Net::LDAP::Filter.eq('sAMAccountName', username)
			attributes = ['sAMAccountName', 'givenName', 'initials', 'sn', 'mail']

			@userad = connection.search(:attributes => attributes, :filter => filter)
		else
			@userl = User.where("user_name = ?", username)
		end

		@departments = Department.where('status_ind = ?', 1).order('department_name ASC')

		@transactions = TransactionLog
			.where("user_name = ?", username)
			.order("execution_date DESC")

		respond_to do |format|
			format.html
		end
	end

	# def timeline
	# 	@username = params[:username]
	#
	# 	@transactions = TransactionLog
	# 		.where("user_name = ?", @username)
	# 		.order("execution_date DESC")
	#
	# 	respond_to do |format|
  #     format.html
  #   end
	# end
end
