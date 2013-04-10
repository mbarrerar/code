class SpaceAdministration < ActiveRecord::Base
  belongs_to :space
  belongs_to :user
  belongs_to :created_by, :class_name => "User"

  validates_presence_of :space_id, :user_id
  validates_uniqueness_of :user_id, :scope => :space_id
  
  before_destroy :ensure_owner_is_administrator
  before_validation :ensure_active_user

  def ensure_owner_is_administrator
    if space.owner == user
      errors.add(:base, "Space Owner can't be removed from administrators.")
      false
    end
  end

  def ensure_active_user
    unless user.try(:active?)
      errors.add(:user_id, 'Invalid Collaborator: user is not active')
    end
  end

  ##
  # Space administrators should have commit access to every repo in the
  # space.  Update the authz file for every repo in the space.
  #
  def write_repositories_authz_files
    space.repositories.each { |r| r.write_authz_file }
  end
  
  def owner?
    space.owner == user
  end


  def self.msg_created(admin)
    "#{admin.user.full_name} has been granted admin access to this space."
  end

  def self.msg_destroyed(admin)
    "#{admin.user.full_name}'s admin access has been removed for this space."
  end
end
