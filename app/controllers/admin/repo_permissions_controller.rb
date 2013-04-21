class RepoPermissionsController < Admin::BaseController
  current_tab(:minor, :repository_permissions)
  
  def index
    @collaborations = @user.collaborations
  end
  
end
