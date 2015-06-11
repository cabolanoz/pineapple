module SessionHelper

  def log_in(user, machine)
    session[:username] = user.samaccountname
    session[:firstName] = user.givenname
    session[:lastName] = user.sn
    session[:machine] = machine
  end

  def clearSession
  	session[:username] = nil
    session[:firstName] = nil
    session[:lastName] = nil
    session[:machine] = nil
  end

end
