require 'spec_helper'


describe SshKeyService::Creator do
  let(:current_user) { FactoryGirl.create(:user) }
  let(:key_owner) { FactoryGirl.create(:user) }
  let(:key_writer) { mock('KeyWriter', :write => true) }
  let(:audit_logger) { mock('AuditLogger', :log => true) }

  let(:key_creator) {
    SshKeyService::Creator.new(
        :key_owner => key_owner,
        :current_user => current_user,
        :key_writer => key_writer,
        :audit_logger => audit_logger
    )
  }

  context 'initialize(args)' do
    it 'requires :user' do
      expect { SshKeyService::Creator.new(:current_user => mock, :key_owner => mock) }.to_not raise_error
      expect { SshKeyService::Creator.new(:current_user => mock) }.to raise_error
      expect { SshKeyService::Creator.new(:key_owner => mock) }.to raise_error
      expect { SshKeyService::Creator.new }.to raise_error
    end
  end

  context 'create(key_params)' do
    it 'saves the keys to db' do
      key_owner.should have(0).ssh_keys
      key_creator.create(:name => 'name', :key => 'key contents')
      key_owner.should have(1).ssh_keys
    end

    it 'writes the key to the ssh authorized_keys file' do
      key_writer.should_receive(:write)
      key_creator.create(:name => 'name', :key => 'key contents')
    end

    it 'audit logs creation of the key' do
      audit_logger.should_receive(:log)
      key_creator.create(:name => 'name', :key => 'key contents')
    end
  end
end

