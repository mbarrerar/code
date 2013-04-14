class SpacesController < ApplicationController
  current_tab :minor, :detail, :only => [:edit, :update, :show]
  current_tab :minor, :change_name, :only => [:edit_name, :update_name]

  helper(SpaceTabsHelper)


  def index
    @spaces = SpaceLookupService.find_by_viewing(current_user, params[:viewing])
  end

  def new
    @space = current_user.spaces_owned.build
  end

  def create
    @space = current_user.spaces_owned.build
    if @space.update_attributes(space_params)
      redirect_to(spaces_url, :flash => { success: msg_created(@space)})
    else
      render('new')
    end
  end

  def show
    @space = current_user.spaces_administered.find(params[:id])
  end

  def edit
    @space = current_user.spaces_owned.find(params[:id])
  end

  def update
    @space = current_user.spaces_owned.find(params[:id])
    @space.attributes = space_params

    if @space.valid? && Space.confirmation_required?(@space)
      render('confirm_update')
    elsif @space.save
      redirect_to(edit_space_path(@space), :flash => { success: msg_updated(@space) })
    else
      render('edit')
    end
  end

  def confirm_update
    @space = current_user.spaces_administered.find(params[:id])
    @space.update_attributes(params[:space])

    if params[:perform_notification]
      messages = RepositoryUrlChangedMessage.new_from_space_params(current_user(), params[:space_changed])
      messages.each { |msg| CollaboratorMailer.deliver_repository_url_changed_notification(msg) }
    end

    redirect_to(edit_space_path(@space), :flash => { success: msg_updated(@space)})
  end

  def destroy
    @space = current_user.spaces_owned.find(params[:id])
    if @space.destroy
      redirect_to(spaces_url, :flash => { success: msg_destroyed(@space)})
    else
      redirect_to(edit_space_url(@space), :flash => { error: @space.errors.full_messages})
    end
  end


  private

  def space_params
    params.require(:space).permit(:name, :description)
  end

end

