class UserLoginService
  def initialize(user)
    @user = user
  end

  def record
    record_login if @user
    sync_with_ldap if @user.ldap_entry
  end

  def record_login
    @user.update_attribute(:last_login, Time.now)
  end

  def sync_with_ldap
    @user.update_from_ldap_entry unless RailsEnv.test?
  end
end