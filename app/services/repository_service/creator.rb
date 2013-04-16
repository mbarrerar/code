require 'ostruct'

module RepositoryService
  class Creator
    CreateError = Class.new(StandardError)

    attr_accessor :svn_util, :current_user, :space, :repository

    def initialize(args)
      args.symbolize_keys!
      @svn_util = args.fetch(:svn, default_svn_util)
      @current_user = args.fetch(:current_user)
      @space = args.fetch(:space)
    end

    # TODO: takes params Hash instead of single arg?
    def create(repo_name)
      @repository = create_in_db(repo_name)
      create_on_file_system
    rescue CreateError, ActiveRecord::RecordInvalid => e
      # send out email?
    end

    private

    def default_svn_util
      UcbSvn
    end

    # creates svn repo record in the database
    def create_in_db(repo_name)
      unless space_owner_or_admin?
        raise CreateError, 'User is not Space Admin or Space Owner'
      end

      space.repositories.create!(:name => repo_name)
    end

    # creates svn repo on the filesystem and write out the
    # repository's permissions to its ROOT/conf/authz file
    #
    # TODO: what if the repo is already on the filesystem?
    #
    def create_on_file_system
      svn_util.create_repository(space.name, repository.name)
      svn_util.write_repository_authz_file(space.name, repository.name, authz_content)
      svn_util.initialize_post_commit_hook_file(space.name, repository.name)
    end

    def space_owner_or_admin?
      space.owner_or_admin?(current_user)
    end

    def authz_content
      authz_file = AuthzFile.new
      authz_file.append_committers(space.administrators(true))
      authz_file.append_committers([OpenStruct.new(:username => space.deploy_user_name)])
      authz_file.append_committers([OpenStruct.new(:username => 'app_hudson')])
      authz_file.append_committers(repository.committers)
      authz_file.append_readers(repository.readers)
      authz_file.to_s
    end

  end
end
