 class RepositoryCollaboratorsController < ApplicationController
  before_filter(:user)
  before_filter(:repository)
  before_filter(:permissions)

  current_tab(:major, :repositories)
  current_tab(:minor, :collaborators)

  helper(RepositoryTabsHelper)
  helper(RepositoriesHelper)

  
  def index()
    @collaborations = @repo.collaborations()
    @administrators = @repo.administrators()
  end

  def edit()
    @users = @repo.collaborators_available()
    @administrators = @repo.administrators()
  end

  def update()
    repository.update_collaborators_from_params(current_user, params)
    flash[:notice] = msg_updated("Collaborators")
    redirect_to(repository_collaborations_url(@repo, :id => ''))
  end


private
  
  def permissions()
    @permissions = Collaboration.permissions()
    @permissions.unshift("")
  end

  def user()
    @user = current_user()
  end
  
  def repository()
    @repo = @user.find_repository_administered(params[:repository_id])
  end
end
