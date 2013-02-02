class ApplicationController < ActionController::Base
  include UcbAuthentication
  include CrudMessage

  before_filter :ensure_authenticated, :except => [:logout, :force_exception]
  before_filter :ensure_authorized, :except => [:logout, :force_exception]
  # before_filter :record_last_access, :except => [:logout, :force_exception, :unknown_route]


  protect_from_forgery

  def force_exception
    raise 'Testing, 1 2 3.'
  end

  def msg(string_path)
    App.msg(string_path)
  end

  def error(string_path)
    App.error(string_path)
  end

  #def filter_accepted_terms?
  #  unless current_user.accepted_terms?
  #    flash[:warning] = <<-warn_msg
  #      You must accept terms and conditions before using Code@Berkeley.
  #    warn_msg
  #    redirect_to(accept_terms_url)
  #  end
  #end

  ##
  # Suppresses display of minor_tabs_html.  Supports before_filter
  # options (:only, :except, etc.)
  #
  #   class MyController < ApplicationController
  #     no_minor_tabs :only => [:index]
  #
  #     # ...
  #   end
  def self.no_minor_tabs(*args)
    options = args.extract_options!

    before_filter(options) do |controller|
      controller.send(:no_minor_tabs)
    end
  end

  ##
  # Called by self.no_minor_tabs to set flag (@no_minor_tabs) to suppress minor
  # tabs in ApplicationHelper#minor_tabs_html
  def no_minor_tabs
    @no_minor_tabs = true
  end

  def destroy_notification(record, name = nil)
    if record.frozen?
      flash[:notice] = msg_destroyed(name || record)
    else
      flash[:error] = record.errors.full_messages
    end
  end
end
