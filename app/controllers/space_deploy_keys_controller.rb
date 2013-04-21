class SpaceDeployKeysController < ApplicationController
  before_filter(:find_space)

  current_tab(:major, :spaces)
  current_tab(:minor, :deploy_keys)

  helper(SpacesHelper)
  helper(SpaceTabsHelper)


  def index
    @ssh_keys = @space.deploy_keys
  end

  def new
    @ssh_key = @space.deploy_keys.build
  end

  def create
    @ssh_key = @space.deploy_keys.build(ssh_key_params)
    if @ssh_key.save
      redirect_to(space_deploy_keys_url(@space), :flash => { success: msg_created("Deploy Key") })
    else
      render("new")
    end
  end

  def destroy
    @ssh_key = @space.deploy_keys.find(params[:id])
    @ssh_key.destroy

    respond_to do |format|
      format.js { render :template => 'ssh_keys/destroy' }
    end
  end


  private

  def ssh_key_params
    params.require(:ssh_key).permit(:name, :key)
  end

  def find_space
    @space ||= current_user.spaces_owned.find(params[:space_id])
  end

  def space
    @space
  end

  helper_method :space

  def ssh_key
    @ssh_key
  end

  helper_method :ssh_key

  def ssh_keys
    @space.deploy_keys
  end

  helper_method :ssh_keys
end
