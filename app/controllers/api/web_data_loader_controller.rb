class Api::WebDataLoaderController < Api::BaseController

  def load_repositories()
    Loader::Repo2.build_web_data_for_repo()
    render(:text => "Load completed for webapps", :status => 200)
  rescue RuntimeError => e
    render(:text => e.message(), :status => :unprocessable_entity)
  end

  def purge_repositories()
    space = Space.find_by_name("istas")
    space.repositories.each(&:destroy)
    render(:text => "Purge completed for webapps", :status => 200)
  rescue RuntimeError => e
    render(:text => e.message(), :status => :unprocessable_entity)
  end

end