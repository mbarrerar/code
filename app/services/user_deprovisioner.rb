class UserDeprovisioner

  attr_accessor :user, :admin

  ##
  # Required options:
  # * user
  # * admin
  def initialize(args)
    args.symbolize_keys!

    @user = args.fetch(:user)
    @admin = args.fetch(:admin)
  end

  def deprovision
    delete_ssh_keys
    transfer_space_ownership
    delete_collaborations
    delete_administrations
  end

  private

  def delete_ssh_keys
    user.ssh_keys(true).each(&:destroy)
  end

  def transfer_space_ownership
    spaces_owned = user.spaces_owned(true)
    spaces_owned.each { |s| s.update_attribute(:owner_id, admin.id) }

    unless spaces_owned.empty?
      # AppAdminMailer.deliver_space_transfer_notification(admin, user, spaces_owned)
    end
  end

  def delete_collaborations
    user.collaborations(true).each do |c|
      c.destroy
      c.write_repository_authz_file
    end
  end

  def delete_administrations
    user.space_administrations(true).each do |sa|
      sa.destroy
      sa.write_repositories_authz_files
    end
  end
end
