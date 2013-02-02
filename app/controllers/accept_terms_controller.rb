class AcceptTermsController < ApplicationController
  before_filter(:set_user)
  skip_before_filter(:filter_accepted_terms?)
  
  def edit()
  end

  def update()
    @user.email = params[:user][:email]
    @user.terms_and_conditions = true
    
    if @user.save()
      AppAdminMailer.deliver_new_user_notification(@user)
      redirect_to(dashboard_url)
    else
      render('edit')
    end
  end
  
end
