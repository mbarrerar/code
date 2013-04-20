class RepositoriesController < ApplicationController
  helper(RepositoryTabsHelper)
  current_tab(:major, :repositories)
  no_minor_tabs(:only => [:index, :new, :create])
  current_tab(:minor, :detail, :only => [:edit, :update])


  def index
    params[:viewing] = 'own_or_admin' unless params[:viewing]
    @repos = RepositoryLookupService.find_by_viewing(current_user, params[:viewing])
  end
  
  def new
    @spaces = available_spaces
    @repo = Repository.new
    @repo.set_default_space(current_user)
  end

  def create
    @spaces = available_spaces

    @repo = repo_creator.create(repo_params)
    if @repo.persisted?
      redirect_to(edit_repository_path(@repo), :flash => { success: msg_created(@repo) })
    else
      render('new')
    end
  end
  
  def edit
    @spaces = available_spaces
    @repo = current_user.find_repository_administered(params[:id])
  end
  
  def update
    @spaces = available_spaces
    @repo = current_user.find_repository_administered(params[:id])
    @repo.attributes = repo_params

    if @repo.valid? && Repository.confirmation_required?(@repo)
      render('confirm_update')
    elsif @repo.save
      redirect_to(edit_repository_path(@repo), :flash => { success: msg_updated(@repo) })
    else
      render('edit')
    end
  end

  def confirm_update
    @repo = current_user.find_repository_administered(params[:id])
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
    @repo = current_user.find_repository_administered(params[:id])
    @repo.destroy
    redirect_to(repositories_path, :flash => { success: msg_destroyed(@repo) })
  end


private

  def repo_params
    params.require(:repository).permit(:space_id, :name, :description)
  end

  def repo_creator
    @repo_creator ||= RepositoryService::Creator.new(:current_user => current_user)
  end

  def available_spaces
    current_user.spaces_administered.inject({}) do |hash, space|
      hash[space.name] = space.id
      hash
    end
  end
end
