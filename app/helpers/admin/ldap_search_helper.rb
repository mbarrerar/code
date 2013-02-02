module Admin::LdapSearchHelper

  def app_user?(ldap_user)
    @existing_users_ldap_uids.include?(ldap_user.ldap_uid.to_s)
  end
  
  def tr_class(ldap_user)
    app_user?(ldap_user) ? "app_user" : ""
  end

  ##
  # If the user is already in the system, displays and 'edit' link
  # If the user is not in the system, displays a 'edit' link
  #
  # @param [UCB::LDAP::User]
  # @return [String] Link to 'edit' or 'edit' user
  #
  def add_link(ldap_user)
    if app_user?(ldap_user)
      app_user = User.find_by_ldap_uid(ldap_user.ldap_uid)
      link_to('Edit', edit_admin_user_path(app_user), :title => "Click to edit this existing user.")
    else
      link_to(ldap_user.ldap_uid, new_admin_user_path(:ldap_uid => ldap_user.ldap_uid), :title => "Click to add this user")
    end
  end

end
