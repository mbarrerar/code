class DashboardController < ApplicationController
  def index
    @repos = Repository.all
  end

  def help
  end
end
