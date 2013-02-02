class AddSizeToSpacesAndRepos < ActiveRecord::Migration
  def self.up
    add_column :spaces, :actual_size, :integer, :limit => 8, :default => 0
    add_column :repos, :actual_size, :integer, :limit => 8, :default => 0
  end

  def self.down
    remove_column :repos, :actual_size
    remove_column :spaces, :actual_size
  end
end
