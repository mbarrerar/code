class SessionsController < ApplicationController
  skip_before_filter :ensure_authenticated
  skip_before_filter :ensure_authorized
  # skip_before_filter :record_last_access

  def new
    redirect_to("/auth/cas")
  end

  def create
    session[:ldap_uid] = auth_attributes.uid
    redirect_to(session[:original_url] || root_path)
  end

  def force_create
    session[:ldap_uid] = params[:ldap_uid] if Rails.env.test?
    redirect_to(session[:original_url] || root_path)
  end

  def destroy
    reset_session
    redirect_to("%s?url=%s" % [AppConfig.cas_logout, root_path])
  end

  def failure
    Rails.logger.debug("Authentication Failed for: #{auth_attributes}")
    render(:text => "Not Authorized", :status => 401)
  end

  protected

  def auth_attributes
    request.env['omniauth.auth']
  end
end
