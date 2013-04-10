require 'spec_helper'


describe RepositoryUrlChangedMessage do

  context 'RepositoryUrlChangedMessage.new_from_space_params(updated_by, params)' do
    it 'should return an array of message objects' do
      updated_by = FactoryGirl.build(:user)
      space = FactoryGirl.create(:space)
      repo1 = space.repositories.build(:name => 'repo1')
      repo1.stub!(:id).and_return(1)
      repo2 = space.repositories.build(:name => 'repo2')
      repo2.stub!(:id).and_return(2)
      
      RepositoryUrlChangedMessage.stub!(:find_space).and_return(space)
      
      params = {
        :id => space.id,
        :message => 'message',
        :url_was => {
          repo1.id.to_s => repo1.url,
          repo2.id.to_s => repo2.url
        }
      }

      messages = RepositoryUrlChangedMessage.
        new_from_space_params(updated_by, params)
      messages.should have(2).messages

      msg1 = messages.first
      msg1.url_was.should == repo1.url
      msg1.message.should == 'message'
      msg1.repository.should == repo1
      msg1.updated_by = updated_by
      
      msg2 = messages.last
      msg2.url_was.should == repo2.url
      msg2.message.should == 'message'
      msg2.repository.should == repo2
      msg2.updated_by = updated_by      
    end
  end

  context 'RepositoryUrlChangedMessage.new_from_repository_params(updated_by, params)' do
    it 'should return a single message object' do
      updated_by = FactoryGirl.build(:user)
      repo = FactoryGirl.create(:repository)

      params = {
          :id => repo.id,
          :message => 'message',
          :url_was => repo.name
      }

      msg = RepositoryUrlChangedMessage.new_from_repository_params(updated_by, params)
      msg.instance_of?(RepositoryUrlChangedMessage).should be_true
      msg.message = 'message'
      msg.repository.should == repo
      msg.url_was.should == repo.name
      msg.updated_by.should == updated_by
    end
  end

  context 'collaborator_emails' do
    it 'should generate a list of collaborator emails' do
      updated_by = FactoryGirl.build(:user)
      repo = FactoryGirl.create(:repository)

      msg = RepositoryUrlChangedMessage.new.tap do |obj|
        obj.url_was = 'old url'
        obj.message = 'hi'
        obj.updated_by = updated_by
        obj.repository = repo
      end

      owner = repo.owner

      # only the administrator/owner of the repository
      msg.collaborator_emails.should include(owner.email)
      msg.collaborator_emails.length.should == 1

      collaborator = FactoryGirl.create(:user)

      repo.collaborations
          .create(:created_by => owner,
                  :user => collaborator,
                  :permission => Permission::COMMIT)

      msg.collaborator_emails.should include(collaborator.email)
      msg.collaborator_emails.length.should == 2
    end
  end
end
