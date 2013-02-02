class Admin::RepositoriesController < Admin::BaseController
  before_filter(:repository, :only => [:edit, :update, :destroy])
  before_filter(:spaces, :only => [:new, :create, :edit, :update, :destroy])

  no_minor_tabs :only => [:index, :new, :create]
  current_tab(:major, :repositories)
  current_tab(:minor, :detail, :only => [:edit, :update])

  helper(Admin::RepositoryTabsHelper)
  helper(::RepositoriesHelper)


  def index
    @repos = Repository.find_by_space_name(params[:space])
    @spaces = Space.select_options
  end
  
  def new
    @repo = Repository.new
  end
  
  def create
    @repo = Repository.new(params[:repository])
    if @repo.save
      flash[:notice] = msg_created(@repo)
      redirect_to(edit_admin_repository_path(@repo))
    else
      render('new')
    end
  end
  
  def edit
    @repo = Repository.find(params[:id])
  end

  def update
    @spaces = available_spaces
    @repo = Repository.find(params[:id])
    @repo.attributes = params[:repository]

    if @repo.valid? && Repository.confirmation_required?(@repo)
      render('confirm_update')
    elsif @repo.save()
      flash[:notice] = msg_updated(@repo)
      redirect_to(edit_admin_repository_path(@repo))
    else
      render("edit")
    end
  end

  def confirm_update
    @repo = Repository.find(params[:id])
    @repo.update_attributes(params[:repository])

    if params[:perform_notification]
      msg = RepositoryUrlChangedMessage.
        new_from_repository_params(current_user, params[:repo_changed])
      CollaboratorMailer.deliver_repository_url_changed_notification(msg)
    end

    flash[:notice] = msg_updated(@repo)
    redirect_to(edit_admin_repository_path(@repo))
  end

  def destroy
    @repo = Repository.find(params[:id])
    @repo.destroy
    flash[:notice] = msg_destroyed(@repo)
    redirect_to(admin_repositories_path)
  end

  def create_svn_directory
    @repo = Repository.find(params[:id])
    if !@repo.svn_dir_exists?
      @repo.create_svn_repository
      flash[:notice] = "SVN Directory has been created."
    end
    redirect_to(edit_admin_repository_path(@repo))
  end


  protected

  def repository
    @repo = Repository.find(params[:id])
  end

  def spaces
    @spaces = Space.all()
  end

  def available_spaces
    spaces.inject({}) do |hash, space|
      hash[space.name] = space.id
      hash
    end
  end

end
