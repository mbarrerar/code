class SpaceDeployKeysController < ApplicationController
  before_filter(:find_space)

  current_tab(:major, :spaces)
  current_tab(:minor, :deploy_keys)

  helper(SpacesHelper)
  helper(SpaceTabsHelper)


  def index
    @keys = @space.deploy_keys
  end

  def new
    @key = @space.deploy_keys.build
  end

  def create
    @key = @space.deploy_keys.build(params[:ssh_key])
    if @key.save
      redirect_to(space_deploy_keys_url(@space), :flash => { success: msg_created("Deploy Key") })
    else
      render("new")
    end
  end

  def edit
    @key = @space.deploy_keys.find(params[:id])
  end

  def update
    @key = @space.deploy_keys.find(params[:id])
    @key.update_attributes(params[:ssh_key])
    if @key.save
      redirect_to(space_deploy_keys_url(@space), :flash => { success: msg_updated("Deploy Key") })
    else
      render("edit")
    end
  end

  # TODO, use ssh_key_destroyer service since we need to send out notification
  def destroy
    @key = @space.deploy_keys.find(params[:id])
    @key.destroy

    respond_to do |format|
      format.html do
        destroy_notification(@key)
        redirect_to(space_deploy_keys_url(@space))
      end
      
      format.js { render(:layout => false) }
    end
  end


private

  def find_space
    @space ||= current_user.spaces_owned.find(params[:space_id])
  end

end
