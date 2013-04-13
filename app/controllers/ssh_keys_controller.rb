class SshKeysController < ApplicationController
  respond_to :html, :js

  def index
  end

  def new
    @ssh_key = current_user.ssh_keys.build
  end

  def edit
    @ssh_key ||= current_user.ssh_keys.find(params[:id])
  end
  
  def create
    @ssh_key = current_user.ssh_keys.build(ssh_key_params)
    if @ssh_key.save
      SshKeyAudit.log(@ssh_key, current_user, :create)
      redirect_to(ssh_keys_url, :flash => { success: msg_created(@ssh_key) })
    else
      render('new')
    end
  end

  def update
    @ssh_key = current_user.ssh_keys.find(params[:id])
    if @ssh_key.update_attributes(ssh_key_params)
      SshKeyAudit.log(@ssh_key, current_user, :update)
      redirect_to(ssh_keys_url, :flash => { success: msg_updated(@ssh_key) })
    else
      render('edit')
    end
  end

  def destroy
    @ssh_key = current_user.ssh_keys.find(params[:id])
    @ssh_key.destroy
    
    SshKeyAudit.log(@ssh_key, current_user, :destroy)

    respond_with(@ssh_key)
  end


  protected

  def ssh_key_params
    params.require(:ssh_key).permit(:name, :key)
  end

  def ssh_key
    @ssh_key
  end
  helper_method :ssh_key

  def ssh_keys
    current_user.ssh_keys
  end
  helper_method :ssh_keys

end
