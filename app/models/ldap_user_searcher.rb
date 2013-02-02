# class LdapUserSearcher
#   SEARCH_BY_OPTIONS = [:ldap_uid, :last_first_name, :last_name, :first_name, :email].freeze
# 
#   
#   class << self
#     def find(_params)
#       return [] unless valid_find_options?(_params)
#       return [] if _params[:search_value].blank?
#       
#       filter = create_filter(_params)
#       RAILS_DEFAULT_LOGGER.debug(filter.inspect)
#       
#       find_in_ldap(filter).map { |obj| User.new_from_ldap_person(obj) }.sort_by{|p| p.display_name.downcase}
#     end
# 
#     def select_options()
#       [
#         ['Last Name', 'last_name'],
#         ['First Name', 'first_name'],
#         ['Last Name, First Name', 'last_first_name'],
#         ['Email', 'email'],
#         ['Ldap Uid', 'ldap_uid'],
#       ]
#     end
#     
#     private
# 
#     def valid_find_options?(_params)
#       SEARCH_BY_OPTIONS.include?(_params[:search_by].try(:to_sym)) ? true : false
#     end
# 
#     def create_filter(_params = {})
#       filter = {}
#       case _params[:search_by]
#       when 'ldap_uid' : filter[:uid] = _params[:search_value]
#       when 'last_first_name' : filter[:sn], filter[:givenname] = _params[:search_value].split(/,\s*/, 2)
#       when 'last_name' : filter[:sn] = _params[:search_value]
#       when 'first_name' : filter[:givenname] = _params[:search_value]
#       when 'email' : filter[:mail] = _params[:search_value]
#       end
#       filter
#     end
# 
#     def find_in_ldap(_filter)
#       UCB::LDAP::Person.search(:filter => _filter)
#     end
#   end
# 
# end
