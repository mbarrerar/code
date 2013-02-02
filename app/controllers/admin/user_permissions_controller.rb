class Admin::UserPermissionsController < Admin::BaseController
  current_tab(:major, :users)
  current_tab(:minor, :repository_permissions)

  helper(Admin::UsersHelper)


  def index()
    @user = User.find(params[:user_id])
    @permissions = UserPermissionsService.permissions(@user).sort_by { |perm| perm.repository.name }
  end

end
