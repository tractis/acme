class CertAuthController < ApplicationController
  # Present screen for redirecting to Nexeden
  def index
  end
  
  # Receive login redirection
  def login
    if NexedenConnector.valid_params?(NEXEDEN_KEY, params)
      session[:name] = params[:'tractis:attribute:name']
      session[:dni]  = params[:'tractis:attribute:dni']
      notify :notice, "Welcome #{session[:name]}"
      redirect_to cert_auth_private_path
    else
      session[:name] = nil
      session[:dni]  = nil
      notify :error, "Login failed"
      redirect_to cert_auth_login_path
    end
  end
  
  # Private page only accesible if logged in
  def private
    if session[:name].blank?
      redirect_to cert_auth_login_path
      return
    end
  end
end
