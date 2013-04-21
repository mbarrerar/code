class SpaceOwnersController < ApplicationController
  before_filter(:find_space)

  current_tab(:major, :spaces)
  current_tab(:minor, :owners)

  helper(SpaceTabsHelper)
  helper(SpacesHelper)


  def index
    @owners = @space.owners
  end

  def edit
    @users = @space.owners_available
  end

  def update
    owner_updater.update(owner_ids)
    redirect_to(space_owners_url(@space), :flash => { success: msg_updated("Owners") })
  end


  private

  def owner_ids
    (params[:owner_ids] || {}).keys
  end

  def owner_updater
    @owner_updater ||= SpaceService::OwnerUpdater.new(:current_user => current_user, :space => @space)
  end

  def find_space
    @space = current_user.spaces_owned.find(params[:space_id])
  end

end
