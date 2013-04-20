class Repository < ActiveRecord::Base
  include SizeMethods

  default_scope includes(:space).order('name')

  belongs_to :space
  has_many :collaborations, :dependent => :delete_all
  has_many :collaborators, :through => :collaborations, :source => :user, :order => 'full_name'

  delegate :name, :to => :space, :prefix => true
  delegate :owner, :to => :space
  delegate :owner_name, :to => :space
  delegate :owner_email, :to => :space
  delegate :administrators, :to => :space

  validates_presence_of :name, :space_id
  validates_uniqueness_of :name, :scope => :space_id
  validates_format_of :name, :with => App::ENTITY_NAME_REGEXP,
                      :message => App::ENTITY_NAME_REGEXP_ERROR_MESSAGE,
                      :unless => 'name.blank?'

  after_create :create_svn_repository
  after_destroy :archive_svn_repository
  after_update :update_svn_repository


  def disk_usage
    size_display
  end

  def committers
    collaborators.keep_if { |collaborator| collaborator.permission == Permission::COMMIT }
  end

  def readers
    collaborators.keep_if { |collaborator| collaborator.permission == Permission::READ }
  end

  ##
  # If _user_ only has one space, set it as the default.
  #
  def set_default_space(user)
    if user.spaces_administered.size == 1
      self.space_id = user.spaces_administered.first.id()
    end
  end

  def canonical_name
    [space.name, name].join(' / ')
  end

  def svn_service
    UcbSvn
  end

  ##
  # All 'active' users that are not administrators of this repository
  #
  # @return [Array<User>]
  #
  def collaborators_available
    User.eligible_collaborators - administrators(true)
  end

  ##
  # URL used by svn clients to connect to the repository.  Is of the format:
  #
  # svn+ssh://svn@code.berkeley.edu
  #
  def url
    "svn+ssh://#{App.svn_username}@#{App.svn_connection_url}/#{space.name}/#{name}"
  end

  def svn_dir
    svn_service.repository_dir(space.name, name)
  end

  def create_svn_repository
    svn_service.create_repository(space.name, name)
    write_authz_file
  end

  def svn_dir_exists?
    File.exists?(svn_dir)
  end

  def update_svn_repository
    rename_svn_repository if name_changed?
    move_svn_repository_to_new_space if space_id_changed?
    update_post_commit_hook_file
    write_authz_file
  end

  def archive_svn_repository
    svn_service.archive_repository(space.name, name, AppConfig.archive_dir)
  end

  def rename_svn_repository
    old_space_name = Space.find(space_id_was).name
    svn_service.rename_repository(old_space_name, name_was, name)
  end

  def move_svn_repository_to_new_space
    old_space_name = Space.find(space_id_was).name
    new_space_name = Space.find(space_id).name
    svn_service.move_repository(name, old_space_name, new_space_name)

    if self.collaborators.include?(self.space.owner)
      collab = self.collaborations.find_by_user_id(self.space.owner)
      collab.destroy
    end
  end

  ##
  # Write out the repository's permissions to its ROOT/conf/authz file
  #
  def write_authz_file
    svn_service.write_repository_authz_file(space.name, name, authz_content)
  end

  def authz_content
    [Repository.authz_preamble, authz_entries].flatten.join("\n")
  end

  ##
  # Collection of entries representing this repositoriy's space administrators.
  # These entries are formatted to be written to the repositoriy's authz file.
  #
  # @example
  #   ["username1 = rw", "username2 = r"]
  #
  # @return[<String>]
  #
  def authz_entries_for_admins
    space.administrators(true).map { |admin| Authz.entry(admin.username, :commit) }
  end

  ##
  # Collection of entries representing this repository's collaborators.  These
  # entries are formatted to be written to the repository's authz file.
  #
  # @example
  #   ["username1 = rw", "username2 = r"]
  #
  # @return[Array<String>]
  #
  def authz_entries_for_collaborators
    collaborations(true).map { |collab| collab.repository_authz_entry }
  end

  def authz_entry_for_hudson_ci
    if uses_hudson_ci?
      ['app_hudson = r']
    else
      []
    end
  end

  ##
  # Entry representing this repository's space deploy user.  This
  # entry is formatted to be written to the repository's authz file.
  #
  # Note: Space deploy users only get read access to a repository.
  #
  # @example
  #   "app_space_name = r"
  #
  # @return[Array<String>]
  #
  def authz_entry_for_space_deploy_user
    ["#{space.deploy_user_name} = r"]
  end

  ##
  # Collection of entries representing this repositoriy's space administrators
  # and its collaborators.  These entries are formatted to be written to the
  # repositoriy's authz file.
  #
  # @example
  #   ["username1 = rw", "username2 = r"]
  #
  # @return[<String>]
  #
  def authz_entries
    authz_entries_for_admins +
        authz_entries_for_collaborators +
        authz_entry_for_space_deploy_user +
        authz_entry_for_hudson_ci
  end

  ##
  # Update the contents of the post_commit_hook file.
  #
  def update_post_commit_hook_file
    svn_service.initialize_post_commit_hook_file(self.space_name, self.name)
  end

  ##
  # Expects a params hash where the String (integer) keys are the user_id
  # and the value of the key is the permission
  #
  # @param [User] the user that is updating the collaborators
  # @param [Hash]
  # @return [nil]
  #
  def update_collaborators_from_params(creator, params = {})
    raise(ArgumentError, 'creator cannot be nil') unless creator

    ids_to_delete = params.inject([]) do |ids, (id, perm)|
      ids << id.to_i if id.match(/^\d+$/) && perm.blank?
      ids
    end

    Collaboration.destroy_all(:repository_id => id, :user_id => ids_to_delete)

    params.each do |id, permission|
      if id.match(/^\d+$/) && !permission.blank?
        collab = collaborations(true).find_by_user_id(id)
        if collab && collab.permission == permission
          next
        elsif collab && (collab.permission != permission)
          collab.destroy
          collaborations.create(:user_id => id,
                                :permission => permission,
                                :created_by_id => creator.id)
        else
          collaborations.create(:user_id => id,
                                :permission => permission,
                                :created_by_id => creator.id)
        end
      end
    end

    self.write_authz_file
  end


  ##
  # Initial state to be used for each svn authz file.
  #
  # @return [String] contents for our authz file.
  #
  def self.authz_preamble
    ['# This file is generated by the code@berkeley application', '[/]'].join('\n')
  end

  ##
  # Determines if the repository space and or name has changed
  #
  # @param [Repository]
  # @return [true, false]
  #
  def self.confirmation_required?(repository)
    old_repo_name = repository.name_was
    old_space_name = Space.find(repository.space_id_was).name

    return true if old_repo_name != repository.name
    return true if old_space_name != repository.space.name
    false
  end

  def self.find_by_space_name(space_name)
    if space_name.blank?
      Repository.joins(:space).order('name, spaces.name').all
    else
      Repository.joins(:space).where(['spaces.name = ?', space_name]).all
    end
  end

  module Authz
    PERMISSIONS = { :commit => 'rw', :read => 'r' }.freeze

    def self.[](key)
      self.permission(key)
    end

    def self.permission(perm)
      unless PERMISSIONS.keys.include?(perm.to_sym)
        raise("unknown permission: #{perm.inspect}")
      end
      PERMISSIONS[perm.to_sym]
    end

    def self.entry(username, perm)
      "#{username} = #{permission(perm)}"
    end
  end

end
