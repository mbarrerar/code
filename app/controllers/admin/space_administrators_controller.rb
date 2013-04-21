class Admin::SpaceAdministratorsController < Admin::BaseController
  current_tab(:major, :spaces)
  current_tab(:minor, :administrators)

  helper('admin/space_tabs')
  helper('spaces')
  helper('space_owners')


  def index
  end

  def edit
  end

  def update
    space.update_administrators_from_params(current_user, params)
    flash[:notice] = msg_updated("Administrators")
    redirect_to(admin_space_administrators_url(space, :id => ""))
  end


  protected

  def space
    @space ||= Space.find(params[:space_id])
  end
  helper_method :space

  def users
    @users ||= space.administrators_available([current_user])
  end
  helper_method :users

  def administrations
    @administrations ||= space.administrations
  end
  helper_method :administrations
end
