require 'spec_helper'


describe 'SshKeyAudit.log' do

  it 'should work' do
    pending "This should write to db table"
    edited_by = FactoryGirl.build(:user)
    ssh_key = FactoryGirl.build(:ssh_key)

    SshKeyAudit.should_receive(:audit_msg).with(ssh_key.key, edited_by.full_name, ssh_key.user.username, :destroy).once
    SshKeyAudit.log(ssh_key, edited_by, :destroy)
  end
end
