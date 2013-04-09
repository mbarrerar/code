class Admin::SpaceRepositoriesController < Admin::BaseController
  current_tab(:major, :spaces)
  current_tab(:minor, :repos)

  helper('admin/space_tabs')
  helper('spaces')

  
  def index
  end
  
  def new
    @repository = space.repositories.build
  end
  
  def create
    @repository = space.repositories.build(repository_params)
    if @repository.save
      flash[:success] = msg_created(@repository)
      redirect_to(admin_space_repositories_path)
    else
      render('new')
    end
  end


  protected

  def repository_params
    params.require(:repository).permit!
  end

  def space
    @space ||= Space.find(params[:space_id])
  end
  helper_method :space

  def repository
    @repository
  end
  helper_method :repository

  def repositories
    @repositories ||= space.repositories.all
  end
  helper_method :repositories
end
