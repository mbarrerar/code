class SpaceRepositoriesController < ApplicationController
  current_tab(:major, :spaces)
  current_tab(:minor, :repositories)

  helper(SpacesHelper)
  helper(SpaceTabsHelper)


  def index
    @space = current_user.spaces_owned.find(params[:space_id])
    @repositories = @space.repositories.all
  end
end
