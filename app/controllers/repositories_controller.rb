class RepositoriesController < ApplicationController
  before_filter(:user)

  helper(RepositoryTabsHelper)

  no_minor_tabs(:only => [:index, :new, :create])
  current_tab(:minor, :detail, :only => [:edit, :update])


  def index
    params[:viewing] = "own_or_admin" unless params[:viewing]
    @repos = RepositoryLookupService.find_by_viewing(@user, params[:viewing])
    @search_options = [["You Own or Administer", "own_or_admin"],
                       ["You Own", "own"],
                       ["You Administer", "administer"]]
  end
  
  def new
    @spaces = available_spaces
    @repo = Repository.new
    @repo.set_default_space(@user)
  end

  def create
    @spaces = available_spaces
    @repo = Repository.new(params[:repository])
    if @repo.save()
      flash[:notice] = msg_created(@repo)
      redirect_to(edit_repository_path(@repo))
    else
      render('new')
    end
  end
  
  def edit
    @spaces = available_spaces
    @repo = @user.find_repository_administered(params[:id])
  end
  
  def update
    @spaces = available_spaces
    @repo = @user.find_repository_administered(params[:id])
    @repo.attributes = params[:repository]

    if @repo.valid? && Repository.confirmation_required?(@repo)
      render('confirm_update')
    elsif @repo.save()
      flash[:notice] = msg_updated(@repo)
      redirect_to(edit_repository_path(@repo))
    else
      render("edit")
    end
  end

  def confirm_update
    @repo = @user.find_repository_administered(params[:id])
    @repo.update_attributes(params[:repository])

    if params[:perform_notification]
      msg = RepositoryUrlChangedMessage.new_from_repository_params(current_user(),
                                                                   params[:repo_changed])
      CollaboratorMailer.deliver_repository_url_changed_notification(msg)
    end

    flash[:notice] = msg_updated(@repo)
    redirect_to(edit_repository_path(@repo))
  end

  def destroy
    @repo = @user.find_repository_administered(params[:id])
    @repo.destroy
    flash[:notice] = msg_destroyed(@repo)
    redirect_to(repositories_path)
  end


private

  def available_spaces
    @user.spaces_administered.inject({}) do |hash, space|
      hash[space.name] = space.id
      hash
    end
  end

  def user
    @user = current_user
  end

end
