module UcbSvnCleanupHelper

  def self.remove_all_spaces
    Space.delete_all
    FileUtils.rm_rf(UcbSvn.root.join('spaces'))
  end
  
  def self.remove_all_users
    User.delete_all
    SshKey.delete_all
  end
  
  def self.remove_all
    remove_all_users
    remove_all_spaces

    AuthzKeysFile.new.delete
    Repository.delete_all
    Collaboration.delete_all
    SpaceAdministration.delete_all
    FileUtils.rm_rf(AppConfig.archive_dir)
  end
end
