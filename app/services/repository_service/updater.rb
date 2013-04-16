module RepositoryService
  class Updater
    UpdateError = Class.new(StandardError)

    attr_accessor :svn_util, :current_user, :space, :repository

    def initialize(args)
      @svn_util = args.fetch(:svn, default_svn_util)
      @current_user = args.fetch(:current_user)
      @space = args.fetch(:space)
      @repository = args.fetch(:repository)
    end

    # TODO: takes params Hash instead of single arg?
    # :hudson_ci => true  ... ?
    #
    def update(repo_name)
      update_db(repo_name)
      update_file_system
    rescue CreateError, ActiveRecord::RecordInvalid => e
      # send out email?
    end


    private

    def default_svn_util
      UcbSvn
    end

    def update_db(repo_name)
      unless space_owner_or_admin?
        raise UpdateError, 'User is not Space Admin or Space Owner'
      end

      @repository = space.repositories.find(repository.id)
      @repository.update_attributes!(:name => repo_name)

      if @repository.space_id_changed?
        change_repository_owner
      end
    end

    def space_owner_or_admin?
      space.owner_or_admin?(current_user)
    end

    def change_repository_owner
      repo_owner = repository.space.owner
      if repository.collaborators.include?(repo_owner)
        repository.collaborations.find_by_user_id(repo_owner).try(:destroy)
      end
    end

    def update_file_system
      if repository.name_changed?
        rename_svn_repository
      end

      if repository.space_id_changed?
        move_repository_to_new_space
      end

      write_authz_file
      update_post_commit_hook_file
    end

    def authz_content
      authz_file = AuthzFileContents.new
      authz_file.append_committers(repository.committers)
      authz_file.append_readers(repository.readers)
      authz_file.append_committers([OpenStruct.new(:username => space.deploy_user_name)])
      authz_file.append_committers([OpenStruct.new(:username => 'app_hudson')])
      authz_file.to_s
    end

    def write_auth_file
      svn_util.write_repository_authz_file(space.name, repository.name, authz_content)
    end

    def upate_post_commit_hook_file
      svn_util.initialize_post_commit_hook_file(space.name, repository.name)
    end

    def rename_svn_repository
      old_space_name = Space.find(space_id_was).name
      svn_util.rename_repository(old_space_name, name_was, name)
    end

    def move_repository_to_new_space
      old_space_name = Space.find(repository.space_id_was).name
      new_space_name = Space.find(repository.space_id).name
      svn_util.move_repository(name, old_space_name, new_space_name)
    end

  end
end
