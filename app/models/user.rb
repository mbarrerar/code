class User < ActiveRecord::Base

  default_scope order('name')

  scope :active, :conditions => { active: true }
  scope :admin, :conditions => { admin: true }
  scope :administrators, :conditions => { admin: true }
  scope :eligible_collaborators, :conditions => { active: true, agreed_to_terms: true }

  has_many :ssh_keys, :as => :ssh_key_authenticatable, :dependent => :delete_all
  has_many :collaborations
  has_many :repositories, :through => :collaborations, :source => :repository
  has_many :repositories_owned, :through => :collaborations

  has_many :space_ownerships, :dependent => :delete_all
  has_many :spaces_owned, :through => :space_ownerships, :source => :space
  has_many :spaces, :through => :space_ownerships, :source => :space

  validates_presence_of :ldap_uid, :name, :email, :username
  validates :username, :username => { allow_blank: true }
  validates_acceptance_of :agreed_to_terms, :accept => true
  validates_uniqueness_of :ldap_uid, :email, :allow_blank => true
  validates :email, :email => { allow_blank: true }


  def default_space
    (spaces_owned.size == 1) ? spaces_owned.first : nil
  end

end
