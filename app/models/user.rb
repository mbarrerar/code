class User < ActiveRecord::Base

  default_scope order('full_name')

  scope(:active, :conditions => {:active => true})
  scope(:eligible_collaborators, :conditions => {:active => true, :terms_and_conditions => true})
  scope(:eligible_administrators, :conditions => {:active => true, :terms_and_conditions => true})
  scope(:admin, :conditions => {:admin => true})
  scope(:administrators, :conditions => {:admin => true})

  has_many :ssh_keys, :as => :ssh_key_authenticatable, :dependent => :delete_all
  has_many :collaborations
  has_many :repositories, :through => :collaborations
  has_many :space_administrations
  has_many :spaces_owned, :class_name => 'Space', :foreign_key => :owner_id

  # The owner of a space, is by default always an administrator as well,
  # so this gives us all spaces owned & administered by a given user.
  has_many :spaces_administered, :through => :space_administrations, :source => :space

  validates_presence_of :ldap_uid, :full_name, :email, :username
  validates_format_of :username, :with => /\A(\S)+\Z/i, :allow_blank => true
  validates_acceptance_of :terms_and_conditions, :accept => true
  validates_uniqueness_of :ldap_uid, :email, :allow_blank => true
  validates_format_of :email,
    :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
    :allow_blank => true


  before_destroy :ensure_not_space_owner
  before_destroy :ensure_not_space_administrator
  before_destroy :ensure_not_collaborator


  def has_no_ssh_keys?
    ssh_keys.empty?
  end

  def ensure_not_space_owner
    unless spaces_owned(true).empty?
      errors.add(:base, "Can't delete; user owns spaces: [#{spaces_owned.map(&:name)}]")
      false
    end
  end

  def ensure_not_space_administrator
    unless spaces_administered(true).empty?
      errors.add(:base, "Can't delete; user administers spaces: [#{spaces_administered.map(&:name)}]")
      false
    end
  end

  def ensure_not_collaborator
    unless collaborations(true).empty?
      errors.add(:base, "Can't delete; user collaborates on: #{repositories(true).map(&:name)}")
      false
    end
  end

  def app_admin?
    active? && admin?
  end

  def repositories_administered
    spaces_administered.map(&:repositories).flatten
  end

  ##
  # @param [Integer, Repository] Repository id or repository
  #
  def find_repository_administered(repo_id)
    repo_id = repo_id.id if repo_id.is_a?(Repository)
    repo_id = repo_id.to_i
    spaces_administered.map(&:repositories).
      flatten.detect { |r| r.id == repo_id }
  end

  def normalize(repo_name)
    repo_name.gsub(/[^\w\-]/, '_')
  end

  def accepted_terms?
    terms_and_conditions?
  end


  def self.find_from_search(term)
    return [] if term.blank?
    User.where(['lower(full_name) LIKE ?', "%#{term}%"]).all
  end

  def self.find_or_create_by_ldap_uid(ldap_uid)
    user = User.find_by_ldap_uid(ldap_uid)
    unless user
      user = new_from_ldap_uid(ldap_uid)
      user.save(false)
    end
    user
  end

  def self.ldap_uids
    connection.select_values('select ldap_uid from users')
  end

  def self.new_from_ldap_uid(ldap_uid)
    ldap_person = ldap_uid.nil? ? nil : UCB::LDAP::Person.find_by_uid(ldap_uid)
    ldap_person.nil? ? User.new : new_from_ldap_person(ldap_person)
  end

  def self.new_from_ldap_person(ldap_person)
    User.new.tap do |user|
      user.sudo_attributes = attr_hash_from_ldap_person(ldap_person)
      user.active = true
    end
  end

  def self.attr_hash_from_ldap_person(ldap_person)
    {
      :username => ldap_person.calnetid,
      :ldap_uid => ldap_person.uid.to_i,
      :full_name => ldap_person.full_name,
      :email => ldap_person.email,
    }
  end

  ##
  # @param [User]
  # @return [User]
  #
  def self.deactivate(user)
    user.update_attribute(:active, false)
  end
end
