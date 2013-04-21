class SpacesController < ApplicationController
  current_tab :major, :spaces
  current_tab :minor, :detail, :only => [:edit, :update, :show]
  current_tab :minor, :change_name, :only => [:edit_name, :update_name]

  helper(SpaceTabsHelper)


  def index
    @spaces = current_user.spaces_owned
  end

  def new
    @space = current_user.spaces.build
  end

  def create
    space_creator.create(space_params)
    @space = space_creator.space

    if @space.persisted?
      redirect_to(spaces_url, :flash => { success: msg_created(@space)})
    else
      render('new')
    end
  end

  def edit
    @space = find_space
  end

  # TODO: restore confirmation behaviour since space name change will
  # change connection url of all repositories in a space
  def update
    space_updater.update(space_params)

    if @space.valid?
      redirect_to(edit_space_path(@space), :flash => { success: msg_updated(@space) })
    else
      render('edit')
    end
  end

  def destroy
    space_destroyer.destroy
    @space = space_destroyer.space

    if @space.destroy
      redirect_to(spaces_url, :flash => { success: msg_destroyed(@space)})
    else
      redirect_to(edit_space_url(@space), :flash => { error: @space.errors.full_messages})
    end
  end


  private

  def find_space
    @space ||= current_user.spaces_owned.find(params[:id])
  end

  def space_updater
    @space_creator ||= SpaceService::Updater.new(:current_user => current_user, :space => find_space)
  end

  def space_destroyer
    @space_creator ||= SpaceService::Destroyer.new(:current_user => current_user, :space => find_space)
  end

  def space_creator
    @space_creator ||= SpaceService::Creator.new(:current_user => current_user)
  end

  def space_params
    params.require(:space).permit(:name, :description)
  end

end

