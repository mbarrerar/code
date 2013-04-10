require 'spec_helper'


describe 'HudsonSshKey class methods' do
  after(:all) { FileUtils.rm(AuthorizedKeysFile.new.file_path) }

  context 'new' do
    it 'should be of type HudsonSshKey' do
      key = HudsonSshKey.new
      key.ssh_key_authenticatable_type.should == 'HudsonSshKey'
      key.ssh_key_authenticatable_id.should == HudsonSshKey.hudson_id
    end
  end

  context 'all' do
    FactoryGirl.create(:hudson_ssh_key)
    FactoryGirl.create(:ssh_key)
    HudsonSshKey.all.length.should == 1
  end

  context 'find_hudson_key(id)' do
    it 'should find only HudsonSshKeys' do
      FactoryGirl.create(:hudson_ssh_key)
      ssh_key = FactoryGirl.create(:ssh_key)
      HudsonSshKey.find_hudson_key(ssh_key.id).should be_nil
    end
  end
end




