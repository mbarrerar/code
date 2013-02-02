class SshKey < ActiveRecord::Base

  belongs_to :ssh_key_authenticatable, :polymorphic => true

  cattr_accessor :always_update_key_file
  self.always_update_key_file = true

  validates_presence_of :name, :key, :ssh_key_authenticatable_id
  validates_uniqueness_of :key
  validates_uniqueness_of :name, :scope => [:ssh_key_authenticatable_id, :ssh_key_authenticatable_type]
  validate :validate_no_ssh_directives
  
  after_save :write_key_file
  after_destroy :write_key_file
  before_validation { |r| r.clean_key }
  
  SSH_DIRECTIVES = [
    "command", "svnserve", "tunnel-user", "port-forwarding", "agent-forwarding", "X11-forwarding", "pty"
  ]


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
    k = key || ""
    logger.debug("RAW SSH KEY")
    logger.debug(k.inspect)

    write_attribute(:key, k.gsub(/\n/, "").gsub(/\r/, ""))
    logger.debug("CLEAN SSH KEY")
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
      errors.add(:key, "Key contains illegal tokens.")
    end
  end

  def authz_keys_file
    self.class.authz_keys_file
  end

  def write_key_file
    self.class.write_key_file
  end
  alias :write_authorized_keys_file :write_key_file

  ##
  # Enables us to specify svn urls like: (svn+ssh://server.berkeley.edu/repo)
  # instead of: (svn+ssh://server.berkeley.edu/apps/home/ezsvn/spaces/repo)
  #
  # For more info see man page for svnserve
  #
  # @return [String] virtual root url used for our repos.
  #
  def virtual_root
    "-r #{svn_service.space_root}"
  end

  ##
  # Returns entry for this key in auth file per
  # http://svnbook.red-bean.com/nightly/en/svn-book.html#svn.serverconfig.svnserve.sshtricks
  #
  # @return [String] a single complete key entry for the authorized_keys file.
  #
  def key_file_entry
    "command=\"/home/svn/bin/svnserve_wrapper -t --tunnel-user=#{username()} #{virtual_root()}\",no-port-forwarding,no-agent-forwarding,no-X11-forwarding,no-pty #{key()}"
  end
  alias :authorized_keys_entry :key_file_entry

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
    elsif ssh_key_authenticatable.is_a?(Space)
      "#{parent.deploy_user_name}"
    end
  end

  def svn_service
    self.class.svn_service
  end


  def self.svn_service
    UcbSvn
  end

  ##
  # Auto create authorized_keys file if it doesn't exist
  # Make sure .ssh is 0700
  # Make sure authorized_keys is 0660
  #
  # Typically, sshd requireds that the permissions are 0700 and 0600.  However,
  # we assume that sshd_conf has the following config option: "StrictModes no"
  # which relaxes its default restriction on these files.
  #
  # @return [nil]
  #
  def self.init_authz_keys_file
    Rails.logger.debug("Initializing authorized_keys file: #{authz_keys_file_root}")

    FileUtils.mkdir_p(authz_keys_file_root) unless File.exists?(authz_keys_file_root)
    FileUtils.chmod(0770, authz_keys_file_root)

    FileUtils.touch(authz_keys_file) unless File.exists?(authz_keys_file)
    App.call_os_cmd("chmod 0660 #{authz_keys_file}")
    # TODO
    # FileUtils.chmod doesn't set correct permissions
    # FileUtils.chmod(0660, authz_keys_file())
    App.call_os_cmd("chgrp #{AppConfig.app_group} #{authz_keys_file}")

    write_key_file

    if File.exists?(authz_keys_file)
      Rails.logger.debug("authorized_keys file initialization: [   OK   ]")
    else
      Rails.logger.debug("authorized_keys file initialization: [ FAILED ]")
    end
  end

  ##
  # Determines location of the .ssh/authorized_keys file for a given
  # environment [test, development, production]
  #
  def self.authz_keys_file_root
    env_regex = /(production.*|quality_assurance.*|dev_integration.*)/
    ssh_dir = Rails.env.to_s.match(env_regex) ? ".ssh" : "dot_ssh"
    "#{svn_service.root}/#{ssh_dir}"
  end

  def self.authz_keys_file
    "#{authz_keys_file_root}/authorized_keys"
  end

  def self.write_key_file(force = false)
    if always_update_key_file || force
      if !(File.exists?(authz_keys_file))
        Rails.logger.warn("File does not exist: #{authz_keys_file()}")
        init_authz_keys_file()
      end

      Rails.logger.debug("Writing authorized_keys file: #{authz_keys_file()}")

      File.open(authz_keys_file(), "w") do |f|
        f.flock(File::LOCK_EX)
        f.puts(key_file_contents())
        f.flock(File::LOCK_UN)
      end
    end
  end

  def self.write_authorized_keys_file(force = false)
    write_key_file(force)
  end

  def self.key_file_contents()
    self.all.map(&:authorized_keys_entry).join("\n")
  end
end
