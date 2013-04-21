class Collaboration < ActiveRecord::Base
  belongs_to :repository
  belongs_to :user

  # TODO: Remove this association, this should be part of an activity log
  belongs_to :created_by, :class_name => 'User'

  validates_uniqueness_of :user_id,
                          :scope => :repository_id,
                          :message => 'is already a collaborator of this repository'
  validates_presence_of :repository_id, :user_id, :permission, :created_by_id
  validates_inclusion_of :permission, :in => [Permission::COMMIT, Permission::READ]

  delegate :name, :to => :repository, :prefix => true
  delegate :username, :name, :admin, :active, :to => :user

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
    "Granted #{collaboration.user.name} #{collaboration.permission} permission"
  end

  def self.msg_destroyed(collaboration)
    "Removed #{collaboration.user.name}'s #{collaboration.permission} permission"
  end

end
