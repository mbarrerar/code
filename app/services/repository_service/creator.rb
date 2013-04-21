require 'ostruct'

module RepositoryService
  class Creator
    CreateError = Class.new(StandardError)

    attr_accessor :svn_util, :current_user, :space, :repository

    def initialize(args={})
      args.symbolize_keys!
      @svn_util = args.fetch(:svn, default_svn_util)
      @current_user = args.fetch(:current_user)
    end

    def create(params)
      create_in_db(params)
      create_on_file_system
    rescue CreateError => e
      @repository.valid?
      @repository.errors.add(:base, e.message)
    end

    private

    def default_svn_util
      UcbSvn
    end

    def create_in_db(params)
      # TODO: add :enable_hudson_ci attribute
      @repository = current_user.repositories.build(
          :name => params[:name],
          :space_id => params[:space_id],
          :description => params[:description],
          :user_id => current_user.id
      )

      space_owner? || raise(CreateError, 'User is not Space Owner')

      @repository.save
    end

    def create_on_file_system
      svn_util.create_repository(space.name, repository.name)
      svn_util.write_repository_authz_file(space.name, repository.name, authz_content)
      svn_util.initialize_post_commit_hook_file(space.name, repository.name)
    end

    def space_owner?
      @space = Space.find_by_id(@repository.space_id)
      @space.nil? ? false : space.owner?(current_user)
    end

    def authz_content
      authz_file = AuthzFile.new
      authz_file.append_committers(space.owners(true))
      authz_file.append_committers([OpenStruct.new(:username => space.deploy_user_name)])
      authz_file.append_committers([OpenStruct.new(:username => 'app_hudson')])
      authz_file.append_committers(repository.committers)
      authz_file.append_readers(repository.readers)
      authz_file.to_s
    end

  end
end
