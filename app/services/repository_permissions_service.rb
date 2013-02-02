class RepositoryPermissionsService
  
  class << self
    ##
    # Retrieves all 'commit' permissions for a given repository.
    #
    # @param [Repository]
    # @returns [Array<Permission>]
    #
    def commit_permissions(repo)
      from_administration = repo.space.administrations.inject([]) do |perms, admin|
        perms << Permission.new_from_space_administration(admin, repo)
      end

      from_collaboration = repo.collaborations.inject([]) do |perms, collab|
        perms << Permission.new_from_collaboration(collab) if collab.commit?
        perms
      end

      (from_administration + from_collaboration).uniq
    end

    ##
    # Retrieves all 'read' permissions for a given repo.
    #
    # @param [Repository]
    # @returns [Array<Permission>]
    #
    def read_permissions(repo)
      repo.collaborations.inject([]) do |perms, collab|
        perms << Permission.new_from_collaboration(collab) if collab.read?
        perms
      end
    end

    ##
    # Retrieves all 'read' and 'commit' permissions for a given repo.
    #
    # @param [Repository]
    # @returns [Array<Permission>]
    #
    def permissions(repo)
      (commit_permissions(repo) + read_permissions(repo))
    end

    ##
    # Retrieves the permission on a repository for a given user.
    #
    # @param [Repository]
    # @param [User]
    # @returns [Permission, nil]
    #
    def permission_for(repo, user)
      permissions(repo).detect { |p| p.user.id == user.id }
    end
  end

end
