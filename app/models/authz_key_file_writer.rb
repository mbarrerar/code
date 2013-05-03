class AuthzKeyFileWriter

  def initialize(args={})
    @svn_root = args.fetch(:svn_root, default_svn_root)
    @ssh_dir = args.fetch(:ssh_dir, default_ssh_dir)
    @app_group = args.fetch(:app_group, default_app_group)
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
  def create(ssh_keys=[])
    Rails.logger.debug("Initializing authorized_keys file: #{file_path}")

    FileUtils.mkdir_p(@ssh_dir) unless File.exists?(@ssh_dir)
    FileUtils.chmod(0770, @ssh_dir)

    FileUtils.touch(file_path) unless File.exists?(file_path)
    App.call_os_cmd("chmod 0660 #{file_path}")

    # TODO
    # FileUtils.chmod doesn't set correct permissions
    # FileUtils.chmod(0660, authorized_keys_file())
    App.call_os_cmd("chgrp #{@app_group} #{file_path}")

    self.write(ssh_keys)

    if File.exists?(file_path)
      Rails.logger.debug('authorized_keys file initialization: [   OK   ]')
    else
      Rails.logger.debug('authorized_keys file initialization: [ FAILED ]')
    end
  end

  def write(ssh_keys)
    unless File.exists?(file_path)
      Rails.logger.warn("Required file does not exist: #{file_path}")
      create
    end

    Rails.logger.debug("Writing authorized_keys file: #{file_path}")

    File.open(file_path, "w") do |f|
      f.flock(File::LOCK_EX)
      f.puts(key_entries(ssh_keys))
      f.flock(File::LOCK_UN)
    end
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

  def svn_root
    @svn_root
  end

  def ssh_dir
    @ssh_dir
  end

  ##
  # Location of the .ssh/authorized_keys file
  #
  def file_path
    "#{@ssh_dir}/authorized_keys"
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
    "-r #{@svn_root}/spaces"
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
