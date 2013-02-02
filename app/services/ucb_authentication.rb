module UcbAuthentication
  extend ActiveSupport::Concern

  def ensure_authenticated
    unless authenticator.authenticated?
      session[:original_url] = request.env['REQUEST_URI']
      redirect_to(login_url)
    end
  end

  def ensure_authorized
    if authorizer.authorized?
      @current_user = authorizer.user
    else
      # render("/application/not_authorized", :status => 403)
      render(:text => "Not Authorized", :status => 403)
    end
  end

  def current_user
    @current_user
  end

  def ldap_person
    @ldap_person ||= LdapPersonFinderService.find_by_uid(ldap_uid)
  end

  def ldap_uid
    session[:ldap_uid]
  end
  alias :logged_in? :current_user

  def authenticator
    @authenticator ||= UserAuthenticatorService.new(session)
  end

  def authorizer
    @authorizer ||= UserAuthorizerService.new(:ldap_person => ldap_person, :affiliations => eligible_affiliations)
  end

  def eligible_affiliations
    @eligible_affiliations ||= UcbAffiliation.all
  end

  def user_is_admin?
    authorizer.admin?
  end


  included do
    helper_method :ldap_person
    helper_method :current_user
    helper_method :eligible_affiliations
    helper_method :user_is_admin?
    helper_method :logged_in?
  end
end