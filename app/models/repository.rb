class Repository < ActiveRecord::Base
  include SizeMethods

  default_scope includes(:space).order('name')

  belongs_to :space
  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id'
  has_many :collaborations, :dependent => :delete_all
  has_many :collaborators, :through => :collaborations, :source => :user, :order => 'name'

  delegate :name, :to => :space, :prefix => true
  delegate :name, :email, :to => :owner, :prefix => true

  validates_presence_of :name, :space_id, :user_id
  validates_uniqueness_of :name, :scope => :space_id
  validates :name, :entity_name => { allow_blank: true }

  def disk_usage
    size_display
  end

  def committers
    collaborators.keep_if { |collaborator| collaborator.permission == Permission::COMMIT }
  end

  def readers
    collaborators.keep_if { |collaborator| collaborator.permission == Permission::READ }
  end

  def canonical_name
    [space.name, name].join(' / ')
  end

  def url
    "svn+ssh://#{App.svn_username}@#{App.svn_connection_url}/#{space.name}/#{name}"
  end
end
