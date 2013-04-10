require 'spec_helper'


describe 'A Valid User' do
  let(:user) { FactoryGirl.build(:user) }

  it 'is valid' do
    expect(user).to be_valid
  end

  it 'requires ldap_uid' do
    user.ldap_uid = nil
    expect(user).to have_at_least(1).error_on(:ldap_uid)
  end

  it 'requires username' do
    user.username = nil
    expect(user).to have_at_least(1).error_on(:username)
  end

  it 'requires full_name' do
    user.full_name = nil
    expect(user).to have_at_least(1).error_on(:full_name)
  end

  it 'requires correctly formatted email' do
    user.email = 'xxx'
    expect(user).to have_at_least(1).error_on(:email)
  end
end


describe 'class methods' do
  context 'named_scope, User.active' do
    it 'should only return users that are active' do
      user1 = FactoryGirl.create(:user)

      user2 = FactoryGirl.create(:user)
      user2.update_attribute(:active, false)

      User.active.should have(1).record
      User.active.should include(user1)
      User.active.should_not include(user2)
    end
  end

  context "User.deactivate(user)" do
    it "should flag them as inactive and deprovision them" do
      user = FactoryGirl.create(:user)
      user.active?.should be_true

      #User.should_receive(:deprovision).once
      User.deactivate(user)
      user.active?.should be_false
    end
  end
end


describe "life cycle callbacks" do
  context "before_destroy()" do
    it "should prevent deletion if user is a collaborator, via => ensure_not_collaborator()" do
      collaborator = FactoryGirl.create(:user)
      repo = FactoryGirl.create(:repository)
      repo.collaborations.create(:permission => Permission::COMMIT, :user => collaborator, :created_by => repo.owner())

      collaborator.destroy.should be_false
      User.find(collaborator).should be_true

      # Now we can destroy :-)
      repo.collaborations.find_by_user_id(collaborator).destroy
      collaborator.destroy.should be_true
      lambda { User.find(collaborator) }.should raise_error
    end

    it "should prevent deletion if user owns a space, via => ensure_not_space_owner()" do
      space = FactoryGirl.create(:space, :owner => FactoryGirl.create(:user))
      owner = space.owner()

      owner.destroy.should be_false
      User.find(owner).should be_true

      # Now we can destroy :-)
      space.destroy
      owner.destroy.should be_true
      lambda { User.find(owner) }.should raise_error
    end

    it "should prevent deletion if user administers a space, via => ensure_not_space_administrator()" do
      space = FactoryGirl.create(:space)
      space_admin = FactoryGirl.create(:user)
      space.administrations.create(:user => space_admin)

      space_admin.destroy.should be_false
      User.find(space_admin).should be_true

      # Now we can destroy :-)
      space.administrations.find_by_user_id(space_admin).destroy
      space_admin.destroy.should be_true
      lambda { User.find(space_admin) }.should raise_error
    end
  end

  context "after_update()" do
    # how to test observers?
    it "should deprovision the user if they become inactive" #do
    #  User.should_receive(:deprovision)
    #  user = FactoryGirl.create(:user)
    #  user.active = false
    #  user.save
    #end
  end
end
