 class CollaboratorsController < ApplicationController
  before_filter(:find_repository)
  before_filter(:permissions)

  current_tab(:major, :repositories)
  current_tab(:minor, :collaborators)

  helper(RepositoryTabsHelper)
  helper(RepositoriesHelper)

  
  def index
    @collaborations = @repository.collaborations
  end

  def edit
    @users = User.all
  end

  def update
    repository.update_collaborators_from_params(current_user, params)
    redirect_to(repository_collaborations_url(@repository), :flash => { success: msg_updated('Collaborators') })
  end


private
  
  def permissions
    @permissions = Collaboration.permissions
    @permissions.unshift('')
  end

  def find_repository
    @repository ||= current_user.repositories.find(params[:repository_id])
  end
end
