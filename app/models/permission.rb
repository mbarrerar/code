class Permission
  COMMIT = 'commit'
  READ   = 'read'
  
  include Comparable
  
  attr_accessor :user, :permission, :repository, :space, :space_repository_token, :sort_token

  def <=>(other_perm)
    self.sort_token <=> other_perm.sort_token
  end

  def id
    "#{repository.name}_#{space.name}_#{user.id}"
  end

  ##
  # @return [Boolean]
  #
  def commit?
    permission == COMMIT
  end

  ##
  # @return [Boolean]
  #
  def read?
    permission == READ
  end
  
  class << self
    ##
    # @param [SpaceAdministration]
    # @param [Repository]
    # @return [Permission]
    #
    def new_from_space_administration(administration, repo)
      space = administration.space
      
      Permission.new.tap do |p|
        p.user = administration.user
        p.permission = COMMIT
        p.repository = repo
        p.space = space
        p.space_repository_token = "#{space.name} / #{repo.name}"
        p.sort_token = "#{space.name}#{repo.name}"
      end
    end

    ##
    # @param [Collaboration]
    # @return [Permission]
    #
    def new_from_collaboration(collab)
      repo = collab.repository
      space = repo.space()

      Permission.new.tap do |p|
        p.user = collab.user
        p.permission = collab.permission
        p.repository = repo
        p.space = space
        p.space_repository_token = "#{space.name} / #{repo.name}"
        p.sort_token = "#{space.name}#{repo.name}"
      end
    end

    ##
    # @return [Array<String>]
    #
    def permissions
      [COMMIT, READ]
    end
  end
end
