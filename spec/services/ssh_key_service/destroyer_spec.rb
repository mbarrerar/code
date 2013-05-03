require 'spec_helper'


describe SshKeyService::Destroyer do
  let(:key_owner) { FactoryGirl.create(:user) }
  let(:current_user) { FactoryGirl.create(:user) }
  let(:key_writer) { mock('KeyWriter', :write => true) }
  let(:audit_logger) { mock('AuditLogger', :log => true) }

  let(:key_destroyer) {
    SshKeyService::Destroyer.new(
        :key_owner => key_owner,
        :current_user => current_user,
        :key_writer => key_writer,
        :audit_logger => audit_logger
    )
  }

  context 'initialize(args)' do
    it 'requires :current_user, :key_owner' do
      expect { SshKeyService::Destroyer.new(:current_user => mock, :key_owner => mock) }.to_not raise_error
      expect { SshKeyService::Destroyer.new(:current_user => mock) }.to raise_error
      expect { SshKeyService::Destroyer.new(:key_owner => mock) }.to raise_error
      expect { SshKeyService::Destroyer.new }.to raise_error
    end
  end

  context 'destroy(key_params)' do
    let(:key) { key_owner.ssh_keys.create(:name => 'name', :key => 'contents') }

    it 'removes the key from db' do
      expect(key).to be_persisted

      key_destroyer.destroy(key.id)

      expect(SshKey.count).to eql(0)
    end

    it 'writes the key to the ssh authorized_keys file' do
      key_writer.should_receive(:write)
      key_destroyer.destroy(key.id)
    end

    it 'audit logs creation of the key' do
      audit_logger.should_receive(:log).with(key, current_user, :destroy)
      key_destroyer.destroy(key.id)
    end
  end
end

