require 'spec_helper'


describe SpaceService::Updater do
  let(:user) { FactoryGirl.create(:user) }
  let(:space_creator) { SpaceService::Creator.new(:current_user => user) }

  context 'initialize(args)' do
    it 'requires :current_user' do
      pending
      #expect { SpaceService::Creator.new(:current_user => mock) }.to_not raise_error
      #expect { SpaceService::Creator.new }.to raise_error
    end
  end

  context 'update(space_params)' do
    # let(:space) { space_creator.space }

    it 'updates the database' do
      pending
    end

    it 'notifies owners and collaborators of the connection url change' do
      pending
      #space_creator.create(:name => 'space_name', :description => 'space_desc')
      #
      #expect(space.owners).to have(1).entry
      #expect(space.owners.first).to eql(user)
    end

    it 'updates the filesystem' do
      pending
    end
  end
end

