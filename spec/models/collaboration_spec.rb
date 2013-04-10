require 'spec_helper'


describe 'Collaboration validation' do
  before(:each) do
    @collab = FactoryGirl.create(:collaboration)
  end
  
  
  it 'should be valid' do
    @collab.should be_valid
  end
  
  it 'should require a repository' do
    @collab.repository_id = nil
    @collab.should have_at_least(1).error_on(:repository_id)
  end
  
  it 'should require a user' do
    @collab.user = nil
    @collab.should have_at_least(1).error_on(:user_id)
  end
  
  it 'should require a permission' do
    @collab.permission = nil
    @collab.should have_at_least(1).error_on(:permission)
  end

  it 'should require the permission to be \'commit\' or \'read\'' do
    @collab.permission = 'hat'
    @collab.should have_at_least(1).error_on(:permission)

    @collab.permission = Permission::COMMIT
    @collab.should have_at_least(0).error_on(:permission)

    @collab.permission = Permission::READ
    @collab.should have_at_least(0).error_on(:permission)
  end

  it 'should require a created_by user' do
    @collab.created_by_id = nil
    @collab.should have_at_least(1).error_on(:created_by_id)
  end

  it 'should not allow space administrators to be added as collaborators' do
    collab = FactoryGirl.build(:collaboration)
    space = collab.repository.space()

    collab.user_id = space.owner.id
    collab.should have_at_least(1).error_on(:user_id)
  end

  it 'should require an active user' do
    @collab.user.update_attribute(:active, false)
    @collab.should have_at_least(1).error_on(:user_id)
  end
end


describe 'Collaboration instance methods' do
  context 'repository_authz_entry()' do
    it 'should return the contents for the repository authz file' do
      steven = FactoryGirl.create(:user, :username => 'steven')
      collaboration = Collaboration.new(:permission => Permission::COMMIT, :user => steven)
      collaboration.repository_authz_entry.should == 'steven = rw'
    end
  end

  context 'write_repository_authz_file' do
    it 'should write all permissions to the repository authz file' do
      collaboration = FactoryGirl.create(:collaboration)
      collaboration.repository.should_receive(:write_authz_file).once
      collaboration.write_repository_authz_file()
    end
  end

  it 'should know if it is a commit permission' do
    collab = FactoryGirl.create(:collaboration, :permission => Permission::COMMIT)
    collab.commit?.should be_true
  end

  it 'should know if it is a read permission' do
    collab = FactoryGirl.create(:collaboration, :permission => Permission::READ)
    collab.read?.should be_true
  end
end

