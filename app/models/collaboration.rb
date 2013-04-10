class Collaboration < ActiveRecord::Base
  belongs_to :repository
  belongs_to :user
  belongs_to :created_by, :class_name => 'User'

  validates_uniqueness_of :user_id,
                          :scope => :repository_id,
                          :message => 'is already a collaborator of this repository'
  validates_presence_of :repository_id, :user_id, :permission, :created_by_id
  validates_inclusion_of :permission, :in => [Permission::COMMIT, Permission::READ]

  delegate :name, :to => :repository, :prefix => true
  delegate :username, :full_name, :admin, :active, :to => :user


  def validate
    if repository.space.administrations(true).map(&:user_id).include?(user_id)
      errors.add(:user_id, 'Administrators cannot be added as collaborators')
      false
    end

    unless user.try(:active?)
      errors.add(:user_id, 'Invalid Administrator: user is not active')
      false
    end
  end

  def repository_authz_entry
    Repository::Authz.entry(username, permission)
  end

  def write_repository_authz_file
    repository.write_authz_file
  end

  def commit?
    permission == Permission::COMMIT
  end

  def read?
    permission == Permission::READ
  end

  def self.permissions
    [Permission::COMMIT, Permission::READ]
  end

  def self.msg_created(collaboration)
    "Granted #{collaboration.user.full_name} #{collaboration.permission} permission"
  end

  def self.msg_destroyed(collaboration)
    "Removed #{collaboration.user.full_name}'s #{collaboration.permission} permission"
  end

end
