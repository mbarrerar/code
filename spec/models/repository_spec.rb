require 'spec_helper'


describe 'Repository validation' do
  let(:repo) { FactoryGirl.create(:repository) }

  it 'should be valid' do
    repo.should be_valid
  end

  it 'should require a space' do
    repo.space = nil
    repo.should have_at_least(1).error_on(:space_id)
  end

  it 'should require name' do
    repo.name = nil
    repo.should have_at_least(1).error_on(:name)
  end

  it "should only allow letters, numbers, '_' and '-'" do
    repo.name = 'a space'
    repo.should have_at_least(1).error_on(:name)

    repo.name = 'foo@bar'
    repo.should have_at_least(1).error_on(:name)

    repo.name = 'aA112-xx_'
    repo.should be_valid
  end

  it 'should require unique name' do
    repo_new = FactoryGirl.build(:repository, :space => repo.space, :name => repo.name)
    repo_new.should_not be_valid
    repo_new.name = 'unique'
    repo_new.should be_valid
  end

  it 'should allow same repository name in different space' do
    repo.save!
    repo_new = FactoryGirl.build(:repository, :name => repo.name)
    repo_new.should be_valid
  end
end


describe 'Repository class methods' do
  let(:repo) { FactoryGirl.create(:repository) }

  context 'confirmation_required?(repository)' do
    it "should be true if the repository's name changes" do
      Repository.confirmation_required?(repo).should be_false

      repo.name = 'new_name'
      Repository.confirmation_required?(repo).should be_true
    end

    it "should be true if the repository's space changes" do
      new_space = FactoryGirl.create(:space)
      Repository.confirmation_required?(repo).should be_false

      repo.space = new_space
      Repository.confirmation_required?(repo).should be_true
    end
  end
end


describe 'Repository instance methods' do
  let(:repo) { FactoryGirl.create(:repository) }

  it 'should know its url' do
    name = App.svn_username
    host = App.svn_connection_url
    repo.url.should match(/svn\+ssh:\/\/#{name}@#{host}\/name-(\d+)\/name-(\d+)/)
  end

  it 'should have collaborations' do
    steven = FactoryGirl.create(:user, :username => 'steven')
    chris = FactoryGirl.create(:user, :username => 'chris')

    repo.collaborations.create(:permission => Permission::READ, :user => steven, :created_by => repo.owner)
    repo.collaborations.create(:permission => Permission::COMMIT, :user => chris, :created_by => repo.owner)

    repo.collaborators.should have(2).collaborators
    steven = repo.collaborations.find_by_user_id(steven.id)
    steven.permission.should == Permission::READ
    chris = repo.collaborations.find_by_user_id(chris.id)
    chris.permission.should == Permission::COMMIT
  end

  context 'collaborators_available' do
    it "should return all 'active' users that are not administrators for this repository" do
      owner = repo.owner

      repo.collaborators_available.should_not include(owner)

      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)

      repo.collaborators_available.should include(user1)
      repo.collaborators_available.should include(user2)

      user2.update_attribute(:active, false)
      repo.collaborators_available.should_not include(user2)

      user2.update_attribute(:active, true)
      repo.collaborators_available.should include(user2)
      repo.space.administrations.create(:user => user2, :created_by => owner)

      repo.collaborators_available.should_not include(user2)
    end
  end

  context 'authz_entries' do
    it 'should have authz entries for collaborators' do
      user = FactoryGirl.create(:user)
      # Space owner and deploy user automatically get authz entries
      repo.authz_entries.should have(2).entries
      repo.collaborations.create(:user_id => user.id, :permission => 'commit', :created_by => repo.owner)
      repo.authz_entries.should have(3).entries
    end

    it 'should have authz entry for the space deploy user' do
      repo.authz_entries.should have(2).entries
      repo.authz_entries.grep(/#{repo.owner.username()}/).should_not be_empty
      entries = repo.authz_entries.grep(/#{repo.space.deploy_user_name()}/)
      entries.should_not be_empty
    end

    it 'should have authz entries for the space administrators' do
      user = FactoryGirl.create(:user)
      # Space owner and deploy user automatically get authz entries
      repo.authz_entries.should have(2).entries
      repo.space.administrations.create(:user_id => user.id)
      repo.authz_entries.should have(3).entries
    end

    it 'should have authz entries for hudson ci access' do
      # Space owner and deploy user automatically get authz entries
      repo.authz_entries.should have(2).entries
      repo.uses_hudson_ci = true
      repo.authz_entries.should have(3).entries
    end

  end

  context 'write_authz_file' do
    it 'should write the authz file' do
      repo = FactoryGirl.build(:repository)
      repo.uses_hudson_ci = true

      authz_file = "#{repo.svn_dir}/conf/authz"
      File.exists?(authz_file).should be_false
      UcbSvn.create_repository(repo.space_name, repo.name)
      repo.write_authz_file()
      File.exists?(authz_file).should be_true
      contents = File.readlines(authz_file)

      owner_entry = Repository::Authz.entry(repo.owner.username, 'commit')
      deploy_user_entry = Repository::Authz.entry(repo.space.deploy_user_name, 'read')
      hudson_ci_entry = Repository::Authz.entry(HudsonSshKey.username, 'read')
      contents.grep(/#{owner_entry}/).should_not be_empty
      contents.grep(/#{deploy_user_entry}/).should_not be_empty
      contents.grep(/#{hudson_ci_entry}/).should_not be_empty
    end
  end

  context 'update_collaborators_from_params' do
    it 'should remove collaborators flagged for deletion' do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)

      repo.collaborations.create(:user_id => user1.id,
                                 :created_by => repo.owner(),
                                 :permission => Permission::COMMIT)
      repo.collaborations.create(:user_id => user2.id,
                                 :created_by => repo.owner(),
                                 :permission => Permission::COMMIT)

      repo.should have(2).collaborations

      repo.update_collaborators_from_params(repo.owner(),
                                            { user1.id.to_s => "",
                                              user2.id.to_s => "" })
      repo.collaborations(true).find_by_user_id(user1).should be_nil
      repo.collaborations(true).find_by_user_id(user2).should be_nil
    end

    it 'should create edit collaborators' do
      repo = FactoryGirl.create(:repository)
      user1 = FactoryGirl.create(:user)

      repo.should have(0).collaborations

      params = { user1.id.to_s => Permission::COMMIT }
      repo.update_collaborators_from_params(repo.owner(), params)
      repo.collaborations(true).find_by_user_id(user1).should_not be_nil
      repo.should have(1).collaborations
    end

    it 'should not modify collaborators absent collaborators' do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)

      repo.collaborations
          .create(:user_id => user1.id,
                  :created_by => repo.owner,
                  :permission => Permission::COMMIT)

      collab = repo.collaborations
                   .create(:user_id => user2.id,
                           :created_by => repo.owner,
                           :permission => Permission::COMMIT)

      repo.should have(2).collaborations

      params = { user1.id.to_s => "" }
      repo.update_collaborators_from_params(repo.owner(), params)
      repo.collaborations(true).find_by_user_id(user2).should_not be_nil
      collab.should_not_receive(:save)
      repo.should have(1).collaborations
    end

    it 'should not modify collaborators with unchanged permissions' do
      user1 = FactoryGirl.create(:user)

      collab = repo.collaborations
                   .create(:user_id => user1.id,
                           :created_by => repo.owner,
                           :permission => Permission::COMMIT)

      repo.should have(1).collaborations

      params = { user1.id.to_s => Permission::COMMIT }
      collab.should_not_receive(:save)
      repo.update_collaborators_from_params(repo.owner(), params)
      repo.should have(1).collaborations
    end

    it 'should modify collaborators with changed permissions' do
      user1 = FactoryGirl.create(:user)

      repo.collaborations
          .create(:user_id => user1.id,
                  :created_by => repo.owner,
                  :permission => Permission::COMMIT)

      repo.should have(1).collaborations

      params = { user1.id.to_s => Permission::READ }
      repo.update_collaborators_from_params(repo.owner(), params)

      repo.should have(1).collaborations
      new_collab = repo.collaborations.first()
      new_collab.user.should == user1
      new_collab.permission.should == Permission::READ
    end

  end
end


describe 'Repository life cycle callbacks' do
  context 'after_create' do
    it 'should create the repository' do
      repo = FactoryGirl.build(:repository)
      space_name = repo.space.name()
      repo_name = repo.name()
      UcbSvn.should_receive(:create_repository).with(space_name, repo_name)
      repo.should_receive(:write_authz_file)
      repo.save()
    end
  end

  context 'after_update' do
    it 'should move the repository within the space if its name has changed' do
      repo = FactoryGirl.create(:repository)
      dir = repo.svn_dir()
      File.exists?(dir).should be_true

      repo.name = 'new_name'
      repo.save!

      File.exists?(dir).should be_false
      repo.svn_dir.should_not == dir
      File.exists?(repo.svn_dir)
    end

    it 'should move the repository to a new space if its space has changed' do
      repo = FactoryGirl.create(:repository)
      dir = repo.svn_dir
      File.exists?(dir).should be_true

      repo.space = FactoryGirl.create(:space)
      repo.save!

      # make sure deploy user is updated
      authz_file = UcbSvn.repository_authz_file(repo.space.name, repo.name)
      authz_file_entries = File.readlines(authz_file).map(&:strip)

      authz_file_entries.shift(1)
      authz_file_entries.map(&:strip).should == repo.authz_entries

      File.exists?(dir).should be_false
      repo.svn_dir.should_not == dir
      File.exists?(repo.svn_dir)
    end

    it 'should should update the post_commit_hook file' do
      repo = FactoryGirl.create(:repository)

      repo.should_receive(:update_post_commit_hook_file).once
      repo.name = 'new_name'
      repo.save!

      repo.should_receive(:update_post_commit_hook_file).once
      repo.space = FactoryGirl.create(:space)
      repo.save!
    end

    it 'should should remove new owner from collaborators on space change' do
      repo = FactoryGirl.create(:repository)
      new_space = FactoryGirl.create(:space)

      repo.collaborations
          .create(:user => new_space.owner,
                  :created_by => repo.owner,
                  :permission => Permission::READ)

      repo.collaborators(true).should include(new_space.owner())
      repo.space = new_space
      repo.save!

      repo.collaborators(true).should_not include(new_space.owner())
    end
  end

  context 'after_destroy' do
    it 'should archive the repository' do
      repo = FactoryGirl.create(:repository)
      File.exists?(repo.svn_dir()).should be_true
      repo.destroy()

      repo_archive = "#{AppConfig.archive_dir}/#{repo.space.name()}_#{repo.name}_#{UcbSvn.archive_timestamp()}"
      File.exists?(repo_archive)
      File.exists?(repo.svn_dir()).should be_false
    end
  end
end


describe Repository::Authz do
  it 'should lookup permissions' do
    Repository::Authz[:commit].should == "rw"
    Repository::Authz[:read].should == "r"
    lambda { Repository::Authz[:bad_perm] }.should raise_error
  end

  it 'should return permission strings' do
    Repository::Authz.entry('runner', 'commit').should == 'runner = rw'
    Repository::Authz.entry('runner', 'read').should == 'runner = r'
    lambda { Repository::Authz.entry('runner', 'bad_perm') }.should raise_error
  end
end
