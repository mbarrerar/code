class Api::RepositoryStatsController < Api::BaseController
  skip_before_filter :verify_auth_user
  
  ##
  # This method gets called via svn post-commit hook after every commit
  #
  def calc_disk_usage
    @space = Space.find_by_name(params[:space_name])
    @repo = @space.nil? ? nil : @space.repositories.find_by_name(params[:repo_name])

    if @space.nil? || @repo.nil?
      Rails.logger.info("calc_disk_usage failed for unrecognized repo: #{params[:space_name]}/#{params[:repo_name]}")
      render :status => 500, :text => "update failed"
    else
      disk_usage = @repo.calc_disk_usage(:format => true)
      Rails.logger.info("Re-calculated disk usage for #{@space.name}/#{@repo.name}: #{disk_usage}")

      respond_to do |format|
        format.html { render :status => 200, :text => disk_usage }
        format.js { render :status => 200, :text => disk_usage }
      end
    end
  end

end
