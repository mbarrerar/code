class RepositoryLookupService
  
  class << self
    ##
    # Returns the repository record only if the user is one of the
    # repositories administrators.
    #
    # @params [Integer] The repository's primary key.
    # @params [User] The user that administers the repository.
    # @return [Repository, nil]
    #
    def find_if_administered_by(repository_id, user)
      user.repositories_administered.detect { |r| r.id == repository_id }
    end

    ##
    # @params [User]
    # @return [Array<Repository>]
    #
    def find_administered_by(user)
      (user.spaces_administered.map(&:repositories).flatten - find_owned_by(user))
    end

    ##
    # @params [User]
    # @return [Array<Repository>]
    #
    def find_owned_by(user)
      user.spaces_owned.map(&:repositories).flatten
    end

    ##
    # @params [User]
    # @return [Array<Repository>]
    #
    def find_owned_or_administered_by(user)
      (find_administered_by(user) + find_owned_by(user)).uniq
    end

    ##
    # List of repositories for which this user has commit permission.
    #
    # @param [User]
    # @returns [Array<Repository>]
    #
    def committable_by(user)
      Repository.all.inject([]) do |repos, repo|
        permission = permissions_service.permission_for(user, repo)
        repos << repo if permission.try(:commit?)
        repos
      end
    end

    ##
    # List of repositories for which this user has read permission.
    #
    # @param [User]
    # @returns [Array<Repository>]
    #
    def readable_by(user)
      Repository.all.inject([]) do |repos, repo|
        permission = permissions_service.permission_for(user, repo)
        repos << repo if permission.try(:read?)
        repos
      end
    end

    ##
    # List of repositories for which this user has commit or read permission.
    #
    # @param [User]
    # @returns [Array<Repository>]
    #
    def committable_or_readable_by(user)
      Repository.all.inject([]) do |repos, repo|
        repos << repo if permissions_service.permission_for(user, repo)
        repos
      end
    end

    ##
    # List of repositories for which this user has neither commit or
    # read permission.
    #
    # @param [User]
    # @returns [Array<Repository>]
    #
    def not_accessible_by(user)
      Repository.all.inject([]) do |repos, repo|
        repos << repo unless permissions_service.permission_for(user, repo)
        repos
      end
    end

    def find_by_permission(user, permission)
      if !["commit_or_read", "none"].include?(permission) || permission.blank?
        permission = "any"
      end

      if permission == "any"
        Repository.all.sort_by { |r| r.name.downcase() }
      elsif permission == "commit_or_read"
        committable_or_readable_by(user).sort_by { |r| r.name.downcase() }
      elsif permission == "none"
        not_accessible_by(user).sort_by { |r| r.name.downcase() }
      end
    end

    def search_options()
      [["Any", "any"], ["Commit or Read", "commit_or_read"], ["None", "none"]]
    end


    ##
    # @param [User]
    # @param [String]  "administer", "own" or nil
    #
    def find_by_viewing(user, viewing)
      if viewing == "administer"
        find_administered_by(user).sort_by { |r| r.name.downcase() }
      elsif viewing == "own"
        find_owned_by(user).sort_by { |r| r.name.downcase() }
      else
        find_owned_or_administered_by(user).sort_by { |r| r.name.downcase() }
      end
    end

    def permissions_service()
      @permissions_service ||= UserPermissionsService
    end
  end

end
