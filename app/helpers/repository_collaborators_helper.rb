module RepositoryCollaboratorsHelper
  ##
  # Predicate that determines if the user has any permission for the
  # repository.
  #
  # @param [Repository]
  # @param [User]
  # @return [Boolean]
  #
  def has_access?(repo, user)
    RepositoryPermissionsService.permission_for(repo, user)
  end

  ##
  # Predicate that determines if the user specifically has "read" or "commit"
  # permission for a repository.
  #
  # @param [Repository]
  # @param [User]
  # @param [String] "commit" or "read"
  # @return [Boolean]
  #
  def has_permission?(repo, user, permission)
    RepositoryPermissionsService.permission_for(repo, user).try(:permission) == permission.to_s.downcase
  end

  ##
  # @param [Repository]
  # @param [User]
  # @return [String, nil] "commit", "read" or nil
  #
  def permission(repo, user)
    RepositoryPermissionsService.permission_for(repo, user).try(:permission)
  end

  def permission_widget(user, repo, permissions)
    if Space.administrator?(repo.space, user)
      Permission::COMMIT
    else
      select_tag(user.id, options_for_select(permissions, permission(repo, user)))
    end
  end

  ##
  # CSS string used to fade out a row for a user that already has permision
  # for a repository.
  #
  # @param [Repository]
  # @param [User]
  # @return [String]
  #
  def has_permission_css(repo, user)
    if has_access?(repo, user)
      "class='has_permission'"
    end
  end
end
