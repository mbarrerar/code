require 'spec_helper'


describe SpaceAdministration do
  let(:admin) { FactoryGirl.build(:space_administration) }

  it 'should be valid' do
    admin.should be_valid
  end

  it 'should require a space' do
    admin.space = nil
    admin.should have_at_least(1).error_on(:space_id)
  end

  it 'should require a user' do
    admin.user = nil
    admin.should have_at_least(1).error_on(:user_id)
  end

  it 'should require an active user' do
    admin.user.update_attribute(:active, false)
    admin.should have_at_least(1).error_on(:user_id)
  end
end


describe 'SpaceAdministration instance methods' do
  def svn_service
    UcbSvn
  end


  context 'write_repositories_authz_files' do
    it 'should update the authz file for all repos in the space' do
      steven = FactoryGirl.create(:user, :username => 'runner')
      space = FactoryGirl.create(:space)

      repo1 = FactoryGirl.create(:repository, :space => space)
      repo2 = FactoryGirl.create(:repository, :space => space)

      space.administrators.should_not include(steven)
      admin = space.administrations.build(:user => steven)
      admin.save
      space.administrators(true).should include(steven)

      repo1_authz = svn_service.repository_authz_file(space.name(), repo1.name())
      repo1_entries = File.readlines(repo1_authz)
      repo1_entries.grep(/#{steven.username}/).should == []

      repo2_authz = svn_service.repository_authz_file(space.name(), repo2.name())
      repo2_entries = File.readlines(repo2_authz)
      repo2_entries.grep(/#{steven.username}/).should == []

      admin.write_repositories_authz_files()

      repo1_entries = File.readlines(repo1_authz)
      repo1_entries.grep(/#{steven.username}/).should_not == []

      repo2_entries = File.readlines(repo2_authz)
      repo2_entries.grep(/#{steven.username}/).should_not == []
    end
  end
end


describe "SpaceAdministration life cycle callbacks" do
  context "before_destroy" do
    it "should not allow the space owner to be removed as an administrator" do
      space = FactoryGirl.create(:space)
      owner = space.owner()

      space.administrators.should include(owner)
      owner_admin = space.administrations.find_by_user_id(owner.id)
      owner_admin.destroy.should be_false
      space.administrations.find_by_user_id(owner.id).should == owner_admin
      owner_admin.should have(1).errors
    end

    it "should allow non-space owners to be removed as an administrator" do
      space = FactoryGirl.create(:space)
      admin = FactoryGirl.create(:user)

      space.administrations.should have(1).administration
      space_admin = space.administrations.build({:user_id => admin.id})

      space_admin.save!
      space.administrations(true).should have(2).administrations
      space.administrators.should include(admin)

      space_admin.destroy.should be_true
      space.administrations.find_by_user_id(admin.id).should be_nil
      space.administrations(true).should have(1).administration
    end
  end
end
