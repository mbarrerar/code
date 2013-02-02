class Api::UserStatsController < Api::BaseController

  def update_last_svn_access
    user = User.find_by_username(params[:username])
    if user
      user.last_svn_access = Time.now()
      user.save!
      render(:text => "User svn access date updated: #{user.last_svn_access()}", :status => 200)
    else
      render(:text => "Not Found", :status => 404)
    end
  end


end