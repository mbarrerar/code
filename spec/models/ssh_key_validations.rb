
module SshKeyValidations
  shared_examples_for 'Valid SshKeys' do
    it "should be valid" do
      @ssh_key.should be_valid
    end

    it "should require :ssh_key_authenticatable" do
      @ssh_key.ssh_key_authenticatable = nil
      @ssh_key.should have(1).error_on(:ssh_key_authenticatable_id)
    end

    it "should require name" do
      @ssh_key.name = nil
      @ssh_key.should have(1).error_on(:name)
    end

    it "should require key" do
      @ssh_key.key = nil
      @ssh_key.should have(1).error_on(:key)
    end

    it "should require globally unique key" do
      key2 = FactoryGirl.create(:ssh_key, :name => "key2", :key => "key2")
      @ssh_key.key = key2.key
      @ssh_key.should have(1).error_on(:key)
    end

    it "should require (:ssh_key_authenticatable scoped) unique name" do
      user = FactoryGirl.create(:user)
      key_a = user.ssh_keys.create!(FactoryGirl.attributes_for(:ssh_key))
      key_b = user.ssh_keys.create!(FactoryGirl.attributes_for(:ssh_key))

      key_a.name = key_b.name
      key_a.should have(1).error_on(:name)
    end

    it "should allow same key name for different :ssh_key_authenticatable relations" do
      user_a = FactoryGirl.create(:user)
      key_a = user_a.ssh_keys.create!(FactoryGirl.attributes_for(:ssh_key))

      user_b = FactoryGirl.create(:user)
      key_b = user_b.ssh_keys.create!(FactoryGirl.attributes_for(:ssh_key))

      key = user_b.ssh_keys.create!(:name => key_a.name, :key => "key_b")
      key.should have(0).error_on(:name)
    end

    it "should not allow keys to contain ssh directives" do
      tokens = SshKey::SSH_DIRECTIVES
      tokens.each do |t|
        @ssh_key.key = "ssh-rsa asdfsadfsaf #{t} adsfasdf"
        @ssh_key.should have(1).error_on(:key)
      end
    end

    it "should remove all line breaks from the key" do
      @ssh_key.key = "precontents\r\npostcontents\r\n"
      @ssh_key.clean_key.include?("\r\n").should be_false
    end
  end
end
