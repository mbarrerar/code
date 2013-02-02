class Admin::SpaceRepositoriesController < Admin::BaseController
  current_tab(:major, :spaces)
  current_tab(:minor, :repos)

  helper(Admin::SpaceTabsHelper)
  helper(::SpacesHelper)

  
  def index
    @space = load_space()
    @repos = @space.repositories.all()
  end
  
  def new
    @space = load_space()
    @repo = @space.repositories.build()
  end
  
  def create
    @space = load_space()
    @repo = @space.repositories.build(params[:repository])
    if @repo.save
      flash[:notice] = msg_created(@repo)
      redirect_to(admin_space_repositories_path)
    else
      render('new')
    end
  end


private

  def load_space()
    Space.find(params[:space_id])
  end
end
