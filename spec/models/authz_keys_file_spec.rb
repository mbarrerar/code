require 'spec_helper'


describe AuthzKeysFile do
  let(:authz_keys) { AuthzKeysFile.new }
  let(:ssh_key) { mock('SshKey', :username => 'runner', :key => 'key contents') }

  context("#initialize(args)") do
    it "auto creates authorized_key file if it does not exist" do
      expect(File.exists?(authz_keys.file_path)).to be_true
    end
  end

  context("#write(ssh_keys)") do
    it "should update authorized_keys file with provided keys" do
      authz_keys.write([ssh_key])
      entry = File.readlines(authz_keys.file_path).first

      expect(entry).to match('runner')
      expect(entry).to match('key contents')
    end
  end

  context("#file_path") do
    it "should know the location of the authorized_keys file" do
      expect(authz_keys.file_path).to eql("#{AppConfig.ssh_dir}/authorized_keys")
    end
  end

  context("#entries") do
    it "returns array of ssh keys entries from authorized_keys file" do
      authz_keys.write([ssh_key])
      expect(authz_keys.entries).to have(1).key
    end
  end

  context("#create") do
    before(:each) do
      authz_keys.delete
      expect(File.exists?(authz_keys.file_path)).to be_false
    end

    it 'should create the authorized_keys file' do
      authz_keys.create
      expect(File.exists?(authz_keys.file_path)).to be_true
    end

    it 'should create the file with correct permissions' do
      authz_keys.create

      mode = File.stat(authz_keys.file_path).mode.to_s(8)
      expect(mode).to eql("100660")

      group_gid = File.stat(authz_keys.file_path).gid
      group_name = Etc.getgrgid(group_gid).name
      expect(group_name).to eql(authz_keys.app_group)
    end
  end

  context("#delete") do
    it 'should delete the authorized_keys file' do
      expect(File.exists?(authz_keys.file_path)).to be_true

      authz_keys.delete

      expect(File.exists?(authz_keys.file_path)).to be_false
    end
  end
end
