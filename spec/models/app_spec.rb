require 'spec_helper'


describe App do
  it 'should have template method' do
    App.template.class.should == ActionView::Base
  end

  it 'should return dom_id' do
    App.dom_id(User.new).should == 'new_user'

    user = FactoryGirl.create(:user)
    App.dom_id(user).should == "user_#{user.id}"
    App.dom_id(user, 'foo').should == "foo_user_#{user.id}"
  end

  it 'should have entity name regexp' do
    App::ENTITY_NAME_REGEXP.class.should == Regexp
    'a space'.should_not match(App::ENTITY_NAME_REGEXP)
    'foo@bar'.should_not match(App::ENTITY_NAME_REGEXP)
    'aA112-xx_'.should match(App::ENTITY_NAME_REGEXP)
  end

  it 'should have entity name regexp error message' do
    App::ENTITY_NAME_REGEXP_ERROR_MESSAGE.class.should == String
  end
end
