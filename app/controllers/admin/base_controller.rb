class Admin::BaseController < ApplicationController
  before_filter(:ensure_authorized_admin)

  layout('admin')

  
  protected
  
  def ensure_authorized_admin
    unless authorizer.admin?
      render(:text => "Forbidden", :status => 403)
    end
  end

  def authorizer
    @authorizer ||= UserAuthorizerService.new(:ldap_person => ldap_person)
  end
end
