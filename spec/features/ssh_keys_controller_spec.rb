require 'spec_helper'


describe 'User SSH Keys', :type => :request do
  let(:user) { FactoryGirl.create(:user) }

  before(:each) { login_as(user) }

  context 'List SSH Keys' do
    it "lists a user's ssh keys" do
      user.ssh_keys.create!(:name => 'KEY', :key => 'KEY')

      visit(ssh_keys_path)

      page.save_and_open_page
      page.should have_selector('h1', :text => 'SSH Public Keys')
      page.all('table#ssh_keys tbody tr').should have(1).key
    end
  end

  context 'Add SSH Key' do
    it 'succeeds for valid key' do
      visit(new_ssh_key_path)

      page.should have_selector('h1', :text => 'New SSH Key')

      fill_in('ssh_key[name]', :with => 'name')
      fill_in('ssh_key[key]', :with => 'key')
      click_on('Save')

      page.should have_selector('h1', :text => 'SSH Public Keys')
      page.should have_selector('div.alert-success')
    end

    it 'fails for invalid key' do
      visit(new_ssh_key_path)

      page.should have_selector('h1', :text => 'New SSH Key')

      click_on('Save')

      page.should have_selector('h1', :text => 'New SSH Key')
      page.should have_selector('div.control-group.error')
    end
  end

  context 'Delete SSH Key' do
    it 'deletes the key' do
      key = user.ssh_keys.create!(:name => 'key name', :key => 'key')
      visit(ssh_keys_path)

      selector = "table#ssh_keys tbody tr##{dom_id(key)}"
      page.all(selector).should have(1).key

      click_on('Delete')

      page.all(selector).should have(0).keys
      user.ssh_keys(true).should be_empty
    end
  end
end

