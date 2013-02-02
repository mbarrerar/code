class SpaceAdministratorsController < ApplicationController

  before_filter(:user)
  before_filter(:space)

  current_tab(:major, :spaces)
  current_tab(:minor, :administrators)

  helper(SpaceTabsHelper)
  helper(SpacesHelper)

  
  def index()
    @administrations = @space.administrations()
  end
  
  def edit()
    @users = @space.administrators_available([current_user()])
  end
  
  def update()
    space.update_administrators_from_params(current_user(), params)
    flash[:notice] = msg_updated("Administrators")
    redirect_to(space_space_administrations_url(@space, :id => ""))
  end


private

  def user()
    @user = current_user()
  end

  def space()
    @space = @user.spaces_administered.find(params[:space_id])
  end

end
