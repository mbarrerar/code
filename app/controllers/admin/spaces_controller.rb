class Admin::SpacesController < Admin::BaseController

  current_tab(:major, :spaces)
  current_tab(:minor, :detail, :only => [:edit, :update])

  helper(Admin::SpaceTabsHelper)
  helper(::SpacesHelper)


  def index
    @spaces = Space.all(:order => :name)
  end

  def new
    @space = Space.new
  end

  def create
    @space = Space.new(params[:space])
    if @space.save
      flash[:success] = msg_created(@space)
      redirect_to(edit_admin_space_url(@space))
    else
      render('new')
    end
  end

  def edit
    @space = Space.find(params[:id])
  end

  def update
    if space.update_attributes(space_params)
      flash[:success] = msg_updated(space)
      redirect_to(edit_admin_space_url(space))
    else
      render('edit')
    end
  end

  def destroy
    if space.destroy
      flash[:success] = msg_destroyed(space)
      redirect_to(admin_spaces_url)
    else
      flash[:error] = space.errors.full_messages
      redirect_to(edit_admin_space_url(space))
    end
  end

  protected

  def space_params
    params.require(:space).permit!
  end

  def space
    @space ||= Space.find(params[:id])
  end
  helper_method :space

  def spaces
    @spaces ||= Space.all
  end
  helper_method :spaces
end
