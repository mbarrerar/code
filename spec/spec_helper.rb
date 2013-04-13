ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
require 'database_cleaner'
require 'capybara/webkit'
require 'simplecov'
require 'simplecov-rcov'


#SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
#SimpleCov.start 'rails' do
#  add_filter 'app/views'
#end


Capybara.javascript_driver = :webkit

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |file| require file }


RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false
  config.include FactoryGirl::Syntax::Methods
  config.include LoginHelper

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

  config.after(:all) do
    UcbSvnCleanupHelper.remove_all
  end
end


