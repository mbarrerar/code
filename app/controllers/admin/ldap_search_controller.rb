class Admin::LdapSearchController < Admin::BaseController
  current_tab :major, :users
  
  def index
    @select_options = LdapSearch.search_by_options()
    @ldap_search = LdapSearch.new(params[:ldap_search])
    respond_to do |format|
      format.html { render("index") }
    end
  end
  
  def do_search
    # require 'ruby-debug'
    # debugger
    
    @select_options = LdapSearch.search_by_options()
    @ldap_search = LdapSearch.new(params[:ldap_search])
    @users = @ldap_search.find()
    @existing_users_ldap_uids = User.ldap_uids()
    respond_to do |format|
      format.html { render("index") }
    end
  end
end
