require 'spec_helper'


describe RepositoryService::Creator do
  let(:space) { FactoryGirl.create(:space) }
  let(:creator) { RepositoryService::Creator.new(:space => space, :current_user => space.owner) }

  context 'initialize(args)' do
    it 'requires :current_user and :space options' do
      expect { RepositoryService::Creator.new(:space => mock, :current_user => mock) }.to_not raise_error
      expect { RepositoryService::Creator.new(:current_user => mock) }.to raise_error
      expect { RepositoryService::Creator.new(:space => mock) }.to raise_error
    end

  end

  context 'create(repo_name)' do
    it 'creates an entry in the database' do
      creator.create('new_repo')

      expect(space.repositories(true)).to have(1).repository
    end

    it 'creates entries on the filesystem' do
      creator.create('new_repo')
    end

    it 'fails if current_user is not owner or space administrator' do
      random_user = FactoryGirl.create(:user)
      creator = RepositoryService::Creator.new(:space => space, :current_user => random_user)

      expect { creator.create('name') }.to raise_error
    end
  end
end

