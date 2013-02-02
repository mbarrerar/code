class Admin::SpaceAdministratorsController < Admin::BaseController
  before_filter(:space)

  current_tab(:major, :spaces)
  current_tab(:minor, :administrators)

  helper(Admin::SpaceTabsHelper)
  helper(::SpacesHelper)
  helper(::SpaceAdministratorsHelper)


  def index()
    @administrations = space.administrations()
  end

  def edit()
    @users = space.administrators_available([current_user()])
  end

  def update()
    space.update_administrators_from_params(current_user(), params)
    flash[:notice] = msg_updated("Administrators")
    redirect_to(admin_space_space_administrations_url(@space, :id => ""))
  end


private

  def space()
    @space ||= Space.find(params[:space_id])
  end

end
