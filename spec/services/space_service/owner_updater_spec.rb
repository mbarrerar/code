require 'spec_helper'


describe SpaceService::OwnerUpdater do
  let(:user) { FactoryGirl.create(:user) }
  let(:space) { space_creator.space }
  let(:space_creator) { SpaceService::Creator.new(:current_user => user) }
  let(:owner_updater) { SpaceService::OwnerUpdater.new(:current_user => user, :space => space) }

  context 'initialize(args)' do
    it 'requires :current_user and :space args' do
      expect { SpaceService::OwnerUpdater.new(:current_user => mock, :space => mock) }.to_not raise_error
      expect { SpaceService::OwnerUpdater.new(:current_user => mock) }.to raise_error
      expect { SpaceService::OwnerUpdater.new(:space => mock) }.to raise_error
      expect { SpaceService::OwnerUpdater.new }.to raise_error
    end
  end

  context 'update(owner_ids)' do
    it 'updates the space owners in the database' do
      space_creator.create(:name => 'space_name')
      user1 = FactoryGirl.create(:user)
      owner_updater.update([user1.id])

      expect(space.owners).to have(2).owners
    end

    it 'always keeps the current_user as an owner' do
      space_creator.create(:name => 'space_name')
      owner_updater.update([])

      expect(space.owners).to have(1).owner
    end
  end
end

