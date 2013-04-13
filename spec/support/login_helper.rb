module LoginHelper

  ##
  # Takes an object that responds to :ldap_uid
  # Or, takes the ldap_uid as a String or Integer.
  #
  def login_as(ldap_obj)
    ldap_uid = ldap_obj.respond_to?(:ldap_uid) ? ldap_obj.ldap_uid : ldap_obj
    visit(force_login_path(ldap_uid: ldap_uid))
  end

end
