class Admin::UsersController < Admin::BaseController
  current_tab(:major, :users)
  current_tab(:minor, :detail, :only => [:edit, :update])
  no_minor_tabs(:except => [:edit, :update])
  
  helper(Admin::UsersHelper)


  def index()
    @users = User.all()
  end

  def new()
    @user = User.new_from_ldap_uid(params[:ldap_uid])
  end

  def edit()
    @user = load_user()
  end
  
  def create()
    @user = User.sudo_new(params[:user])
    @user.terms_and_conditions = true
    @user.save!
    flash[:notice] = msg_created(@user)
    redirect_to(edit_admin_user_url(@user))
  rescue ActiveRecord::RecordInvalid
    render("new")
  end

  def update()
    @user = load_user()
    @user.sudo_attributes = params[:user]
    @user.terms_and_conditions = true
    @user.save!
    if params[:user][:terms_and_conditions] == "0"
      @user.update_attribute(:terms_and_conditions, false)
    end
    flash[:notice] = msg_updated(@user)
    redirect_to(edit_admin_user_url(@user))
  rescue ActiveRecord::RecordInvalid => e
    render("edit")
  end
  
  def destroy()
    @user = load_user()
    if @user.destroy
      flash[:notice] = msg_destroyed(@user)
      redirect_to(admin_users_url())
    else
      # Redirect to avoid "error_count_message_for"
      flash[:error] = @user.errors.full_messages.join(",")
      redirect_to(edit_admin_user_url(@user))
    end
  end

  def login()
    @user = load_user()
    application_login(@user.ldap_uid)
    redirect_to(root_url)
  end
  
  
protected
  
  def load_user()
    User.find(params[:id])
  end
end
