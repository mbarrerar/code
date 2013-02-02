class Admin::SshKeysController < Admin::BaseController
  current_tab(:major, :users)
  current_tab(:minor, :ssh_keys)
  helper(Admin::UsersHelper)


  def index
    @user = load_user()
    @keys = @user.ssh_keys()
  end

  def new
    @user = load_user()
    @key = @user.ssh_keys.build()
  end

  def edit
    @user = load_user()
    @key = load_ssh_key_for(@user)
  end
  
  def create
    @user = load_user()    
    @key = @user.ssh_keys.build(params[:ssh_key])
    
    if @key.save
      SshKeyAudit.log(@key, current_user(), :create)
      flash[:notice] = msg_created(@key)
      redirect_to(admin_user_ssh_keys_url(@user))
    else
      render("new")
    end
  end

  def update
    @user = load_user()    
    @key = load_ssh_key_for(@user)
    
    if @key.update_attributes(params[:ssh_key])
      SshKeyAudit.log(@key, current_user(), :update)
      flash[:notice] = msg_updated(@key)
      redirect_to(admin_user_ssh_keys_url(@user))
    else
      render("edit")
    end
  end

  def destroy()
    @user = load_user()
    @key = load_ssh_key_for(@user)
    @key.destroy()
    
    SshKeyAudit.log(@key, current_user(), :destroy)
    
    respond_to do |format|
      format.html do
        destroy_notification(@key)
        redirect_to(redirect_to(admin_user_ssh_keys_url(@user)))
      end
      
      format.js { render(:layout => false) }
    end
  end


protected
  
  def load_ssh_key_for(user)
    user.ssh_keys.find(params[:id])
  end

  def load_user()
    User.find(params[:user_id])
  end
end
