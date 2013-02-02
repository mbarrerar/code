class Indexes < ActiveRecord::Migration
  def self.up
    add_index 'ssh_keys', 'ssh_key_authenticatable_id'
    add_index 'collaborations', 'created_by_id'
    add_index 'space_administrations', 'created_by_id'
  end

  def self.down
  end
end
