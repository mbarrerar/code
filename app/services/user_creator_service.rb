class UserCreatorService
  InvalidOption    = Class.new(ArgumentError)
  CreateFailed     = Class.new(StandardError)
  UnauthorizedUser = Class.new(CreateFailed)

  attr_accessor :ldap_person, :ldap_uid, :user

  ##
  # Valid options: :ldap_person, :ldap_uid
  #
  def initialize(options)
    options.symbolize_keys!

    if options.has_key?(:ldap_uid)
      @ldap_uid = options.fetch(:ldap_uid)
    elsif options.has_key?(:ldap_person)
      @ldap_person = options.fetch(:ldap_person)
    else
      raise InvalidOption, "Expects :ldap_uid or :ldap_person as options"
    end
  end

  def create!
    @user           = User.new
    @user.ldap_uid  = ldap_uid
    @user.full_name = full_name
    @user.save!
    @user
  rescue ActiveRecord::RecordInvalid => e
    raise(CreateFailed, e.message)
  end

  def find_or_create!
    unless (@user = User.find_by_ldap_uid(ldap_person.try(:ldap_uid)))
      create!
    end

    @user
  end

  def ldap_person
    @ldap_person ||= LdapPersonFinderService.find_by_uid(@ldap_uid)
  end

  private

  def full_name
    "#{ldap_attributes.fetch(:first_name)} #{ldap_attributes.fetch(:last_name)}"
  end

  def ldap_uid
    ldap_attributes.fetch(:ldap_uid)
  end

  def ldap_attributes
    if ldap_person
      { :ldap_uid   => ldap_person.ldap_uid,
        :first_name => ldap_person.first_name,
        :last_name  => ldap_person.last_name }
    else
      { }
    end
  end
end
