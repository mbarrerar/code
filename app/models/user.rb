class User < ActiveRecord::Base

  default_scope :order => 'full_name'

  scope(:active, :conditions => {:active => true})
  scope(:eligible_collaborators, :conditions => {:active => true, :terms_and_conditions => true})
  scope(:eligible_administrators, :conditions => {:active => true, :terms_and_conditions => true})
  scope(:admin, :conditions => {:admin => true})
  scope(:administrators, :conditions => {:admin => true})

  attr_accessible :email
  
  has_many :ssh_keys, :as => :ssh_key_authenticatable, :dependent => :delete_all
  has_many :collaborations
  has_many :repositories, :through => :collaborations
  has_many :space_administrations
  has_many :spaces_owned, :class_name => "Space", :foreign_key => :owner_id

  # The owner of a space, is by default always an administrator as well,
  # so this gives us all spaces owned & administered by a given user.
  has_many :spaces_administered, :through => :space_administrations, :source => :space

  validates_presence_of :ldap_uid, :username, :full_name
  validates_acceptance_of :terms_and_conditions, :accept => true
  validates_uniqueness_of :ldap_uid, :username, :allow_blank => true
  validates :email, :email => { allow_blank: true, unique: true, present: true }
  validates_format_of :username, :with => /\A(\S)+\Z/i, :allow_blank => true

  after_update :deprovision_if_no_longer_active
  before_destroy :ensure_not_space_owner
  before_destroy :ensure_not_space_administrator
  before_destroy :ensure_not_collaborator
  after_destroy { SshKey.write_authorized_keys_file }
  

  def deprovision_if_no_longer_active
    if active_changed? && !active?
      admin = User.admin.first
      self.class.deprovision(self, admin)
    end
  end
  
  def ensure_not_space_owner
    if !spaces_owned(true).empty?
      errors.add_to_base("Can't delete; user owns spaces: [#{spaces_owned.map(&:name)}]")
      false
    end
  end

  def ensure_not_space_administrator
    if !self.spaces_administered(true).empty?
      errors.add_to_base("Can't delete; user administers spaces: [#{spaces_administered.map(&:name)}]")
      false
    end
  end

  def ensure_not_collaborator
    if !collaborations(true).empty?
      errors.add_to_base("Can't delete; user collaborates on: #{repositories(true).map(&:name)}")
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

  def has_no_ssh_keys?
    ssh_keys.empty?
  end

  
  def self.find_from_search(term)
    return [] if term.blank?
    User.where("lower(full_name) LIKE ?", "%#{term}%")
  end
  
  def self.find_or_create_by_ldap_uid(ldap_uid)
    user = User.find_by_ldap_uid(ldap_uid)
    unless user
      user = new_from_ldap_uid(ldap_uid)
      user.save(false)
    end
    user
  end
  
  def self.ldap_uids()
    connection.select_values("select ldap_uid from users")
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

  ##
  # * Delete all of their ssh keys
  # * For any spaces that they own, transfer ownership to the application administrator
  # * Delete all of their collaborations.
  # * Delete all of their administrations.
  #
  # @param [User] user to deprovision
  # @param [User] admin user to transfer ownership of spaces to.
  # @return [User]
  #
  def self.deprovision(user, admin)
    user.ssh_keys(true).each(&:destroy)

    spaces_owned = user.spaces_owned(true)
    spaces_owned.each do |s|
      s.update_attribute(:owner_id, admin.id)
    end

    unless spaces_owned.empty?
      AppAdminMailer.deliver_space_transfer_notification(admin, user, spaces_owned)
    end

    user.collaborations(true).each do |c|
      c.destroy
      c.write_repository_authz_file
    end

    user.space_administrations(true).each do |sa|
      sa.destroy
      sa.write_repositories_authz_files
    end

    user
  end
end
