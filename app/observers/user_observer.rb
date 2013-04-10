class UserObserver < ActiveRecord::Observer
  observe :user

  def after_update(user)
    @user = user

    if user.active_changed? && !user.active?
      deprovisioner.deprovision
    end
  end

  def after_destroy(user)
    authorized_keys_file.write(SshKey.all)
  end

  def authorized_keys_file
    @authorized_keys_file ||= AuthorizedKeysFile.new(AppConfig)
  end

  private

  def deprovisioner
    @deprovisioner ||= UserDeprovisioner.new(:user => @user, :admin => User.admin.first)
  end
end
