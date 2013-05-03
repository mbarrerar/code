class Admin::SshKeysController < Admin::BaseController
  before_filter(:find_user)
  before_filter(:find_ssh_key, :only => [:edit, :update, :destroy])

  current_tab(:major, :users)
  current_tab(:minor, :ssh_keys)

  helper('admin/users')


  def index
  end

  def new
    @ssh_key = user.ssh_keys.build
  end

  def create
    creator.create(ssh_key_params)
    @ssh_key = creator.ssh_key

    if @ssh_key.persisted?
      redirect_to(admin_user_ssh_keys_url(user), :flash => { success: msg_created(@ssh_key) })
    else
      render("new")
    end
  end

  def destroy
    #@ssh_key.destroy
    #respond_to do |format|
    #  format.html do
    #    destroy_notification(@ssh_key)
    #    redirect_to(redirect_to(admin_user_ssh_keys_url(user)))
    #  end
    #
    #  format.js { render(:layout => false) }
    #end
  end


  protected
  def creator
    @creator ||= SshKeyService::Creator.new(:user => user)
  end

  def ssh_key_params
    params.require(:ssh_key).permit!
  end

  def find_ssh_key
    @ssh_key ||= user.ssh_keys.find(params[:id])
  end

  def find_user
    @user ||= User.find(params[:user_id])
  end

  def user
    @user
  end

  helper_method :user

  def ssh_key
    @ssh_key
  end

  helper_method :ssh_key

  def ssh_keys
    @ssh_keys ||= user.ssh_keys
  end

  helper_method :ssh_keys
end
