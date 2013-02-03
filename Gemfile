source 'https://rubygems.org'

gem 'rake', '~> 10.0.1'
gem 'rails', "~> 3.2.11"
gem 'jquery-rails', "~> 2.1.3"
gem 'omniauth', '~> 1.0.3'
gem 'omniauth-cas', '~> 0.0.6'
gem 'simple_form', '2.0.2'
gem 'ucb_ldap', '2.0.0.pre1'
gem 'execjs'
gem 'fuubar', '~> 1.1.0'
gem 'active_attr'
gem 'strong_parameters'
gem 'warbler'
gem "exception_notification", :require => "exception_notifier"
gem 'debugger' if ENV['DEBUGGER']

platforms :jruby do
  gem "jruby-jars", "~> 1.7.2"
  gem "activerecord-jdbc-adapter"
  gem "activerecord-jdbcpostgresql-adapter"
end

platforms :ruby do
  gem 'pg', '0.14.0'
end

group :test, :development do
  gem 'capybara', '~> 1.1.2'
  gem 'factory_girl', '~> 4.1.0'
  gem 'launchy'
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'database_cleaner'
  gem "capybara-webkit" if ENV['WEBKIT']

  gem 'rspec_junit_formatter'
  gem 'rspec-rails', "~> 2.11.4"
  gem 'thin', :platforms => :ruby
  gem 'quiet_assets'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem "jquery-datatables-rails"
  gem 'uglifier', '1.0.3'
  gem 'bootstrap-sass', '~> 2.2.2.0'
  gem 'sass-rails', '~> 3.2'
  gem 'therubyrhino', :platforms => :jruby
  gem 'therubyracer', :platforms => :ruby
end
