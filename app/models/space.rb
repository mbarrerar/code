class Space < ActiveRecord::Base
  include SizeMethods
  include Comparable

  default_scope :order => 'name'

  has_many :deploy_keys, :as => :ssh_key_authenticatable, :class_name => "SshKey", :dependent => :delete_all
  has_many :repositories, :order => :name
  has_many :administrations, :dependent => :delete_all, :class_name => 'SpaceAdministration'
  has_many :administrators, :through => :administrations, :source => :user, :order => "full_name"
  belongs_to :owner, :class_name => "User", :foreign_key => :owner_id

  after_create :create_svn_space
  after_update :update_svn_space
  before_destroy :ensure_has_no_repositories
  after_destroy :delete_svn_space

  validates_presence_of :name, :owner_id
  validates_format_of :name, :with => App::ENTITY_NAME_REGEXP, :allow_blank => true,
                      :message => App::ENTITY_NAME_REGEXP_ERROR_MESSAGE
  validates_uniqueness_of :name, :allow_blank => true


  def <=>(other_space)
    self.name.downcase <=> other_space.name.downcase
  end

  def owner_name
    owner.full_name
  end

  def owner_email
    owner.email
  end

  def owned_by?(user)
    user == owner
  end

  def owner?(user)
    owned_by?(user)
  end

  def administrator?(user)
    administrators(true).include?(user)
  end

  def owner_or_admin?(user)
    owner?(user) || administrator?(user)
  end

  def actual_size
    repositories.inject(0) { |sum, r| sum += r.actual_size }
  end

  ##
  # All users that are not administrators of this space
  #
  # @return [Array<User>]
  #
  def non_admins
    User.all - administrators
  end

  def authorized_keys_file
    @authz_keys_file ||= AuthorizedKeysFile.new
  end

  ##
  # Each space has its owner deploy user which gets its own
  # key entries in authorized_keys, this is the name of the
  # space's deploy user.
  #
  # @return [String] name of space deploy user: "app_<space_name>"
  #
  def deploy_user_name
    "#{name}_deployment"
  end

  def delete_svn_space
    UcbSvn.delete_space(name)
    authorized_keys_file.write(SshKey.all)
  end

  def create_svn_space
    UcbSvn.create_space(name)
    # Space owner automatically gets added as an administrator
    administrations.create(:user => owner)
  end

  def update_svn_space
    return if !name_changed? && !owner_id_changed?

    if name_changed?
      UcbSvn.rename_space(name_was, name)
      update_post_commit_hook_files
      authorized_keys_file.write(SshKey.all)
    end

    if owner_id_changed?
      old_owner = User.find(owner_id_was)
      old_admin = administrations.find_by_user_id(old_owner)
      old_admin.destroy
      administrations(true).create(:user_id => owner.id)
    end

    write_repositories_authz_files
  end

  ##
  # Updates the authz file for all of its repositories
  #
  def write_repositories_authz_files
    repositories(true).each(&:write_authz_file)
  end

  ##
  # Updates the post_commit_hook file for all of its repositories.
  #
  def update_post_commit_hook_files
    repositories(true).each { |r| UcbSvn.initialize_post_commit_hook_file(name, r.name) }
  end

  ##
  # @return [True] if no repos for this space.
  #
  def ensure_has_no_repositories
    if !repositories(true).empty?
      errors.add(:base, 'Error: must delete all repositories before space can be deleted.')
      false
    end
  end

  ##
  # Expects a params hash where the String (integer) keys are the user_id
  # and the value of the key is the permission
  #
  # @param [User] creator that is updating the collaborators
  # @param [Hash]
  #
  def update_administrators_from_params(creator, params = {})
    raise(ArgumentError, 'creator cannot be nil') unless creator

    ids_to_delete = params.inject([]) do |ids, (id, admin)|
      if id.match(/^\d+$/) && admin.blank? && (id.to_i != owner.id)
        ids << id.to_i
      end
      ids
    end

    SpaceAdministration.destroy_all(:user_id => ids_to_delete, :space_id => id)

    params.each do |id, admin|
      if id.match(/^\d+$/) && !admin.blank?
        unless administrations(true).find_by_user_id(id)
          administrations.create(:user_id => id, :created_by => creator)
        end
      end
    end

    self.write_repositories_authz_files
  end

  ##
  # All users that are 'active', not the space owner and not in +excluded_users+
  #
  # @param [Array<User>] list of users that should be excluded.
  # @return [Array<User>]
  #
  def administrators_available(excluded_users = [])
    excluded_users << owner
    User.eligible_administrators - excluded_users
  end


  def self.select_options
    spaces = Space.all.sort.map { |space| [space.name, space.name] }
    spaces.unshift(["Any Space", ""])
  end

  ##
  # Predicate that determines if the user is an administrator of the space.
  #
  # @param [Space]
  # @param [User]
  # @return [Boolean]
  #
  def self.administrator?(space, user)
    space.administrators(true).include?(user)
  end

  ##
  # Determines if the space name has changed.
  #
  # @param [Space]
  # @return [true, false]
  #
  def self.confirmation_required?(space)
    (space.name_was != space.name) ? true : false
  end

end
