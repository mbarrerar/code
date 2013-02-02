class SpaceRepositoriesController < ApplicationController
  current_tab(:major, :spaces)
  current_tab(:minor, :repositories)

  helper(SpacesHelper)
  helper(SpaceTabsHelper)


  def index
    @user = current_user()
    @space = @user.spaces_administered.find(params[:space_id])
    @repos = @space.repositories.all()
  end
end
