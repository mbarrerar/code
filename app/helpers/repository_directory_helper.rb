module RepositoryDirectoryHelper
  def permission(user, repo)
      UserPermissionsService.permission_for(user, repo).try(:permission)
  end

  def owner(repo)
    "#{repo.owner.full_name} - #{repo.owner.email}"
  end
end
