class UserAuthenticatorService

  def initialize(session_params)
    @ldap_uid = session_params[:ldap_uid]
  end

  def authenticated?
    @ldap_uid.present?
  end

end
