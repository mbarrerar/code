class ProfilesController < ApplicationController
  current_tab(:major, :profile)

  def edit
  end

  def update
    if current_user.update_attributes(user_params)
      redirect_to(edit_profile_url, :flash => { success: msg_updated('Profile') })
    else
      render('edit')
    end
  end


  protected

  def user_params
    params.require(:user).permit(:email, :bio)
  end

end
