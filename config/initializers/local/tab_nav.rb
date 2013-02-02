require File.join(Rails.root, 'lib', 'tab_nav', 'lib', 'tab_nav')
# make sure to manually require tab_nav:
# http://www.williambharding.com/blog/technology/rails-3-autoload-modules-and-classes-in-production/
ActionController::Base.send(:include, TabNav::ControllerMethods)