class Api::BaseController < ActionController::Base
  before_filter :verify_auth_user

  ##
  # Used only for testing
  #
  def test_auth
    render :text => "OK"
  end


  protected

  def local_request?
    false
  end

  def verify_auth_user
    return true if ["development"].include?(Rails.env.to_s)
    Rails.logger.info("API Authentication attempt for: #{request.remote_ip}")
    if request.remote_ip == "127.0.0.1"
      Rails.logger.info("Authentication successful")
      true
    else
      Rails.logger.info("Authentication failed")
      render(:text => App.msg_not_authorized, :status => :forbidden)
    end
  end
end
