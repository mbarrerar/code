class MakeSshKeysPolymorphic < ActiveRecord::Migration
  def self.up
    add_column :ssh_keys, :ssh_key_authenticatable_id, :integer
    add_column :ssh_keys, :ssh_key_authenticatable_type, :string
  end

  def self.down
    remove_column :ssh_keys, :ssh_key_authenticatable_id
    remove_column :ssh_keys, :ssh_key_authenticatable_type
  end
end
