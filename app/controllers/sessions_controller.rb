require 'ostruct'

class SessionsController < ApplicationController
  skip_before_filter :ensure_authenticated_user
  skip_before_filter :ensure_authorized_user
  before_filter :ensure_omniauth_attributes, :only => :create
  # skip_before_filter :check_browser
  # skip_before_filter :record_last_access

  def new
    redirect_to('/auth/cas')
  end

  def create
    session[:ldap_uid] = omniauth_attributes.uid
    redirect_to(session[:original_url] || root_path)
  end

  def destroy
    reset_session
    # must be root_url for CAS re-login to work
    redirect_to('%s?url=%s' % [AppConfig.cas_logout, root_url])
  end

  def failure
    Rails.logger.debug("Authentication Failed for: #{omniauth_attributes}")
    render(:text => 'Not Authorized', :status => 401)
  end

  protected

  def ensure_omniauth_attributes
    redirect_to(root_path) if request.env['omniauth.auth'].nil?
  end

  def omniauth_attributes
    unless @omniauth_attributes
      @omniauth_attributes = if Rails.env.test?
                               OpenStruct.new(:uid => params[:ldap_uid])
                             else
                               request.env['omniauth.auth']
                             end
    end
    @omniauth_attributes
  end
end
