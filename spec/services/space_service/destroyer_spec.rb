require 'spec_helper'


describe SpaceService::Destroyer do
  let(:user) { FactoryGirl.create(:user) }
  let(:space) { creator.space }
  let(:creator) { SpaceService::Creator.new(:current_user => user) }
  let(:destroyer) { SpaceService::Destroyer.new(:current_user => user, :space => space) }

  context 'initialize(args)' do
    it 'requires :current_user and :space arguments' do
      expect { SpaceService::Destroyer.new(:current_user => mock, :space => mock) }.to_not raise_error
      expect { SpaceService::Destroyer.new(:current_user => mock) }.to raise_error
      expect { SpaceService::Destroyer.new(:space => mock) }.to raise_error
      expect { SpaceService::Destroyer.new }.to raise_error
    end
  end

  context 'destroy' do
    before(:each) do
      creator.create(:name => 'name')
      destroyer.destroy
    end

    it 'removes space entry from the database' do
      expect(Space.find_by_id(space)).to be_nil
    end

    it 'removes all space_ownership entries from the database' do
      expect(SpaceOwnership.all).to be_empty
    end

    it 'removes space entry from the filesystem' do
      pending
    end

    it 'archives all space repositories on filesystem' do
      pending
    end
  end
end

