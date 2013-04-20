require 'spec_helper'


describe RepositoryService::Creator do
  let(:space) { FactoryGirl.create(:space) }
  let(:creator) { RepositoryService::Creator.new(:current_user => space.owner) }

  context 'initialize(args)' do
    it 'requires :current_user and :space options' do
      expect { RepositoryService::Creator.new(:current_user => mock) }.to_not raise_error
      expect { RepositoryService::Creator.new }.to raise_error
    end

  end

  context 'create(repo_name)' do
    it 'creates an entry in the database' do
      creator.create(:name => 'new_repo', :space_id => space.id)

      expect(space.repositories(true)).to have(1).repository
    end

    it 'creates entries on the filesystem' do
      creator.create(:name => 'new_repo', :space_id => space.id)

      repo_dir = creator.svn_util.repository_dir(space.name, 'new_repo')
      authz_file = creator.svn_util.repository_authz_file(space.name, 'new_repo')

      expect(File.exists?(repo_dir)).to be_true
      expect(File.exists?(authz_file)).to be_true
      expect(File.readlines(authz_file).length).to eql(5)

      # pp File.readlines(authz_file)
    end

    it 'fails if current_user is not owner or space administrator' do
      random_user = FactoryGirl.create(:user)
      creator = RepositoryService::Creator.new(:current_user => random_user)

      expect { creator.create(:name => 'name', :space_id => space.id) }.to raise_error
    end
  end
end

