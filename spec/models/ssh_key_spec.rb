require 'spec_helper'
require_relative './ssh_key_validations'


describe SshKey, "validations" do
  include SshKeyValidations

  before(:all) do
    SshKey.delete_all
  end
  
  before(:each) do
    @ssh_key = FactoryGirl.build(:ssh_key, :name => "key1", :key => "key1")
  end
  
  after(:all) do
    FileUtils.rm(AuthorizedKeysFile.new.file_path())
  end

  it_should_behave_like "Valid SshKeys"
end


describe SshKey do
  before(:each) do
    @key_file = AuthorizedKeysFile.new()
    @key_file_path = @key_file.file_path()
  end

  after(:each) do
    FileUtils.rm(AuthorizedKeysFile.new.file_path())
  end

  it "should create the authorized_keys file" do
    user = FactoryGirl.create(:user)
    user.ssh_keys.create!(:name => "key1", :key => "key1")

    FileUtils.rm(@key_file_path) if File.exists?(@key_file_path)
    File.exists?(@key_file_path).should_not be_true

    @key_file.create()
    File.exists?(@key_file_path).should be_true
    File.stat(@key_file.ssh_dir()).mode.to_s(8).should eql("40770")
    File.stat(@key_file_path).mode.to_s(8).should eql("100660")
  end

  it "should write key file" do
    user = FactoryGirl.create(:user)
    ssh_key = user.ssh_keys.create!(:name => "key1", :key => "key1")
    contents, username = ssh_key.key(), ssh_key.username()
    IO.read(@key_file.file_path()).should == @key_file.key_entry(username, contents) + "\n"
  end
end


describe SshKey, "polymorphic methods" do
  after(:all) do
    FileUtils.rm(AuthorizedKeysFile.new.file_path())
  end

  context "username()" do
    it "should return space.deploy_user_name() when parent is Space" do
      space = FactoryGirl.create(:space)
      key = space.deploy_keys.create!(:name => "key1", :key => "key1")
      key.username.should == space.deploy_user_name()
    end

    it "should return user.username() when parent is User" do
      user = FactoryGirl.create(:user)
      key = user.ssh_keys.create!(:name => "key1", :key => "key1")
      key.username.should == user.username()
    end

    it "should return HudsonSshKey.username() when parent is HudsonSshKey" do
      key = HudsonSshKey.new(:name => "key1", :key => "key1")
      key.username.should == HudsonSshKey.username()

      key = SshKey.new(:name => "key1", :key => "key1")
      key.ssh_key_authenticatable_type = "HudsonSshKey"
      key.ssh_key_authenticatable_id = HudsonSshKey.hudson_id()
      key.username.should == HudsonSshKey.username()
    end
  end
end
