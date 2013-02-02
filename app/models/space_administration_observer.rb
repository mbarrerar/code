class SpaceAdministrationObserver < ActiveRecord::Observer

  ##
  # @param [SpaceAdministration]
  #
  def after_save(admin)
    if admin.created_by
      SpaceAdministratorMailer.deliver_space_administrator_notification(admin)
      SpaceAdministratorMailer.deliver_space_administrator_created_notification(admin)
    end
  end

end