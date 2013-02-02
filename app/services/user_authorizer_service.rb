class UserAuthorizerService
  attr_accessor :user, :ldap_person, :affiliations, :user_creator, :user_finder, :user_creator

  ##
  # required args:
  #   :ldap_person
  #
  # optional args:
  #   :affiliations
  #
  def initialize(args)
    args.symbolize_keys!
    @ldap_person = args.fetch(:ldap_person)
    @affiliations = args.fetch(:affiliations, default_affiliations)
    @user_creator = args.fetch(:user_creator, default_user_creator)
    @user_finder = args.fetch(:user_finder, default_user_finder)
  end

  def authorized?
    if has_eligible_affiliation?
      @user = user_creator.find_or_create!
      true
    else
      false
    end
  end

  def admin?
    user.try(:admin?)
  end

  def user
    user_finder.find_by_ldap_uid(ldap_person.ldap_uid)
  end

  private

  def default_user_creator
    UserCreatorService.new(:ldap_person => ldap_person)
  end

  def default_user_finder
    User
  end

  def default_affiliations
    UcbAffiliation.all
  end

  def has_eligible_affiliation?
    !(affiliations & ldap_person.affiliations).empty?
  end
end