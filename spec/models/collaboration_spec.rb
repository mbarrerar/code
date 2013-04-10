require 'spec_helper'


describe 'Collaboration validation' do
  let(:collaboration) { FactoryGirl.create(:collaboration) }

  it 'should be valid' do
    collaboration.should be_valid
  end
  
  it 'should require a repository' do
    collaboration.repository_id = nil
    collaboration.should have_at_least(1).error_on(:repository_id)
  end
  
  it 'should require a user' do
    collaboration.user = nil
    collaboration.should have_at_least(1).error_on(:user_id)
  end
  
  it 'should require a permission' do
    collaboration.permission = nil
    collaboration.should have_at_least(1).error_on(:permission)
  end

  it 'should require the permission to be \'commit\' or \'read\'' do
    collaboration.permission = 'hat'
    collaboration.should have_at_least(1).error_on(:permission)

    collaboration.permission = Permission::COMMIT
    collaboration.should have_at_least(0).error_on(:permission)

    collaboration.permission = Permission::READ
    collaboration.should have_at_least(0).error_on(:permission)
  end

  it 'should require a created_by user' do
    collaboration.created_by_id = nil
    collaboration.should have_at_least(1).error_on(:created_by_id)
  end

  it 'should require an active user' do
    collaboration.user.update_attribute(:active, false)
    collaboration.should have_at_least(1).error_on(:user_id)
  end
end


describe 'Collaboration instance methods' do
  context 'repository_authz_entry' do
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
    collaboration = FactoryGirl.create(:collaboration, :permission => Permission::COMMIT)
    collaboration.commit?.should be_true
  end

  it 'should know if it is a read permission' do
    collaboration = FactoryGirl.create(:collaboration, :permission => Permission::READ)
    collaboration.read?.should be_true
  end
end

