class DashboardController < ApplicationController
  def index
    @repositories_owned = current_user.repositories
    @repositories_contributed = []
  end

  def help
  end
end
