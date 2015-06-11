require 'net-ldap' # gem install ruby-net-ldap
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  include SessionHelper

  before_filter :verifySession, :set_locale

  def verifySession
    if session[:username] == nil and request.path != '/login'
      redirect_to  '/login'
    end
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

end
