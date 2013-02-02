class SshKeysController < ApplicationController
  before_filter(:find_ssh_key, :only => [:edit, :update, :destroy])

  def index
  end

  def new
    @ssh_key = user.ssh_keys.build
  end

  def edit
  end
  
  def create
    @ssh_key = user.ssh_keys.build(ssh_key_params)
    if @ssh_key.save
      SshKeyAudit.log(@ssh_key, user, :create)
      flash[:success] = msg_created(@ssh_key)
      redirect_to(ssh_keys_url)
    else
      render("new")
    end
  end

  def update
    if @ssh_key.update_attributes(ssh_key_params)
      SshKeyAudit.log(@ssh_key, user, :update)
      flash[:success] = msg_updated(@ssh_key)
      redirect_to(ssh_keys_url)
    else
      render("edit")
    end
  end

  def destroy
    @ssh_key.destroy
    
    SshKeyAudit.log(@ssh_key, user, :destroy)
    
    respond_to do |format|
      format.html do
        destroy_notification(@ssh_key)
        redirect_to(redirect_to(ssh_keys_url))
      end
      
      format.js { render(:layout => false) }
    end
  end


  protected

  def ssh_key_params
    params.require(:ssh_key).permit(:name, :key)
  end

  def find_ssh_key
    @ssh_key ||= user.ssh_keys.find(params[:id])
  end

  def ssh_key
    find_ssh_key
  end
  helper_method :ssh_key

  def ssh_keys
    user.ssh_keys
  end
  helper_method :ssh_keys

  def user
    current_user
  end
  helper_method :user
end
