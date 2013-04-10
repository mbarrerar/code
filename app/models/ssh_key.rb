class SshKey < ActiveRecord::Base

  belongs_to :ssh_key_authenticatable, :polymorphic => true

  validates_presence_of :name, :key, :ssh_key_authenticatable_id
  validates_uniqueness_of :key
  validates_uniqueness_of :name, :scope => [:ssh_key_authenticatable_id, :ssh_key_authenticatable_type]
  validate :validate_no_ssh_directives

  before_validation { |r| r.clean_key }

  SSH_DIRECTIVES = %w{ command svnserve tunnel-user port-forwarding agent-forwarding X11-forwarding pty }

  ##
  # Mutates the original key, removing line any breaks.  Returns the
  # original (now cleansed) key.
  #
  # Note: it is common for line breaks to be unintentionally added to a
  # key when a user cuts and pastes their key into an html textarea.
  #
  # @return [String] contents of ssh public key
  #
  def clean_key
    k = key || ''
    logger.debug('RAW SSH KEY')
    logger.debug(k.inspect)

    write_attribute(:key, k.gsub(/\n|\r/, ''))
    logger.debug('CLEAN SSH KEY')
    logger.debug(key.inspect)
    key
  end

  ##
  # It may be possible to inject ssh directives into the authorized keys file
  # by adding them to your public key. Here we make sure non of the directives
  # are in a key.
  #
  def validate_no_ssh_directives
    return if key.blank?
    if SSH_DIRECTIVES.any? { |dir| key.include?(dir) }
      errors.add(:key, 'Key contains illegal tokens.')
    end
  end

  def user
    parent = ssh_key_authenticatable
    parent.is_a?(User) ? parent : raise(NotImplementedError)
  end

  def space
    parent = ssh_key_authenticatable
    parent.is_a?(Space) ? parent : raise(NotImplementedError)
  end

  def username
    parent = ssh_key_authenticatable
    if parent.is_a?(User)
      parent.username
    elsif ssh_key_authenticatable_type == "Space"
      "#{parent.deploy_user_name}"
    elsif ssh_key_authenticatable_type ==  "HudsonSshKey"
      HudsonSshKey.username
    end
  end
end
