class SshKeyObserver < ActiveRecord::Observer
  observe :ssh_key

  def after_save(ssh_key)
    authorized_keys_file.write(SshKey.all)
  end

  def after_destroy(ssh_key)
    authorized_keys_file.write(SshKey.all)
  end

  def authorized_keys_file
    @authorized_keys_file ||= AuthorizedKeysFile.new(AppConfig)
  end
end
