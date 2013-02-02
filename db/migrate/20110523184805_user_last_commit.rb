class UserLastCommit < ActiveRecord::Migration
  def self.up
    add_column :users, :last_svn_access, :timestamp
  end

  def self.down
    remove_column :users, :last_svn_access
  end
end
