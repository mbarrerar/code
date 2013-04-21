class RepositoriesController < ApplicationController
  helper(RepositoryTabsHelper)

  current_tab(:major, :repositories)
  no_minor_tabs(:only => [:index, :new, :create])
  current_tab(:minor, :detail, :only => [:edit, :update])


  def index
    @repositories = current_user.repositories
  end
  
  def new
    @spaces = current_user.spaces_owned
    @repository = current_user.repositories.build
  end

  def create
    @spaces = current_user.spaces_owned

    repo_creator.create(repo_params)
    @repository = repo_creator.repository

    if @repository.persisted?
      redirect_to(edit_repository_path(@repository), :flash => { success: msg_created(@repository) })
    else
      render('new')
    end
  end

  def edit
    @spaces = current_user.spaces_owned
    @repository = current_user.repositories.find(params[:id])
  end

  # TODO: restore confirmation behaviour since repository name (or space)
  # change will change the connection url
  def update
    @spaces = current_user.spaces_owned
    @repository = current_user.repositories.find(params[:id])
    @repository.attributes = repo_params

    if @repository.save
      redirect_to(edit_repository_path(@repository), :flash => { success: msg_updated(@repository) })
    else
      render('edit')
    end
  end

  def destroy
    @repository = current_user.repositories.find(params[:id])
    @repository.destroy
    redirect_to(repositories_path, :flash => { success: msg_destroyed(@repository) })
  end


private

  def repo_params
    params.require(:repository).permit(:space_id, :name, :description)
  end

  def repo_creator
    @repo_creator ||= RepositoryService::Creator.new(:current_user => current_user)
  end

end
