class ProfilesController < ApplicationController

  def edit
  end

  def update
    if user.update_attributes(user_params)
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
