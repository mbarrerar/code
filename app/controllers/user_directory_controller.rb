class DirectoryDirectoryController < ApplicationController
  
  def index
    @usersrepositories = RepositoryLookupService.find_by_permission(@user, params[:permission])
    @search_options = RepositoryLookupService.search_options()
  end

  def show
    @repo = Repository.find(params[:id])
    @permissions = Permission.permissions()
  end
end
