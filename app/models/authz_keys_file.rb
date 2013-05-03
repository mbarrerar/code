##
# Responsible for managing reading/writing ssh public keys to ~/.ssh/authorized_keys
#
class AuthzKeysFile
  attr_accessor :svn_root, :ssh_dir, :app_group

  def initialize(args={})
    @svn_root = args.fetch(:svn_root, default_svn_root)
    @ssh_dir = args.fetch(:ssh_dir, default_ssh_dir)
    @app_group = args.fetch(:app_group, default_app_group)

    create
  end

  def entries
    File.readlines(file_path)
  end

  ##
  # Location of the .ssh/authorized_keys file
  #
  def file_path
    "#{@ssh_dir}/authorized_keys"
  end

  def write(ssh_keys)
    create_file unless File.exists?(file_path)

    Rails.logger.debug("Writing ssh keys to: #{file_path}")

    File.open(file_path, "w") do |f|
      f.flock(File::LOCK_EX)
      f.puts(key_entries(ssh_keys))
      f.flock(File::LOCK_UN)
    end
  end

  ##
  # Create authorized_keys file if it doesn't exist
  # Make sure .ssh is 0700
  # Make sure authorized_keys is 0660
  #
  # Typically, sshd requireds that the permissions are 0700 and 0600.  However,
  # we assume that sshd_conf has the following config option: "StrictModes no"
  # which relaxes its default restriction on these files.
  #
  def create
    unless File.exists?(ssh_dir)
      FileUtils.mkdir_p(ssh_dir)
      FileUtils.chmod(0770, ssh_dir)
    end

    if File.exists?(file_path)
      Rails.logger.debug("Found existing authorized_keys file: #{file_path}")
    else
      Rails.logger.debug("Creating authorized_keys file: #{file_path}")
      FileUtils.touch(file_path)
    end

    # TODO
    # FileUtils.chmod doesn't set correct permissions
    # FileUtils.chmod(0660, authorized_keys_file())
    App.call_os_cmd("chmod 0660 #{file_path}")
    App.call_os_cmd("chgrp #{app_group} #{file_path}")

    if File.exists?(file_path)
      Rails.logger.debug('authorized_keys file initialization: [   OK   ]')
    else
      Rails.logger.debug('authorized_keys file initialization: [ FAILED ]')
    end
  end

  def delete
    File.delete(file_path)
  end

  private


  def default_svn_root
    Pathname.new(AppConfig.svn_root)
  end

  def default_ssh_dir
    Pathname.new(AppConfig.ssh_dir)
  end

  def default_app_group
    AppConfig.app_group
  end

  ##
  # Enables us to specify svn urls like: (svn+ssh://server.berkeley.edu/repo)
  # instead of: (svn+ssh://server.berkeley.edu/apps/home/ezsvn/spaces/repo)
  #
  # For more info see man page for svnserve
  #
  # @return [String] virtual root url used for our repos.
  #
  def virtual_root
    "-r #{svn_root}/spaces"
  end

  ##
  # Returns entry for this key in auth file per
  # http://svnbook.red-bean.com/nightly/en/svn-book.html#svn.serverconfig.svnserve.sshtricks
  #
  # @return [String] a single complete key entry for the authorized_keys file.
  #
  def key_entry(username, key_contents)
    "command=\"/home/svn/bin/svnserve_wrapper -t --tunnel-user=#{username} #{virtual_root}\",no-port-forwarding,no-agent-forwarding,no-X11-forwarding,no-pty #{key_contents}"
  end

  def key_entries(ssh_keys)
    ssh_keys.map { |key| key_entry(key.username, key.key) }.join("\n")
  end

end
