# Allow the metal piece to run in isolation.  NOTE: requests handled by
# metal will not be logged.
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

class AppMonitor
  def self.call(env)
    if env["PATH_INFO"] =~ /^\/app_monitor\/?$/
      return report_status()
    else
      [404, {"Content-Type" => "text/html"}, ["Not Found"]]      
    end
  end

  def self.report_status()
    exercise_stack()
    [200, {"Content-Type" => "text/html"}, ["OK\n"]]
  rescue Exception => e
    [200, {"Content-Type" => "text/html"}, ["FAIL"]]
  end
  
  ##
  # Logic to make sure the basics are working:
  #
  # * db connection
  #
  def self.exercise_stack()
    User.first()
    Repository.first()    
  end
end
