class Admin::UserPermissionsController < Admin::BaseController
  current_tab(:major, :users)
  current_tab(:minor, :permissions)

  helper('admin/users')


  def index
    @user = User.find(params[:user_id])
    @permissions = @user.collaborations
  end

  protected

  def user
    @user
  end
  helper_method :user

  def permissions
    @permissions
  end
  helper_method :permissions
end
