class Admin::UsersController < Admin::BaseController
  before_filter(:find_user, :only => [:edit, :update, :destroy, :login])

  current_tab(:major, :users)
  current_tab(:minor, :detail, :only => [:edit, :update])
  no_minor_tabs(:except => [:edit, :update])

  helper('admin/users')

  def index
    @users = User.all
  end

  def new
    @user = User.new_from_ldap_uid(params[:ldap_uid])
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    @user.terms_and_conditions = true
    @user.save!
    flash[:success] = msg_created(@user)
    redirect_to(edit_admin_user_url(@user))
  rescue ActiveRecord::RecordInvalid
    render("new")
  end

  def update
    user.attributes = user_params
    user.terms_and_conditions = true
    user.save!
    if params[:user][:terms_and_conditions] == "0"
      user.update_attribute(:terms_and_conditions, false)
    end
    flash[:success] = msg_updated(user)
    redirect_to(edit_admin_user_url(user))
  rescue ActiveRecord::RecordInvalid => e
    render("edit")
  end

  def destroy
    if user.destroy
      flash[:success] = msg_destroyed(user)
      redirect_to(admin_users_url)
    else
      flash[:error] = user.errors.full_messages.join(",")
      redirect_to(edit_admin_user_url(user))
    end
  end

  def login
    application_login(user.ldap_uid)
    redirect_to(root_url)
  end

  protected

  def user_params
    params.require(:user).permit!
  end

  def find_user
    @user ||= User.find(params[:id])
  end

  def user
    @user
  end
  helper_method :user

  def users
    @users ||= User.all
  end
  helper_method :users
end
