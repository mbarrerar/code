require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  unless ENV['DRB']
    require 'simplecov'
    require 'simplecov-rcov'
    SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
    SimpleCov.start "rails" do
      add_filter "app/views"
    end
  end

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'capybara/rspec'
  require 'database_cleaner'
  require 'capybara/webkit'

  Capybara.javascript_driver = :webkit

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  RSpec.configure do |config|
    config.infer_base_class_for_anonymous_controllers = false
    config.include FactoryGirl::Syntax::Methods

    # config.filter_run :focus => true
    # config.run_all_when_everything_filtered = true

    config.before(:each) do
      ActionMailer::Base.deliveries.clear
      DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end
  end


  EMPLOYEE_LDAP_UID = "212386"
  UCB::LDAP::Person.include_test_entries = true

  ##
  # Takes an object that responds to :ldap_uid
  # Or, takes the ldap_uid as a String or Integer.
  #
  def login_user(ldap_obj)
    ldap_uid = if ldap_obj.is_a?(String) || ldap_obj.is_a?(Integer)
                 ldap_obj
               else
                 ldap_obj.ldap_uid
               end

    visit(force_login_path(ldap_uid: ldap_uid))
  end

  def test_file(ext)
    File.join(Rails.root, "spec", "fixtures", "test_file.#{ext.to_s}")
  end

end

Spork.each_run do

  FactoryGirl.reload

  if ENV['DRB']
    require 'simplecov'
    require 'simplecov-rcov'
    SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
    SimpleCov.start "rails" do
      add_filter "app/views"
    end
  end

end

