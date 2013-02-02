class UserPermissionsService

  class << self
    ##
    # Retrieves all 'commit' permissions for a given user.
    #
    # @param [User]
    # @returns [Array<Permission>]
    #
    def commit_permissions(user)
      from_administration = user.space_administrations.inject([]) do |perms, administration|
        administration.space.repositories.each do |repo|
          p = Permission.new_from_space_administration(administration, repo)
          perms <<  p
        end
        perms
      end
      
      from_collaboration = user.collaborations.inject([]) do |perms, collab|
        perms << Permission.new_from_collaboration(collab) if collab.commit?
        perms
      end
      
      (from_administration + from_collaboration).uniq
    end

    ##
    # Retrieves all 'read' permissions for a given user.
    #
    # @param [User]
    # @returns [Array<Permission>]
    #
    def read_permissions(user)
      user.collaborations.inject([]) do |perms, collab|
        perms << Permission.new_from_collaboration(collab) if collab.read?
        perms
      end
    end

    ##
    # Retrieves all 'read' and 'commit' permissions for a given user.
    #
    # @param [User]
    # @returns [Array<Permission>]
    #
    def permissions(user)
      (commit_permissions(user) + read_permissions(user))
    end

    ##
    # Retrieves a user's permission for a given repository.
    #
    # @param [User]
    # @param [DbRepo]
    # @returns [Permission, nil]
    #
    def permission_for(user, repo)
      permissions(user).detect { |p| p.repository.id == repo.id }
    end
  end

end
