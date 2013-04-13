require 'spec_helper'


describe 'User Profile', :type => :request do
  let(:user) { FactoryGirl.create(:user) }

  before(:each) { login_as(user) }

  context 'Update profile' do
    it 'succeeds for valid profile' do
      visit(edit_profile_path)

      click_on('Save')

      page.should have_selector('h1', :text => 'Edit Profile')
      page.should have_selector('div.alert-success')
    end

    it 'fails for invalid profile' do
      visit(edit_profile_path)

      fill_in('user[email]', :with => '')
      click_on('Save')

      page.should have_selector('h1', :text => 'Edit Profile')
      page.should have_selector('div.control-group.error')
    end
  end
end

