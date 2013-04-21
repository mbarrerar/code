class Space < ActiveRecord::Base
  include SizeMethods
  include Comparable

  default_scope order('name')

  has_many :deploy_keys, :as => :ssh_key_authenticatable, :class_name => "SshKey", :dependent => :delete_all
  has_many :repositories, :order => :name
  has_many :ownerships, :dependent => :delete_all, :class_name => 'SpaceOwnership'
  has_many :owners, :through => :ownerships, :source => :owner, :order => "name"

  validates_presence_of :name
  validates_uniqueness_of :name, :allow_blank => true
  validates :name, :entity_name => { allow_blank: true }


  def <=>(other_space)
    self.name.downcase <=> other_space.name.downcase
  end

  def owners_available
    User.all
  end

  def owner?(user)
    owners.include?(user)
  end

  def actual_size
    repositories.inject(0) { |sum, r| sum + r.actual_size }
  end

  def deploy_user_name
    "#{name}_deployment"
  end
end
