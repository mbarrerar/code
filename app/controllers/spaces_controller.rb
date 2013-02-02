class SpacesController < ApplicationController
  before_filter(:user)

  current_tab :minor, :detail, :only => [:edit, :update, :show]
  current_tab :minor, :change_name, :only => [:edit_name, :update_name]

  helper(SpaceTabsHelper)


  def index
    params[:viewing] = "own_or_admin" unless params[:viewing]
    @spaces = SpaceLookupService.find_by_viewing(@user, params[:viewing])
    @search_options = [["You Own or Administer", "own_or_admin"], ["You Own", "own"], ["You Administer", "administer"]]
  end
  
  def new
    @space = @user.spaces_owned.build()
  end
  
  def create
    @space = @user.spaces_owned.build()
    if @space.update_attributes(params[:space])
      flash[:notice] = msg_created(@space)
      redirect_to(spaces_url)
    else
      render('new')
    end
  end

  def show
    @space = @user.spaces_administered.find(params[:id])
  end
  
  def edit
    @space = @user.spaces_owned.find(params[:id])
  end
  
  def update
    @space = @user.spaces_owned.find(params[:id])
    @space.attributes = params[:space]

    if @space.valid? && Space.confirmation_required?(@space)
      render('confirm_update')
    elsif @space.save()
      flash[:notice] = msg_updated(@space)
      redirect_to(edit_space_path(@space))
    else
      render("edit")
    end
  end

  def confirm_update()
    @space = @user.spaces_administered.find(params[:id])
    @space.update_attributes(params[:space])

    if params[:perform_notification]
      messages = RepositoryUrlChangedMessage.new_from_space_params(current_user(), params[:space_changed])
      messages.each { |msg| CollaboratorMailer.deliver_repository_url_changed_notification(msg) }
    end

    flash[:notice] = msg_updated(@space)
    redirect_to(edit_space_path(@space))
  end

  def destroy
    @space = @user.spaces_owned.find(params[:id])
    if @space.destroy
      flash[:notice] = msg_destroyed(@space)
      redirect_to(spaces_url)
    else
      flash[:error] = @space.errors.full_messages
      redirect_to(edit_space_url(@space))
    end
  end


private

  def user()
    @user = current_user()
  end

end

