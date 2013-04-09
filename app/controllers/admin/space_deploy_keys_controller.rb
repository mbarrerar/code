class Admin::SpaceDeployKeysController < Admin::BaseController
  current_tab(:major, :spaces)
  current_tab(:minor, :deploy_keys)

  helper('admin/space_tabs')
  helper('spaces')


  def index
  end

  def new
    @deploy_key = space.deploy_keys.build
  end

  def create
    @deploy_key = space.deploy_keys.build(deploy_key_params)
    if @deploy_key.save
      flash[:success] = msg_created("Deploy Key")
      redirect_to(admin_space_deploy_keys_url(space))
    else
      render("new")
    end
  end

  def edit
  end

  def update
    deploy_key.update_attributes(deploy_key_params)
    if deploy_key.save
      flash[:success] = msg_updated("Deploy Key")
      redirect_to(admin_space_deploy_keys_url(space))
    else
      render("edit")
    end

  end

  def destroy
    deploy_key.destroy

    respond_to do |format|
      format.html do
        destroy_notification(deploy_key, "Deploy Key")
        redirect_to(admin_space_deploy_keys_url(space))
      end
      
      format.js { render(:layout => false) }
    end
  end

  
  protected

  def deploy_key_params
    params.require(:ssh_key).permit!
  end

  def space
    @space ||= Space.find(params[:space_id])
  end
  helper_method :space

  def deploy_keys
    @deploy_keys ||= space.deploy_keys
  end
  helper_method :deploy_keys

  def deploy_key
    @deploy_key ||= space.deploy_keys.find(params[:id])
  end
  helper_method :deploy_key
end
