class Api::RepositoriesController < ApplicationController
  respond_to :json

  def index
    respond_with(Repository.all, :root => false)
  end

end
