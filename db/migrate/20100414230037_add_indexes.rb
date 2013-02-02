class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index 'spaces', 'owner_id'
    add_index 'ssh_keys', 'user_id'
    add_index 'repos', 'space_id'
    add_index 'space_administrations', 'space_id'
    add_index 'space_administrations', 'user_id'
    add_index 'collaborations', 'repo_id'
    add_index 'collaborations', 'user_id'
  end

  def self.down
  end
end
