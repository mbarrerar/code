source 'https://rubygems.org'


gem 'rake', '~> 10.0.1'
gem 'rails', '~> 3.2.13'
gem 'jquery-rails', '~> 2.1.3'
gem 'omniauth', '~> 1.0.3'
gem 'omniauth-cas', '~> 0.0.6'
gem 'simple_form', '2.0.2'
gem 'ucb_ldap', '2.0.0.pre2'
gem 'execjs'
gem 'fuubar', '~> 1.1.0'
gem 'active_attr'
gem 'strong_parameters'
gem 'warbler'
gem 'jquery-datatables-rails'
gem 'exception_notification', '~> 2.6.1', :require => 'exception_notifier'
gem 'haml'
gem 'angular-gem'
gem 'active_model_serializers'


platforms :jruby do
  gem 'jruby-jars', '~> 1.7.2'
  gem 'activerecord-jdbc-adapter'
  gem 'activerecord-jdbcpostgresql-adapter'
end


platforms :ruby do
  gem 'pg', '0.14.0'
end


group :development do
  gem 'thin', :platforms => :ruby
  gem 'quiet_assets'
end


group :test, :development do
  gem 'rspec-rails', '~> 2.11.4'
end


group :test do
  gem 'capybara', '~> 1.1.2'
  gem 'factory_girl_rails', '~> 4.1.0'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'capybara-webkit' if ENV['WEBKIT']
  gem 'rspec_junit_formatter'
  gem 'simplecov'
  gem 'simplecov-rcov'
end


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'uglifier', '1.0.3'
  gem 'bootstrap-sass', '~> 2.3'
  gem 'sass-rails', '~> 3.2'
  gem 'therubyrhino', :platforms => :jruby
  gem 'therubyracer', :platforms => :ruby
end
