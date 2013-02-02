class ProfilesController < ApplicationController

  def edit
  end

  def update
    user.email = params[:user][:email]
    
    if user.save
      flash[:notice] = msg_updated("Profile")
      redirect_to(edit_profile_url)
    else
      render('edit')
    end
  end

  protected

  def user
    @user ||= current_user
  end

  helper_method :user
end
