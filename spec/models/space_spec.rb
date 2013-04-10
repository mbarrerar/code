require 'spec_helper'


describe 'Space Validation' do
  let(:space) { FactoryGirl.build(:space) }

  it 'should be valid' do
    space.should be_valid
  end

  it 'should require name' do
    space.name = nil
    space.should have_at_least(1).error_on(:name)
  end

  it "should restrict the name to letters, numbers, '_' and '-'" do
    space.name = "a space"
    space.should have_at_least(1).error_on(:name)

    space.name = "foo@bar"
    space.should have_at_least(1).error_on(:name)

    space.name = "aA112-xx_"
    space.should be_valid
  end

  it "should require unique name" do
    space.save!
    space_2 = FactoryGirl.build(:space, :name => space.name)
    space_2.should_not be_valid
    space_2.name = 'unique'
    space_2.should be_valid
  end

  it "should require owner" do
    space.owner = nil
    space.should have_at_least(1).error_on(:owner_id)
  end
end


describe "instance methods" do
  context "write_repositories_authz_files" do
    it "should update the authz file for each repository in the space" do
      space = FactoryGirl.create(:space)
      repo1 = FactoryGirl.create(:repository, :space => space)
      repo2 = FactoryGirl.create(:repository, :space => space)

      space.stub!(:repositories).and_return([repo1, repo2])
      repo1.should_receive(:write_authz_file).once
      repo2.should_receive(:write_authz_file).once

      space.write_repositories_authz_files
    end
  end

  context "administrators_available(excluded_users)" do
    it "should return all 'active' users that are not the space owner" do
      space = FactoryGirl.create(:space)
      owner = space.owner

      space.administrators_available([]).should_not include(owner)

      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)

      space.administrators_available.should include(user1)
      space.administrators_available.should include(user2)

      user2.update_attribute(:active, false)
      space.administrators_available.should_not include(user2)

      user2.update_attribute(:active, true)
      space.administrators_available.should include(user2)
      space.administrations.create(:user => user2, :created_by => owner)

      space.administrators_available.should include(user2)
    end

    it "should exclude specified users" do
      space = FactoryGirl.create(:space)

      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)

      space.administrators_available.should include(user1)
      space.administrators_available.should include(user2)

      space.administrators_available([user1]).should include(user2)
      space.administrators_available([user1]).should_not include(user1)
      space.administrators_available([user1, user2]).should be_empty
    end

  end

  context "update_administrators_from_params(creator, params)" do
    it "should require a creator" do
      space = FactoryGirl.create(:space)
      lambda { space.update_administrators_from_params(nil, {}) }.should raise_error
      lambda { space.update_administrators_from_params(User.new, {}) }.should_not raise_error
    end

    it "should remove administrators flagged for deletion" do
      space = FactoryGirl.create(:space)
      creator = space.owner
      admin1 = FactoryGirl.create(:user)
      admin2 = FactoryGirl.create(:user)

      space.administrations.create(:user_id => admin1.id)
      space.administrations.create(:user_id => admin2.id)

      # space owner gets added as administrator
      space.should have(3).administrations

      params = { admin1.id.to_s => "", admin2.id.to_s => "" }
      space.update_administrators_from_params(creator, params)
      space.administrations(true).find_by_user_id(admin1).should be_nil
      space.administrations(true).find_by_user_id(admin2).should be_nil
      space.administrations(true).should have(1).administration
    end

    it "should create edit administrators" do
      space = FactoryGirl.create(:space)
      creator = space.owner
      admin1 = FactoryGirl.create(:user)

      # space owner gets added as administrator
      space.should have(1).administrations

      params = { admin1.id.to_s => "admin" }
      space.update_administrators_from_params(creator, params)
      space.administrations(true).find_by_user_id(admin1).should_not be_nil
      space.administrations(true).should have(2).administration
    end

    it "should not modify unspecified administrators" do
      space = FactoryGirl.create(:space)
      creator = space.owner
      admin1 = FactoryGirl.create(:user)
      admin2 = FactoryGirl.create(:user)

      space.administrations.create(:user_id => admin1.id)
      space.administrations.create(:user_id => admin2.id)

      # space owner gets added as administrator
      space.should have(3).administrations

      params = { admin1.id.to_s => "" }
      space.update_administrators_from_params(creator, params)
      space.administrations(true).find_by_user_id(admin2).should_not be_nil
      space.administrations(true).should have(2).administration
    end

    it "should write out permissions to all space repos" do
      space = FactoryGirl.create(:space)
      creator = space.owner

      space.respond_to?(:write_repositories_authz_files).should be_true
      space.should_receive(:write_repositories_authz_files).once
      space.update_administrators_from_params(creator, {})
    end
  end
end


describe "class methods" do
  context "administrator?(space, user)" do
    it "should know if the user is an administrator of the space" do
      space = FactoryGirl.create(:space)
      user1 = FactoryGirl.create(:user)

      Space.administrator?(space, user1).should be_false

      space.administrations.create(:user_id => user1.id)
      Space.administrator?(space, user1).should be_true
    end
  end
end


describe "Space life cycle callbacks" do
  def authz_file_contents(space_name, repo_name)
    authz_file = UcbSvn.repository_authz_file(space_name, repo_name)
    File.readlines(authz_file)
  end


  context "after_create" do
    it "should create space directory" do
      space = FactoryGirl.build(:space)
      UcbSvn.should_receive(:create_space).once.with(space.name)
      space.save!
    end

    it "should add owner as administrator" do
      owner = FactoryGirl.create(:user)
      space = FactoryGirl.create(:space, :owner => owner)
      space.administrators.should include(owner)
    end
  end

  context "after_update" do
    it "should do nothing if nothing changes" do
      space = FactoryGirl.create(:space)
      space.should_not_receive(:write_repositories_authz_files)
      space.save!
    end

    it "should rename space directory" do
      space = FactoryGirl.create(:space)
      UcbSvn.should_receive(:rename_space).once.with(space.name, "new_name")
      space.name = "new_name"
      space.save!
    end

    it "should make the edit owner an administrator if owner changes" do
      old_owner = FactoryGirl.create(:user)
      new_owner = FactoryGirl.create(:user)
      space = FactoryGirl.create(:space, :owner => old_owner)

      space.owner = new_owner
      space.save

      space.administrators(true).should_not include(old_owner)
      space.administrators(true).should include(new_owner)
    end

    it "should update the authz file for all of its repos if owner changes" do
      space = FactoryGirl.create(:space)
      owner = space.owner
      new_owner = FactoryGirl.create(:user, :username => "new_owner")

      repo1 = FactoryGirl.create(:repository, :space => space)
      repo2 = FactoryGirl.create(:repository, :space => space)

      repo1_entries = authz_file_contents(space.name, repo1.name)
      repo1_entries.grep(/#{new_owner.username}/).should == []

      repo2_entries = authz_file_contents(space.name, repo2.name)
      repo2_entries.grep(/#{new_owner.username}/).should == []

      space.owner = new_owner
      space.save

      space.administrators(true).should_not include(owner)
      space.administrators(true).should include(new_owner)

      repo1_entries = authz_file_contents(space.name, repo1.name)
      repo1_entries.grep(/#{new_owner.username}/).should_not == []

      repo2_entries = authz_file_contents(space.name, repo2.name)
      repo2_entries.grep(/#{new_owner.username}/).should_not == []
    end

    it "should update the deploy user in the authz file for its repositories if name changes" do
      space = FactoryGirl.create(:space)

      repo1 = FactoryGirl.create(:repository, :space => space)
      repo2 = FactoryGirl.create(:repository, :space => space)

      deploy_user = space.deploy_user_name

      repo1_entries = authz_file_contents(space.name, repo1.name)
      repo1_entries.grep(/#{deploy_user}/).should_not be_empty

      repo2_entries = authz_file_contents(space.name, repo2.name)
      repo2_entries.grep(/#{deploy_user}/).should_not be_empty

      space.name = "foo"
      space.save

      new_deploy_user = space.deploy_user_name
      new_deploy_user.should_not == deploy_user

      repo1_entries = authz_file_contents(space.name, repo1.name)
      repo1_entries.grep(/#{deploy_user}/).should be_empty
      repo1_entries.grep(/#{new_deploy_user}/).should_not be_empty

      repo2_entries = authz_file_contents(space.name, repo2.name)
      repo2_entries.grep(/#{deploy_user}/).should be_empty
      repo2_entries.grep(/#{new_deploy_user}/).should_not be_empty
    end

    it "should update all of its deploy key entries in authorized_keys file if name changes" do
      space = FactoryGirl.create(:space)
      space.authorized_keys_file.should_receive(:write)
      space.name = "foo"
      space.save!
    end
  end

  context 'before_destroy' do
    it 'should not allow the space to be destroyed if it contains repositories' do
      space = FactoryGirl.create(:space)
      repo = FactoryGirl.create(:repository, :space => space)

      space.should have(1).repository
      space.destroy
      space.should_not be_destroyed

      repo.destroy
      space.repositories(true).should be_empty

      # now we can destroy :-)
      space.destroy.should be_true
      lambda { Space.find(space) }.should raise_error
    end
  end

  context 'after_destroy' do
    it 'should remove space directory' do
      space = FactoryGirl.create(:space)
      UcbSvn.should_receive(:delete_space).once.with(space.name)
      space.destroy
    end

    it 'should remove all of its deploy keys from the db' do
      space = FactoryGirl.create(:space)
      key1 = space.deploy_keys.create(:name => "1", :key => "1")
      key2 = space.deploy_keys.create(:name => "2", :key => "2")
      space.should have(2).deploy_keys

      space.destroy
      lambda { SshKey.find(key1.id) }.should raise_error
      lambda { SshKey.find(key2.id) }.should raise_error
    end

    it 'should remove all of its deploy keys from authorized_keys file' do
      space = FactoryGirl.create(:space)
      space.authorized_keys_file.should_receive(:write)
      space.destroy
    end
  end
end


