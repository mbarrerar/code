class CollaborationObserver < ActiveRecord::Observer

  ##
  # @param [Collaboration]
  #
  def after_save(collab)
    CollaboratorMailer.deliver_collaborator_notification(collab)
  end

end
