require 'spec_helper'


describe SpaceService::Updater do
  let(:user) { FactoryGirl.create(:user) }
  let(:space_creator) { SpaceService::Creator.new(:current_user => user) }

  context 'initialize(args)' do
    it 'requires :current_user' do
      expect { SpaceService::Creator.new(:current_user => mock) }.to_not raise_error
      expect { SpaceService::Creator.new }.to raise_error
    end
  end

  context 'create(space_params)' do
    let(:space) { space_creator.space }

    it 'creates space entry in the database' do
      space_creator.create(:name => 'space_name', :description => 'space_desc')

      expect(space).to be_persisted
      expect(space.name).to eql('space_name')
      expect(space.description).to eql('space_desc')
    end

    it 'creates space_ownership entry in the database' do
      space_creator.create(:name => 'space_name', :description => 'space_desc')

      expect(space.owners).to have(1).entry
      expect(space.owners.first).to eql(user)
    end

    it 'creates entries on the filesystem' do
      pending
    end
  end
end

