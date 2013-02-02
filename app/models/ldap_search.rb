class LdapSearch

  SEARCH_BY_OPTIONS = [
    :ldap_uid, 
    :last_first_name, 
    :last_name, 
    :first_name, 
    :email, 
    :username 
  ].freeze  

  attr_accessor :search_by, :search_value

  
  ##
  # Set up an LDAP search for a person in LDAP.
  #
  # @param [Hash] opts are the search options.
  # @options opts [String] :search_by
  # ('ldap_uid', 'last_first_name', 'last_name',
  #  'first_name', 'email', 'username')
  # @options opts [String] :search_value value of the search
  #
  def initialize(params = {})
    return if params.nil?
    @search_by = params[:search_by] if params[:search_by]
    @search_value = params[:search_value] if params[:search_value]
  end

  ##
  # Fetch the results of the search.
  #
  # @return [Array<UCB::LDAP::Person>]
  #
  def find()
    return [] unless valid_find_options?

    params = { :search_by => search_by, :search_value => search_value() }
    filter = self.class.create_filter(params)
    Rails.logger.debug(filter.inspect)
    
    self.class.find_in_ldap(filter).map { |obj|
      User.new_from_ldap_person(obj)
    }.sort_by(&:full_name)
  end

  ##
  # Predicate that determines if the :search_by option is valid.
  #
  # @return [true, false]
  #
  def valid_find_options?
    return false if search_by.blank?
    return false if search_value.blank?
    SEARCH_BY_OPTIONS.include?(search_by.try(:to_sym)) ? true : false
  end
  
  ##
  # Hack to get formtastic to work
  #
  def new_record?
  end
  
  ##
  # Hack to get formtastic to work
  #
  def self.human_name()
  end
  
  ##
  # Hack to get formtastic to work
  #
  def id()
    nil
  end


  class << self    
    def search_by_options()
      [['Last Name', 'last_name'],
       ['Last Name, First Name', 'last_first_name'],
       ['First Name', 'first_name'],
       ['Ldap Uid', 'ldap_uid'],
       ['Email', 'email'],
       ['Username', 'username']]
    end
    
    def create_filter(params = {})
      filter = {}
      case params[:search_by]
      when 'ldap_uid' then filter[:uid] = params[:search_value]
      when 'last_first_name' then filter[:sn], filter[:givenname] = params[:search_value].split(/,\s*/, 2)
      when 'last_name' then filter[:sn] = params[:search_value]
      when 'first_name' then filter[:givenname] = params[:search_value]
      when 'email' then filter[:mail] = params[:search_value]
      when 'username' then filter[:berkeleyedukerberosprincipalstring] = params[:search_value]
      end
      filter
    end

    def find_in_ldap(filter)
      UCB::LDAP::Person.search(:filter => filter).select do |record|
        eligible_user?(record)
      end
    end

    def eligible_user?(ldap_person)
      Authz.authorized_user?(ldap_person)
    end
  end

end
